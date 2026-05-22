import Foundation
import CoreLocation

struct HijriDate {
    let day: Int
    let month: String
    let year: Int
    
    var formatted: String {
        "\(day) \(month) \(year)"
    }
}

struct QuranVerse: Identifiable {
    let id = UUID()
    let surahNumber: Int
    let verseNumber: Int
    let arabicText: String
    let translation: String
    let transliteration: String?
}

struct Surah: Identifiable {
    let id: Int
    let name: String
    let arabicName: String
    let englishName: String
    let numberOfVerses: Int
    let revelationType: String
}

struct Dua: Identifiable {
    let id = UUID()
    let title: String
    let arabicText: String
    let transliteration: String
    let translation: String
    let reference: String
}

struct Mosque: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let distance: Double?
}

extension CLLocationCoordinate2D {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
