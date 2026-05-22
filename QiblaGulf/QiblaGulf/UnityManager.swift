//
//  UnityManager.swift
//  QiblaGulf
//
//  Created by Mobi iOS on 21/01/26.
//

import Foundation
import SwiftUI
import UnityAds
import UIKit

class UnityManager: NSObject {
    
    static let shared = UnityManager()
    
    // MARK: - Properties
    var gameID: String = ""
    var bannerPlacementID = "Banner_iOS"
    var interstitialPlacementID = "Interstitial_iOS"
    var rewardedVideoPlacementID = "Rewarded_iOS"
    
    var isInitialized = false
    var isInterstitialReady = false
    var isRewardedReady = false
    
    var onRewardedClose: ((Bool) -> Void)?
    var onRewardedReady: (() -> Void)?
    
    func initializeUnityAds(gameID: String) {
        self.gameID = gameID
#if DEBUG
        UnityAds.initialize(gameID, testMode: true, initializationDelegate: self)
#else
        UnityAds.initialize(gameID, initializationDelegate: self)
#endif
    }
    
    // MARK: - Load Ads
    func loadRewardedAd() {
        guard isInitialized else { return }
        UnityAds.load(rewardedVideoPlacementID, loadDelegate: self)
    }
    
    func loadInterstitialAd() {
        guard isInitialized else { return }
        UnityAds.load(interstitialPlacementID, loadDelegate: self)
    }
    
    // MARK: - Show Ads
    func showRewardedAds(viewController: UIViewController, onClose: @escaping (Bool) -> Void) {
        if isRewardedReady {
            onRewardedClose = onClose
            UnityAds.show(viewController, placementId: rewardedVideoPlacementID, showDelegate: self)
            isRewardedReady = false
        } else {
            loadRewardedAd()
            onClose(false)
        }
    }
    
    func showInterstitialAds(viewController: UIViewController, onClose: @escaping (Bool) -> Void) {
        if isInterstitialReady {
            UnityAds.show(viewController, placementId: interstitialPlacementID, showDelegate: self)
            isInterstitialReady = false
            // store onClose if needed
        } else {
            loadInterstitialAd()
            onClose(false)
        }
    }
    
    func showBannerAd(viewController: UIViewController) {
        guard isInitialized else { return }
        let banner = UADSBannerView(placementId: bannerPlacementID, size: CGSize(width: 320, height: 50))
        banner.delegate = self
        viewController.view.addSubview(banner)
        banner.load()
    }
    
    func isRewardedAdReady() -> Bool {
        return isRewardedReady && isInitialized
    }
}

extension UnityManager: UnityAdsInitializationDelegate {
    func initializationComplete() {
        isInitialized = true
        loadRewardedAd()
        loadInterstitialAd()
    }
    
    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        isInitialized = false
    }
}

extension UnityManager: UnityAdsLoadDelegate {
    func unityAdsAdLoaded(_ placementId: String) {
        if placementId == rewardedVideoPlacementID {
            isRewardedReady = true
            onRewardedReady?()
            onRewardedReady = nil
        } else if placementId == interstitialPlacementID {
            isInterstitialReady = true
        }
    }
    
    func unityAdsAdFailed(toLoad placementId: String, withError error: UnityAdsLoadError, withMessage message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if placementId == self.rewardedVideoPlacementID { self.loadRewardedAd() }
            if placementId == self.interstitialPlacementID { self.loadInterstitialAd() }
        }
    }
}

extension UnityManager: UnityAdsShowDelegate {
    func unityAdsShowComplete(_ placementId: String, withFinish state: UnityAdsShowCompletionState) {
        if placementId == rewardedVideoPlacementID {
            onRewardedClose?(true)
            onRewardedClose = nil
            loadRewardedAd()
        } else if placementId == interstitialPlacementID {
            loadInterstitialAd()
        }
    }
    
    func unityAdsShowFailed(_ placementId: String, withError error: UnityAdsShowError, withMessage message: String) {
        if placementId == rewardedVideoPlacementID {
            onRewardedClose?(false)
            onRewardedClose = nil
            loadRewardedAd()
        } else if placementId == interstitialPlacementID {
            loadInterstitialAd()
        }
    }
    
    func unityAdsShowStart(_ placementId: String) {}
    func unityAdsShowClick(_ placementId: String) {}
}

extension UnityManager: UADSBannerViewDelegate {
    func bannerViewDidLoad(_ bannerView: UADSBannerView!) {}
    func bannerViewDidError(_ bannerView: UADSBannerView!, error: UADSBannerError!) {}
}
