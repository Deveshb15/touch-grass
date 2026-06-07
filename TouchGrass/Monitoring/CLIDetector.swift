import Foundation
import Darwin

/// The result of one CLI scan: the first matched AI CLI name (for the HUD) and
/// every pid whose argv matched a wanted CLI name (for CPU sampling).
struct CLIScan {
    let name: String?
    let pids: [pid_t]
}

/// Detects AI command-line tools running for the current user by scanning the
/// process table with libproc. `NSRunningApplication` only sees GUI apps, so a
/// `claude`/`codex` process is invisible to it — libproc is the mechanism.
///
/// Matching is on **argv[0]**, not the executable path: tools like Claude Code
/// install a versioned binary (e.g. `~/.local/share/claude/versions/2.1.168`),
/// so `proc_pidpath`/`proc_name` report `2.1.168` while argv[0] is `claude`.
/// For interpreter-hosted CLIs (`node …/claude`) we also check argv[1].
final class CLIDetector {
    private let names: () -> Set<String>
    private var cachedScan = CLIScan(name: nil, pids: [])
    private var lastScan: Date = .distantPast
    private let throttle: TimeInterval = 2.0

    private static let interpreters: Set<String> = [
        "node", "bun", "deno", "ruby", "uv", "npx", "npm", "pnpm",
    ]
    private static func isInterpreter(_ base: String) -> Bool {
        interpreters.contains(base) || base.hasPrefix("python")
    }

    init(names: @escaping () -> Set<String>) {
        self.names = names
    }

    /// Returns the matched AI CLI name if one is running, else nil. Throttled.
    func activeAICLI() -> String? { scan().name }

    /// Returns the matched CLI name + every matching pid. Throttled (2 s); CPU
    /// sampling tolerates the gap since it diffs over actual elapsed time.
    func scan() -> CLIScan {
        if Date().timeIntervalSince(lastScan) < throttle { return cachedScan }
        lastScan = Date()
        cachedScan = fullScan()
        return cachedScan
    }

    private func fullScan() -> CLIScan {
        let wanted = names()
        guard !wanted.isEmpty else { return CLIScan(name: nil, pids: []) }
        var name: String?
        var pids: [pid_t] = []
        for pid in listPIDs() where pid > 0 {
            if let match = match(pid: pid, wanted: wanted) {
                if name == nil { name = match }
                pids.append(pid)
            }
        }
        return CLIScan(name: name, pids: pids)
    }

    private func match(pid: pid_t, wanted: Set<String>) -> String? {
        guard let argv = processArgs(pid), let arg0 = argv.first else {
            return nil
        }
        // argv[0] = the command as launched ("claude" even for a versioned binary).
        let base0 = (arg0 as NSString).lastPathComponent
        if wanted.contains(base0) { return base0 }
        if wanted.contains(arg0) { return arg0 }
        // `node …/bin/claude --flag` → the tool is the script in argv[1].
        if Self.isInterpreter(base0), argv.count > 1 {
            let base1 = (argv[1] as NSString).lastPathComponent
            if wanted.contains(base1) { return base1 }
        }
        return nil
    }

    /// All PIDs on the system. Uses `proc_listpids(PROC_ALL_PIDS)` with a
    /// probe-then-fill: `proc_listallpids` was observed to silently under-report
    /// (returning ~240 of ~960 processes and omitting the very CLIs we look for),
    /// so the agent was never detected. We size the buffer from a nil-buffer probe
    /// plus a margin for processes spawned between the probe and the fill.
    private func listPIDs() -> [pid_t] {
        let probe = proc_listpids(UInt32(PROC_ALL_PIDS), 0, nil, 0)
        guard probe > 0 else { return [] }
        let capacity = Int(probe) / MemoryLayout<pid_t>.size + 64
        var buffer = [pid_t](repeating: 0, count: capacity)
        let bytes = proc_listpids(UInt32(PROC_ALL_PIDS), 0, &buffer,
                                  Int32(capacity * MemoryLayout<pid_t>.size))
        guard bytes > 0 else { return [] }
        return Array(buffer.prefix(Int(bytes) / MemoryLayout<pid_t>.size))
    }

    /// Returns argv for a process via KERN_PROCARGS2. Buffer is sized to the
    /// process's actual arg blob (probe with a nil buffer first), not KERN_ARGMAX,
    /// so scanning every process stays cheap. nil if unreadable (e.g. other users).
    private func processArgs(_ pid: pid_t) -> [String]? {
        var size = 0
        var mib: [Int32] = [CTL_KERN, KERN_PROCARGS2, pid]
        guard sysctl(&mib, 3, nil, &size, nil, 0) == 0, size > MemoryLayout<Int32>.size else {
            return nil
        }
        var buffer = [CChar](repeating: 0, count: size)
        guard sysctl(&mib, 3, &buffer, &size, nil, 0) == 0 else { return nil }

        // Layout: [int argc][exec_path\0][padding \0...][argv0\0 argv1\0 ...][env...]
        var argc: Int32 = 0
        withUnsafeMutableBytes(of: &argc) { dst in
            buffer.withUnsafeBytes { src in
                dst.copyBytes(from: UnsafeRawBufferPointer(rebasing: src.prefix(MemoryLayout<Int32>.size)))
            }
        }
        guard argc > 0 else { return nil }

        var offset = MemoryLayout<Int32>.size
        while offset < size && buffer[offset] != 0 { offset += 1 }   // skip exec_path
        while offset < size && buffer[offset] == 0 { offset += 1 }   // skip padding

        var args: [String] = []
        var parsed: Int32 = 0
        while parsed < argc && offset < size {
            let start = offset
            while offset < size && buffer[offset] != 0 { offset += 1 }
            if offset > start {
                let bytes = buffer[start..<offset].map { UInt8(bitPattern: $0) }
                args.append(String(decoding: bytes, as: UTF8.self))
            }
            offset += 1   // skip the null terminator
            parsed += 1
        }
        return args.isEmpty ? nil : args
    }
}
