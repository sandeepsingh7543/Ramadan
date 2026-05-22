import Foundation

class HijriCalendarService {
    static func getCurrentHijriDate() -> HijriDate {
        let calendar = Calendar(identifier: .islamicUmmAlQura)
        let components = calendar.dateComponents([.day, .month, .year], from: Date())
        
        let monthNames = [
            "Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani",
            "Jumada al-Awwal", "Jumada al-Thani", "Rajab", "Sha'ban",
            "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"
        ]
        
        let monthName = monthNames[(components.month ?? 1) - 1]
        
        return HijriDate(
            day: components.day ?? 1,
            month: monthName,
            year: components.year ?? 1445
        )
    }
}
