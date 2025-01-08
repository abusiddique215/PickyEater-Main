import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Request notification permission when app launches
        Task {
            do {
                try await NotificationManager.shared.requestPermission()
            } catch {
                print("Failed to request notification permission: \(error)")
            }
        }
        return true
    }

    func application(
        _: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Convert token to string
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")

        // TODO: Send this token to your server
    }

    func application(
        _: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }

    func application(
        _: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Handle silent notifications
        if let aps = userInfo["aps"] as? [String: Any] {
            if let contentAvailable = aps["content-available"] as? Int, contentAvailable == 1 {
                // This is a silent notification
                // Perform background fetch
                completionHandler(.newData)
                return
            }
        }

        completionHandler(.noData)
    }
}
