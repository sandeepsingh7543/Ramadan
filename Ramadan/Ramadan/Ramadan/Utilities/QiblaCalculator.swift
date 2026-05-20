//
//  QiblaCalculator.swift
//  Ramadan
//
//  Created by Mobi iOS on 23/02/26.
//

import CoreLocation

class QiblaCalculator {
    static let kaabaLocation = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
    
    static func calculateQiblaDirection(from userLocation: CLLocationCoordinate2D) -> Double {
        let lat1 = userLocation.latitude * .pi / 180.0
        let lon1 = userLocation.longitude * .pi / 180.0
        let lat2 = kaabaLocation.latitude * .pi / 180.0
        let lon2 = kaabaLocation.longitude * .pi / 180.0
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var bearing = atan2(y, x) * 180.0 / .pi
        bearing = (bearing + 360.0).truncatingRemainder(dividingBy: 360.0)
        
        return bearing
    }
}
