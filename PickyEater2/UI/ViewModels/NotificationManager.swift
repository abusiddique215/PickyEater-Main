import Foundation
import SwiftUI
import UserNotifications
import PickyEater2Core

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private init() {}
    
    @Published var isAuthorized = false
    
    func requestAuthorization() async {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            isAuthorized = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print("Error requesting notification authorization: \(error.localizedDescription)")
            isAuthorized = false
        }
    }
    
    func scheduleRestaurantNotification(for restaurant: AppRestaurant) {
        let content = UNMutableNotificationContent()
        content.title = "Time to eat!"
        content.body = "Check out \(restaurant.name) - it matches your preferences!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
