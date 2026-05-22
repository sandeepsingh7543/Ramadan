import SwiftUI
import CoreLocation
import MapKit

struct QiblaView: View {
    @StateObject private var compassManager = CompassManager()
    @StateObject private var locationService = LocationService()
    @State private var isCalibrating = false
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            // Background Map
            if let location = locationService.location {
                Map(position: $cameraPosition) {
                    UserAnnotation()
                }
                .mapStyle(.standard(elevation: .flat))
                .ignoresSafeArea()
                .onAppear {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    ))
                }
                .onChange(of: locationService.location) { _, newLocation in
                    if let loc = newLocation {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: loc,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                    }
                }
                
                // Overlay gradient for better visibility
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.85),
                        Color.white.opacity(0.75),
                        Color.white.opacity(0.65)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [Color.theme.background, Color.theme.primary.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Text("Qibla Direction")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    if let location = locationService.location {
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("Direction")
                                    .font(.caption)
                                    .foregroundColor(Color.theme.textSecondary)
                                Text("\(Int(compassManager.qiblaDirection))°")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.theme.primary)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack(spacing: 4) {
                                Text("Heading")
                                    .font(.caption)
                                    .foregroundColor(Color.theme.textSecondary)
                                Text("\(Int(compassManager.heading))°")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.theme.accent)
                            }
                        }
                        .padding()
                        .background(Color.theme.cardBackground)
                        .cornerRadius(16)
                    } else {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(Color.theme.primary)
                            Text("Getting location...")
                                .font(.subheadline)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        .padding()
                        .background(Color.theme.cardBackground)
                        .cornerRadius(16)
                    }
                }
                .padding(.top, 20)
                
                // Compass
                ZStack {
                    // White background for compass
                    Circle()
                        .fill(Color.white.opacity(0.95))
                        .frame(width: 320, height: 320)
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                    
                    // Outer glow
                    Circle()
                        .fill(Color.theme.primary.opacity(0.05))
                        .frame(width: 310, height: 310)
                    
                    // Main circle
                    Circle()
                        .stroke(Color.theme.primary.opacity(0.4), lineWidth: 3)
                        .frame(width: 300, height: 300)
                    
                    // Inner circle
                    Circle()
                        .stroke(Color.theme.primary.opacity(0.3), lineWidth: 2)
                        .frame(width: 250, height: 250)
                    
                    // Compass Rose
                    CompassRose()
                        .frame(width: 280, height: 280)
                        .rotationEffect(Angle(degrees: -compassManager.heading))
                        .animation(.easeInOut(duration: 0.3), value: compassManager.heading)
                    
                    // Qibla Indicator
                    QiblaIndicator()
                        .rotationEffect(Angle(degrees: compassManager.qiblaDirection - compassManager.heading))
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: compassManager.qiblaDirection - compassManager.heading)
                    
                    // Center dot
                    Circle()
                        .fill(Color.theme.primary)
                        .frame(width: 12, height: 12)
                }
                .padding(.vertical, 20)
                
                // Info Cards
                if let location = locationService.location {
                    VStack(spacing: 16) {
                        // Distance Card
                        HStack {
                            Image(systemName: "map.fill")
                                .font(.title2)
                                .foregroundColor(Color.theme.primary)
                                .frame(width: 50)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Distance to Kaaba")
                                    .font(.caption)
                                    .foregroundColor(Color.theme.textSecondary)
                                Text("\(formatDistance(distanceToMakkah(from: location)))")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.theme.cardBackground)
                        .cornerRadius(16)
                        
                        // Location Card
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color.theme.accent)
                                .frame(width: 50)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Location")
                                    .font(.caption)
                                    .foregroundColor(Color.theme.textSecondary)
                                Text("\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                                    .font(.footnote)
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.theme.cardBackground)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Calibration Tip
                if !isCalibrating {
                    VStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color.theme.secondary)
                        Text("Move your device in a figure-8 pattern to calibrate")
                            .font(.caption)
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.theme.cardBackground.opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            locationService.requestPermission()
            locationService.startUpdating()
            compassManager.startUpdating()
            
            // Calculate qibla if location already available
            if let location = locationService.location {
                compassManager.calculateQiblaDirection(from: location)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isCalibrating = true
            }
        }
        .onDisappear {
            compassManager.stopUpdating()
        }
        .onChange(of: locationService.location) { _, newLocation in
            if let location = newLocation {
                compassManager.calculateQiblaDirection(from: location)
            }
        }
    }
    
    private func distanceToMakkah(from location: CLLocationCoordinate2D) -> Double {
        let makkah = CLLocation(latitude: 21.4225, longitude: 39.8262)
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return userLocation.distance(from: makkah) / 1000
    }
    
    private func formatDistance(_ km: Double) -> String {
        if km < 1 {
            return "\(Int(km * 1000)) meters"
        } else if km < 1000 {
            return "\(Int(km)) km"
        } else {
            return String(format: "%.1f km", km)
        }
    }
}

struct CompassRose: View {
    var body: some View {
        ZStack {
            // Cardinal directions with better styling
            ForEach(Array(zip(["N", "E", "S", "W"], [0, 90, 180, 270])), id: \.0) { direction, angle in
                VStack(spacing: 4) {
                    Text(direction)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(direction == "N" ? Color.red : Color.theme.textPrimary)
                    
                    if direction == "N" {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .rotationEffect(Angle(degrees: -Double(angle)))
                .offset(y: -115)
                .rotationEffect(Angle(degrees: Double(angle)))
            }
            
            // Degree markers
            ForEach(0..<72) { index in
                Rectangle()
                    .fill(index % 9 == 0 ? Color.theme.primary : Color.theme.textSecondary.opacity(0.5))
                    .frame(width: index % 9 == 0 ? 3 : 1, height: index % 9 == 0 ? 20 : 10)
                    .offset(y: -125)
                    .rotationEffect(Angle(degrees: Double(index) * 5))
            }
        }
    }
}

struct QiblaIndicator: View {
    var body: some View {
        VStack(spacing: 0) {
            // Kaaba icon
            ZStack {
                Circle()
                    .fill(Color.theme.primary)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.theme.primary.opacity(0.5), radius: 15)
                
                Image(systemName: "building.2.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            
            // Arrow line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.theme.primary, Color.theme.primary.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4, height: 70)
            
            // Arrow tip
            Image(systemName: "arrowtriangle.down.fill")
                .font(.title2)
                .foregroundColor(Color.theme.primary)
        }
        .offset(y: -50)
    }
}

class CompassManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var heading: Double = 0
    @Published var qiblaDirection: Double = 0
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.headingFilter = 1
    }
    
    func startUpdating() {
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingHeading()
    }
    
    func calculateQiblaDirection(from location: CLLocationCoordinate2D) {
        let makkahLat = 21.4225
        let makkahLon = 39.8262
        
        let userLat = location.latitude * .pi / 180
        let userLon = location.longitude * .pi / 180
        let makkahLatRad = makkahLat * .pi / 180
        let makkahLonRad = makkahLon * .pi / 180
        
        let dLon = makkahLonRad - userLon
        
        let y = sin(dLon) * cos(makkahLatRad)
        let x = cos(userLat) * sin(makkahLatRad) - sin(userLat) * cos(makkahLatRad) * cos(dLon)
        
        var bearing = atan2(y, x) * 180 / .pi
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)
        
        qiblaDirection = bearing
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy >= 0 {
            heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        }
    }
}
