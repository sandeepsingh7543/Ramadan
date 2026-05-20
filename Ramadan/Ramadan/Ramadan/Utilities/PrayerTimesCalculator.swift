//
//  PrayerTimesCalculator.swift
//  Ramadan
//
//  Created by Mobi iOS on 23/02/26.
//

import Foundation
import CoreLocation

struct PrayerTimes {
    var fajr: Date
    var sunrise: Date
    var dhuhr: Date
    var asr: Date
    var maghrib: Date
    var isha: Date
    var sehar: Date
    var iftar: Date
}

class PrayerTimesCalculator {
    static func calculate(for location: CLLocation, date: Date = Date()) -> PrayerTimes {
        let calendar = Calendar.current
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let declination = 23.45 * sin((360.0 / 365.0) * Double(dayOfYear - 81) * .pi / 180.0)
        
        let sunriseHourAngle = acos(-tan(latitude * .pi / 180.0) * tan(declination * .pi / 180.0)) * 180.0 / .pi
        let sunriseTime = 12.0 - (sunriseHourAngle / 15.0) - (longitude / 15.0)
        let sunsetTime = 12.0 + (sunriseHourAngle / 15.0) - (longitude / 15.0)
        
        let fajrTime = sunriseTime - 1.5
        let dhuhrTime = 12.0 - (longitude / 15.0) + 0.1
        let asrTime = dhuhrTime + 3.5
        let maghribTime = sunsetTime + 0.05
        let ishaTime = maghribTime + 1.5
        
        func createDate(hour: Double) -> Date {
            let hours = Int(hour)
            let minutes = Int((hour - Double(hours)) * 60)
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = hours
            components.minute = minutes
            return calendar.date(from: components) ?? date
        }
        
        return PrayerTimes(
            fajr: createDate(hour: fajrTime),
            sunrise: createDate(hour: sunriseTime),
            dhuhr: createDate(hour: dhuhrTime),
            asr: createDate(hour: asrTime),
            maghrib: createDate(hour: maghribTime),
            isha: createDate(hour: ishaTime),
            sehar: createDate(hour: fajrTime - 0.5),
            iftar: createDate(hour: maghribTime)
        )
    }
}
