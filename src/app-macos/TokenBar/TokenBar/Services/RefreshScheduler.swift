import Foundation

@MainActor
protocol RefreshScheduling {
    func apply(interval: RefreshInterval, refresh: @escaping () async -> Void)
    func stop()
}

@MainActor
final class RefreshScheduler: RefreshScheduling {
    private var task: Task<Void, Never>?

    func apply(interval: RefreshInterval, refresh: @escaping () async -> Void) {
        stop()

        guard let seconds = interval.seconds else {
            return
        }

        task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(seconds))
                guard !Task.isCancelled else { break }
                await refresh()
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
    }
}
