//
//  RemoteConfigurationManager.swift
//  Ai Photo Editor
//
//  Created by Mobi iOS on 13/02/26.
//


import Foundation
import FirebaseRemoteConfig
import FingerprintPro


class RemoteConfigurationManager: ObservableObject {
    
    @Published var webInterfaceEnabled: Bool? = nil
    @Published var webDestinationURL: URL?
    @Published var configurationInProgress = true
    @Published var userVisitorIdentifier = ""
    @Published var sessionRequestIdentifier = ""
    @Published var completeResponseData = ""
    @Published var lastErrorDescription = ""

    private var firebaseRemoteConfig = RemoteConfig.remoteConfig()
    private var fingerprintClient: (any FingerprintClientProviding)?

    init() {
        let remoteConfigSettings = RemoteConfigSettings()
        remoteConfigSettings.minimumFetchInterval = 0
        firebaseRemoteConfig.configSettings = remoteConfigSettings
        loadRemoteConfigurationData()
    }

    /// Fetch and activate Firebase Remote Config
    func loadRemoteConfigurationData() {
      
        firebaseRemoteConfig.fetchAndActivate { _, configError in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                guard configError == nil else {
                    self.finishConfiguration(enabled: false)
                    return
                }

                let remoteURLPath = self.firebaseRemoteConfig["aiphotoeditor"].stringValue
                let fingerprintAPIKey = self.firebaseRemoteConfig["Fingerprint"].stringValue
                
                guard !remoteURLPath.isEmpty, let targetURL = URL(string: remoteURLPath) else {
                    self.finishConfiguration(enabled: false)
                    return
                }
                
                self.webInterfaceEnabled = true
                self.webDestinationURL = targetURL
                
                if fingerprintAPIKey.isEmpty {
                    self.finishConfiguration(enabled: true)
                } else {
                    self.setupFingerprint(with: fingerprintAPIKey)
                }
            }
        }
    }
    
    private func setupFingerprint(with apiKey: String) {

        let configuration = Configuration(apiKey: apiKey, region: .eu, extendedResponseFormat: true)
        self.fingerprintClient = FingerprintProFactory.getInstance(configuration)
       
        Task { await self.getFingerprintData() }
    }
    
    private func getFingerprintData() async {

        guard let client = fingerprintClient else {
            await MainActor.run { self.finishConfiguration(enabled: true) }
            return
        }
        
        do {
            let response = try await client.getVisitorIdResponse()
            
            await MainActor.run {
                self.userVisitorIdentifier = response.visitorId
                self.sessionRequestIdentifier = response.requestId
                self.completeResponseData = String(describing: response)

                self.enhanceURL()
            }
        } catch {
            await MainActor.run {
                self.lastErrorDescription = error.localizedDescription
                self.finishConfiguration(enabled: true)
            }
        }
    }
    
    private func enhanceURL() {      
        guard let baseURL = webDestinationURL,
              !userVisitorIdentifier.isEmpty,
              !sessionRequestIdentifier.isEmpty,
              var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            finishConfiguration(enabled: true)
            return
        }
        
        var queryItems = components.queryItems ?? []
        queryItems += [
            URLQueryItem(name: "visitorId", value: userVisitorIdentifier),
            URLQueryItem(name: "requestId", value: sessionRequestIdentifier)
        ]
        components.queryItems = queryItems
        
        let finalURL = components.url ?? baseURL
        self.webDestinationURL = finalURL
        
        finishConfiguration(enabled: true)
    }
    
    private func finishConfiguration(enabled: Bool) {
        webInterfaceEnabled = enabled
        configurationInProgress = false
    }
}
