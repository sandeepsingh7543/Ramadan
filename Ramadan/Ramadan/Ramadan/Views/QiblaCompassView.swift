//
//  QiblaCompassView.swift
//  Ramadan
//
//  Created by Mobi iOS on 23/02/26.
//

import SwiftUI
import CoreLocation
import MapKit

struct QiblaCompassView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var motionManager = MotionManager()
    
    @State private var qiblaDirection: Double = 0
    @State private var needsCalibration = false
    @State private var animate = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262),
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                mapBackground
                overlayGradient
                contentView
            }
            .navigationTitle("Qibla Compass")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: setupView)
        .onDisappear(perform: cleanupView)
    }
    
    private var mapBackground: some View {
        Map(coordinateRegion: .constant(region), interactionModes: [], annotationItems: [
            MapPin(coordinate: CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)),
            MapPin(coordinate: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
        ]) { pin in
            MapMarker(coordinate: pin.coordinate, tint: pin.coordinate.latitude == 21.4225 ? .green : .blue)
        }
        .ignoresSafeArea()
        .blur(radius: 2)
    }
    
    private var overlayGradient: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0.7),
                Color.black.opacity(0.5),
                Color.black.opacity(0.7)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var contentView: some View {
        if locationManager.authorizationStatus == .notDetermined {
            locationPromptView
        } else if needsCalibration {
            calibrationView
        } else {
            compassView
        }
    }
    
    private func setupView() {
        locationManager.requestPermission()
        motionManager.startUpdating()
        motionManager.onLocationUpdate = { location in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                qiblaDirection = QiblaCalculator.calculateQiblaDirection(from: location.coordinate)
                region.center = location.coordinate
            }
        }
        motionManager.onAccuracyUpdate = { accuracy in
            needsCalibration = accuracy < 0
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            animate = true
        }
    }
    
    private func cleanupView() {
        motionManager.stopUpdating()
    }
    
    private var locationPromptView: some View {
        VStack(spacing: AppSpacing.xxl) {
            ZStack {
                Circle()
                    .fill(AppColors.success.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.success)
            }
            .scaleEffect(animate ? 1 : 0.8)
            .opacity(animate ? 1 : 0)
            
            VStack(spacing: AppSpacing.sm) {
                Text("Location Access Needed")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Enable location to find accurate Qibla direction")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button(action: { locationManager.requestPermission() }) {
                Text("Enable Location")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [AppColors.success, AppColors.success.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(AppCornerRadius.xl)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    private var calibrationView: some View {
        VStack(spacing: AppSpacing.xxl) {
            ZStack {
                Circle()
                    .fill(AppColors.warning.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.warning)
            }
            
            VStack(spacing: AppSpacing.sm) {
                Text("Compass Calibration")
                    .font(.title2.bold())
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Move your device in a figure-8 pattern")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
    
    private var compassView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            ZStack {
                compassCircle
                compassNeedle
                centerDot
            }
            .frame(width: 280, height: 280)
            .scaleEffect(animate ? 1 : 0.8)
            .opacity(animate ? 1 : 0)
            
            Spacer()
            
            directionCard
                .padding(.bottom, 40)
        }
        .padding()
    }
    
    private var compassCircle: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: AppColors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
            
            ForEach(0..<4, id: \.self) { i in
                let directions = ["N", "E", "S", "W"]
                let colors: [Color] = [.red, .white.opacity(0.6), .white.opacity(0.6), .white.opacity(0.6)]
                Text(directions[i])
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(colors[i])
                    .offset(y: -110)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
            
            ForEach(0..<36, id: \.self) { i in
                Rectangle()
                    .fill(i % 3 == 0 ? Color.white.opacity(0.5) : Color.white.opacity(0.2))
                    .frame(width: 1.5, height: i % 3 == 0 ? 15 : 8)
                    .offset(y: -125)
                    .rotationEffect(.degrees(Double(i) * 10))
            }
        }
        .frame(width: 280, height: 280)
        .rotationEffect(.degrees(-motionManager.heading))
        .animation(.spring(response: 0.3, dampingFraction: 0.9), value: motionManager.heading)
    }
    
    private var compassNeedle: some View {
        ZStack {
            Image("Arrow")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 120)
                .shadow(color: AppColors.success.opacity(0.6), radius: 20)
                .offset(y: -60)
        }
        .rotationEffect(.degrees(qiblaDirection))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: qiblaDirection)
    }
    
    private var centerDot: some View {
        Circle()
            .fill(AppColors.textPrimary)
            .frame(width: 12, height: 12)
            .shadow(color: AppColors.textPrimary.opacity(0.5), radius: 5)
    }
    
    private var directionCard: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.xxl) {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "location.north.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.success)
                    
                    Text("\(Int(qiblaDirection))°")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("to Kaaba")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                
                if let location = locationManager.location {
                    Divider()
                        .background(AppColors.textPrimary.opacity(0.3))
                        .frame(height: 80)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(AppColors.success)
                            Text("Your Location")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Text(String(format: "%.4f°", location.coordinate.latitude))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(String(format: "%.4f°", location.coordinate.longitude))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.xxl)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.xxl)
                            .stroke(AppColors.textPrimary.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: AppColors.primary.opacity(0.3), radius: 20, x: 0, y: 8)
        }
        .padding(.horizontal)
        .opacity(animate ? 1 : 0)
    }
}

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

class MotionManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var heading: Double = 0
    @Published var magneticAccuracy: CLLocationAccuracy = 0
    
    var onLocationUpdate: ((CLLocation) -> Void)?
    var onAccuracyUpdate: ((CLLocationAccuracy) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func startUpdating() {
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
}

extension MotionManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        magneticAccuracy = newHeading.headingAccuracy
        onAccuracyUpdate?(newHeading.headingAccuracy)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            onLocationUpdate?(location)
        }
    }
}
