import Foundation
import Darwin

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
    private var cached: String?
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
    func activeAICLI() -> String? {
        if Date().timeIntervalSince(lastScan) < throttle { return cached }
        lastScan = Date()
        cached = scan()
        return cached
    }

    private func scan() -> String? {
        let wanted = names()
        guard !wanted.isEmpty else { return nil }
        for pid in listPIDs() where pid > 0 {
            if let match = match(pid: pid, wanted: wanted) { return match }
        }
        return nil
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

    private func listPIDs() -> [pid_t] {
        let maxCount = 8192
        var buffer = [pid_t](repeating: 0, count: maxCount)
        let byteCount = proc_listallpids(&buffer, Int32(maxCount * MemoryLayout<pid_t>.size))
        guard byteCount > 0 else { return [] }
        return Array(buffer.prefix(Int(byteCount) / MemoryLayout<pid_t>.size))
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
