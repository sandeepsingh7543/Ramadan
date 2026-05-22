//
//  AdManager.swift
//  Movie Har
//
//  Created by Mobi iOS on 13/02/26.
//


import Foundation
import SwiftUI
import UIKit
import UnityAds

class AdManager {
    
    // MARK: - Root ViewController Helper
    private static var rootViewController: UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootVC
    }
    
    // MARK: - Show Rewarded Ad
    public static func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard let rootVC = rootViewController else {
            completion(false)
            return
        }
        
        if UnityManager.shared.isRewardedAdReady() {
            UnityManager.shared.onRewardedClose = completion
            UnityAds.show(rootVC, placementId: UnityManager.shared.rewardedVideoPlacementID, showDelegate: UnityManager.shared)
            UnityManager.shared.isRewardedReady = false
        } else {
            // Safety timeout fallback (ad fail case)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if !UnityManager.shared.isRewardedAdReady() {
                    completion(false)
                }
            }
            // Set callback when ad becomes ready
            UnityManager.shared.onRewardedReady = {
                DispatchQueue.main.async {
                    showRewardedAd(completion: completion)
                }
            }
            UnityManager.shared.loadRewardedAd()
        }
    }
    
    // MARK: - Banner & Interstitial (Optional)
    public static func showBannerAd() {
        guard let rootVC = rootViewController else { return }
        UnityManager.shared.showBannerAd(viewController: rootVC)
    }
    
    public static func showInterstitialAd(completion: @escaping (Bool) -> Void) {
        guard let rootVC = rootViewController else {
            completion(false)
            return
        }
        UnityManager.shared.showInterstitialAds(viewController: rootVC, onClose: completion)
    }
}
