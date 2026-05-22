import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                self.scheduleAllPrayerNotifications()
            }
        }
    }
    
    func scheduleAllPrayerNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule for next 7 days
        for dayOffset in 0..<7 {
            schedulePrayerNotifications(daysFromNow: dayOffset)
        }
    }
    
    private func schedulePrayerNotifications(daysFromNow: Int) {
        let calendar = Calendar.current
        guard let targetDate = calendar.date(byAdding: .day, value: daysFromNow, to: Date()) else { return }
        
        let prayers = [
            (name: "Fajr", hour: 5, minute: 30),
            (name: "Dhuhr", hour: 12, minute: 30),
            (name: "Asr", hour: 15, minute: 45),
            (name: "Maghrib", hour: 18, minute: 15),
            (name: "Isha", hour: 19, minute: 45)
        ]
        
        for prayer in prayers {
            guard let prayerTime = calendar.date(bySettingHour: prayer.hour, minute: prayer.minute, second: 0, of: targetDate) else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "Time for \(prayer.name)"
            content.body = "It's time to pray \(prayer.name)"
            content.sound = .default
            
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: prayerTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "\(prayer.name)-\(daysFromNow)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
}
