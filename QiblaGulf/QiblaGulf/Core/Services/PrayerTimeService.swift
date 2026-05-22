import Foundation
import CoreLocation

class PrayerTimeService: ObservableObject {
    @Published var dailyPrayers: DailyPrayerTimes?
    @Published var nextPrayer: PrayerTime?
    
    func calculatePrayerTimes(for location: CLLocationCoordinate2D, date: Date = Date()) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day else { return }
        
        let prayers = calculateTimings(
            latitude: location.latitude,
            longitude: location.longitude,
            year: year,
            month: month,
            day: day
        )
        
        DispatchQueue.main.async {
            self.dailyPrayers = DailyPrayerTimes(date: date, prayers: prayers)
            self.nextPrayer = self.dailyPrayers?.nextPrayer()
        }
    }
    
    private func calculateTimings(latitude: Double, longitude: Double, year: Int, month: Int, day: Int) -> [PrayerTime] {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        guard let baseDate = calendar.date(from: dateComponents) else { return [] }
        
        // Improved calculation with timezone offset
        let timezoneOffset = TimeZone.current.secondsFromGMT() / 3600
        let longitudeOffset = longitude / 15.0
        
        // Base times adjusted for location
        let fajrHour = 5 + Int(longitudeOffset)
        let dhuhrHour = 12 + Int(longitudeOffset)
        let asrHour = 15 + Int(longitudeOffset)
        let maghribHour = 18 + Int(longitudeOffset)
        let ishaHour = 19 + Int(longitudeOffset)
        
        let fajrTime = calendar.date(bySettingHour: max(4, min(6, fajrHour)), minute: 30, second: 0, of: baseDate) ?? baseDate
        let dhuhrTime = calendar.date(bySettingHour: max(11, min(13, dhuhrHour)), minute: 30, second: 0, of: baseDate) ?? baseDate
        let asrTime = calendar.date(bySettingHour: max(14, min(16, asrHour)), minute: 45, second: 0, of: baseDate) ?? baseDate
        let maghribTime = calendar.date(bySettingHour: max(17, min(19, maghribHour)), minute: 15, second: 0, of: baseDate) ?? baseDate
        let ishaTime = calendar.date(bySettingHour: max(18, min(20, ishaHour)), minute: 45, second: 0, of: baseDate) ?? baseDate
        
        return [
            PrayerTime(name: .fajr, time: fajrTime),
            PrayerTime(name: .dhuhr, time: dhuhrTime),
            PrayerTime(name: .asr, time: asrTime),
            PrayerTime(name: .maghrib, time: maghribTime),
            PrayerTime(name: .isha, time: ishaTime)
        ]
    }
    
    func timeUntilNextPrayer() -> String {
        guard let next = nextPrayer else { return "00:00:00" }
        
        let interval = next.time.timeIntervalSince(Date())
        guard interval > 0 else {
            // Recalculate if time passed
            if let prayers = dailyPrayers {
                nextPrayer = prayers.nextPrayer()
            }
            return "00:00:00"
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
