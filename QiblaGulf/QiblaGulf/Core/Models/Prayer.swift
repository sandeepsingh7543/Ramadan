import Foundation

enum PrayerName: String, CaseIterable {
    case fajr = "Fajr"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"
}

struct PrayerTime: Identifiable {
    let id = UUID()
    let name: PrayerName
    let time: Date
    var isCompleted: Bool = false
}

struct DailyPrayerTimes {
    let date: Date
    let prayers: [PrayerTime]
    
    func nextPrayer() -> PrayerTime? {
        prayers.first { $0.time > Date() }
    }
    
    func currentPrayer() -> PrayerTime? {
        let now = Date()
        return prayers.last { $0.time <= now }
    }
}
