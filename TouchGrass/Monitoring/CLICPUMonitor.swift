import Foundation
import Darwin

/// Per-tick CPU sampler for AI-CLI processes, used to tell whether an agent is
/// actually *working* (vs. just sitting alive at a prompt). Reads cumulative
/// on-CPU time per pid via libproc `proc_pid_rusage`, diffs it against the
/// previous tick, and reports "working" when any tracked pid's CPU fraction over
/// the elapsed interval exceeds a small threshold.
///
/// No new permission: this reads same-user process resource info — the same
/// access class `CLIDetector` already uses via `sysctl(KERN_PROCARGS2)` — and
/// works in the app's non-sandboxed configuration without Input Monitoring or
/// Accessibility.
///
/// The signal is intentionally *bursty*: while a model "thinks" server-side the
/// local process burns ~0 CPU, so this returns false during the wait. That gap
/// is bridged by the caller's grace window (`backgroundGraceSeconds`) — which is
/// why the threshold stays low and the grace generous.
final class CLICPUMonitor {
    private struct Sample { var ticks: UInt64; var at: Date }
    private var last: [pid_t: Sample] = [:]

    /// Nanoseconds per `ri_user_time`/`ri_system_time` unit. Those fields are in
    /// mach absolute-time units, NOT nanoseconds: on Apple Silicon the timebase is
    /// 125/3 (≈41.67 ns/unit), so a fully-busy core reads ~24M units/sec. Treating
    /// the raw value as nanoseconds undercounts CPU by ~42×. On Intel the timebase
    /// is 1/1, making this conversion a no-op — so it's correct on both.
    private let nsPerTick: Double = {
        var tb = mach_timebase_info_data_t()
        mach_timebase_info(&tb)
        return Double(tb.numer) / Double(tb.denom)
    }()

    /// Cumulative on-CPU time (mach time units, user+system) for `pid`, or nil if
    /// the process exited or its rusage is unreadable.
    private func cpuTicks(_ pid: pid_t) -> UInt64? {
        var info = rusage_info_v4()
        let rc = withUnsafeMutablePointer(to: &info) { ptr -> Int32 in
            ptr.withMemoryRebound(to: rusage_info_t?.self, capacity: 1) {
                proc_pid_rusage(pid, RUSAGE_INFO_V4, $0)
            }
        }
        guard rc == 0 else { return nil }
        // ri_child_* only accrues for *reaped* children, so a live `node` worker's
        // CPU isn't captured here — but interpreter-hosted CLIs are matched on
        // argv[1], so that worker pid is tracked directly by the caller instead.
        return info.ri_user_time &+ info.ri_system_time
    }

    /// True if any of `pids` is consuming CPU above `threshold` (a fraction of one
    /// core, 0…1) since its previous reading. Maintains the pid→sample map: a newly
    /// seen pid only seeds a baseline (returns false that tick); pids that vanished
    /// are dropped so the map can't grow without bound.
    func isWorking(pids: [pid_t], threshold: Double) -> Bool {
        let now = Date()
        var working = false
        var seen = Set<pid_t>()

        for pid in pids {
            guard let ticks = cpuTicks(pid) else { continue }   // exited / unreadable
            seen.insert(pid)
            defer { last[pid] = Sample(ticks: ticks, at: now) }

            guard let prev = last[pid] else { continue }        // first sight: baseline only
            let elapsed = now.timeIntervalSince(prev.at)
            guard elapsed > 0.05 else { continue }
            guard ticks >= prev.ticks else { continue }         // guard pid reuse / counter resets
            let cpuSeconds = Double(ticks - prev.ticks) * nsPerTick / 1_000_000_000
            if cpuSeconds / elapsed >= threshold { working = true }
        }

        last = last.filter { seen.contains($0.key) }
        return working
    }
}
