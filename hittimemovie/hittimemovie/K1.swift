//
//  K1.swift
//  hittimemovie
//
//  Created by Mobi iOS on 04/11/25.
//

import Foundation
import SwiftUI
@preconcurrency import WebKit
import AdjustWebBridge
import AdjustSdk

struct K1: UIViewRepresentable {
    let k2: URL
    var k3: () -> Void
    var k4: () -> Void

    func makeCoordinator() -> K5 {
        K5(k6: k3, k7: k4)
    }

    func makeUIView(context: Context) -> WKWebView {
        let k8 = WKWebViewConfiguration()
        let k9 = WKWebView(frame: .zero, configuration: k8)
        k9.navigationDelegate = context.coordinator
        k9.uiDelegate = context.coordinator

        let k10 = AdjustBridge()
        k10.loadWKWebViewBridge(k9)

        var k11 = k2
        var k12 = k2.absoluteString

        if k12.hasPrefix("http://") {
            k12 = k12.replacingOccurrences(of: "http://", with: "https://")
        } else if !k12.hasPrefix("https://") {
            k12 = "https://" + k12
        }

        if let k13 = URL(string: k12) {
            k11 = k13
        }

        k9.load(URLRequest(url: k11))
        return k9
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    class K5: NSObject, WKNavigationDelegate, WKUIDelegate {
        var k14: () -> Void
        var k15: () -> Void

        init(k6: @escaping () -> Void, k7: @escaping () -> Void) {
            self.k14 = k6
            self.k15 = k7
        }

        func webView(_ k16: WKWebView, decidePolicyFor k17: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let k18 = k17.request.url,
                  let k19 = k18.scheme?.lowercased() else {
                decisionHandler(.allow)
                return
            }
            if k19 == "error" {
                k14()
                decisionHandler(.cancel)
                return
            }
            
            let k20 = k18.absoluteString.lowercased()
            if !k20.hasPrefix("http"),
               UIApplication.shared.canOpenURL(k18) {
                UIApplication.shared.open(k18, options: [:]) { _ in
                    self.k14()
                }
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ k16: WKWebView, didFail k21: WKNavigation!, withError k22: Error) {
            k14()
        }

        func webView(_ k16: WKWebView, didFailProvisionalNavigation k23: WKNavigation!, withError k24: Error) {
            k14()
        }

        func webView(_ k16: WKWebView, didFinish k25: WKNavigation!) {
            k15()
        }
    }
}
