import Foundation
@preconcurrency import UserNotifications

struct UsageNotification: Equatable, Sendable {
    let identifier: String
    let title: String
    let body: String
}

protocol NotificationDelivering: Sendable {
    func requestAuthorization() async -> Bool
    func send(notification: UsageNotification) async
}

enum UsageNotificationBuilder {
    static func build(
        alert: UsageAlert,
        snapshot: UsageSnapshot,
        forecast: UsageForecast?
    ) -> UsageNotification {
        let providerName = snapshot.providerName
        let identifier = "\(snapshot.accountID.uuidString).\(alert.trigger.rawValue)"

        if let threshold = alert.trigger.thresholdPercent {
            return UsageNotification(
                identifier: identifier,
                title: "\(providerName) usage alert",
                body: "Usage crossed \(threshold)%."
            )
        }

        let exhaustionText: String
        if let date = forecast?.estimatedExhaustionDate {
            exhaustionText = "Quota may exhaust by \(Self.dateFormatter.string(from: date))."
        } else if let days = forecast?.daysRemaining {
            exhaustionText = "Quota may exhaust in about \(Int(days.rounded())) days."
        } else {
            exhaustionText = "Quota may exhaust within 7 days."
        }

        return UsageNotification(
            identifier: identifier,
            title: "\(providerName) exhaustion forecast",
            body: exhaustionText
        )
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

struct SystemNotificationService: NotificationDelivering {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func send(notification: UsageNotification) async {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: notification.identifier,
            content: content,
            trigger: nil
        )

        try? await center.add(request)
    }
}

private actor RecordingNotificationActor {
    var authorizationRequested = false
    var delivered: [UsageNotification] = []

    func setAuthorizationRequested() {
        authorizationRequested = true
    }

    func appendDelivered(_ notification: UsageNotification) {
        delivered.append(notification)
    }
}

final class RecordingNotificationService: NotificationDelivering, @unchecked Sendable {
    private let storage = RecordingNotificationActor()

    func requestAuthorization() async -> Bool {
        await storage.setAuthorizationRequested()
        return true
    }

    func send(notification: UsageNotification) async {
        await storage.appendDelivered(notification)
    }

    // Async accessors for testing or inspection:

    func getAuthorizationRequested() async -> Bool {
        await storage.authorizationRequested
    }

    func getDeliveredNotifications() async -> [UsageNotification] {
        await storage.delivered
    }
}
