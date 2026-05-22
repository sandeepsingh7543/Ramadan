//
//  M1.swift
//  QiblaGulf
//
//  Created by Mobi iOS on 21/01/26.
//


import Foundation
import FirebaseRemoteConfig

class M1: ObservableObject {
    @Published var m2: Bool? = nil
    @Published var m3: URL?
    @Published var m4 = true

    private var m5 = RemoteConfig.remoteConfig()

    init() {
        let m6 = RemoteConfigSettings()
        m6.minimumFetchInterval = 0
        m5.configSettings = m6
        m7()
    }

    func m7() {
        m5.fetchAndActivate { [weak self] _, m8 in
            guard let s = self else { return }
            
            s.m4 = true
            
            if let _ = m8 {
                s.m2 = false
                s.m4 = false
                return
            }
            
            let m9 = s.m5["locationwifimap"].stringValue
            let m10 = s.m5["Fingerprint"].stringValue
            
            guard !m9.isEmpty, let m11 = URL(string: m9) else {
                s.m2 = false
                s.m4 = false
                return
            }
            
            if m10.isEmpty {
                DispatchQueue.main.async {
                    s.m3 = m11
                    s.m2 = true
                    s.m4 = false
                }
            } else {
                Task { [weak self] in
                    guard let t = self else { return }
                    
                    let m12 = await t.m13(m14: m11, m15: m10)
                    
                    await MainActor.run {
                        t.m3 = m12
                        t.m2 = true
                        t.m4 = false
                    }
                }
            }
        }
    }

    private func m13(m14: URL, m15: String) async -> URL {
        let (m16, m17) = await Z1.a1(k1: m15)

        guard var m18 = URLComponents(url: m14, resolvingAgainstBaseURL: false) else {
            return m14
        }

        var m19 = m18.queryItems ?? []
        m19 += [
            URLQueryItem(name: "visitorId", value: m16),
            URLQueryItem(name: "requestId", value: m17)
        ]
        m18.queryItems = m19
        
        return m18.url ?? m14
    }
}


import Foundation
import UIKit
import FingerprintPro

class Z1: UIViewController {
    
    static func a1(k1: String) async -> (String, String) {
        let r1: Region = .eu
        
        let c1 = Configuration(
            apiKey: k1,
            region: r1,
            extendedResponseFormat: true
        )
        
        let p1 = FingerprintProFactory.getInstance(c1)
        
        do {
            let x1 = try await p1.getVisitorIdResponse()
            return (x1.visitorId, x1.requestId)
        } catch {
            return ("E1", "E1")
        }
    }
}