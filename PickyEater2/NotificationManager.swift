import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    @Published var hasPermission = false
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() async throws {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        
        DispatchQueue.main.async {
            self.hasPermission = granted
        }
        
        // Register for remote notifications on the main thread
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func scheduleLocalNotification(title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleRestaurantReminder(restaurant: Restaurant, timeInterval: TimeInterval = 3600) {
        let content = UNMutableNotificationContent()
        content.title = "Time to order from \(restaurant.name)!"
        content.body = "Check out their menu and place your order now."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(
            identifier: "restaurant-reminder-\(restaurant.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleOrderStatusNotification(orderStatus: String) {
        let content = UNMutableNotificationContent()
        content.title = "Order Status Update"
        content.body = orderStatus
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        let userInfo = response.notification.request.content.userInfo
        
        // Handle different notification types
        if identifier.starts(with: "restaurant-reminder-") {
            let restaurantId = identifier.replacingOccurrences(of: "restaurant-reminder-", with: "")
            handleRestaurantReminder(restaurantId: restaurantId, userInfo: userInfo)
        } else if let type = userInfo["type"] as? String {
            switch type {
            case "order_status":
                if let status = userInfo["status"] as? String {
                    handleOrderStatus(status: status)
                }
            case "promotion":
                if let message = userInfo["message"] as? String {
                    handlePromotion(message: message)
                }
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    private func handleRestaurantReminder(restaurantId: String, userInfo: [AnyHashable: Any]) {
        // Handle restaurant reminder tap
        print("Opening restaurant details for ID: \(restaurantId)")
        // TODO: Navigate to restaurant details
    }
    
    private func handleOrderStatus(status: String) {
        print("Order status updated: \(status)")
        // TODO: Update order status in UI
    }
    
    private func handlePromotion(message: String) {
        print("Received promotion: \(message)")
        // TODO: Show promotion in UI
    }
} 