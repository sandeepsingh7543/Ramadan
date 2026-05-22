//
//  WebContentLoader.swift
//  Movie Har
//
//  Created by Mobi iOS on 13/02/26.
//


import SwiftUI
@preconcurrency import WebKit
import AdjustWebBridge
import AdjustSdk


struct WebContentLoader: UIViewRepresentable {
    let destinationURL: URL
    var onLoadFailure: () -> Void
    var onLoadSuccess: () -> Void
    
    func makeCoordinator() -> WebViewNavigationCoordinator {
        WebViewNavigationCoordinator(onLoadFailure: onLoadFailure, onLoadSuccess: onLoadSuccess)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webViewConfiguration = WKWebViewConfiguration()
        let webViewInstance = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webViewInstance.navigationDelegate = context.coordinator
        webViewInstance.uiDelegate = context.coordinator

        let adjustBridgeInstance = AdjustBridge()
        adjustBridgeInstance.loadWKWebViewBridge(webViewInstance)

        // URL Normalization
        var processedURL = destinationURL
        var urlString = destinationURL.absoluteString

        if !(urlString.hasPrefix("http://") || urlString.hasPrefix("https://")) {
            urlString = "https://" + urlString
        }
        
        if let normalizedURL = URL(string: urlString) {
            processedURL = normalizedURL
        }

        webViewInstance.load(URLRequest(url: processedURL))
        return webViewInstance
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    /// Coordinator for handling navigation and UI delegation
    class WebViewNavigationCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var onLoadFailure: () -> Void
        var onLoadSuccess: () -> Void
        
        init(onLoadFailure: @escaping () -> Void, onLoadSuccess: @escaping () -> Void) {
            self.onLoadFailure = onLoadFailure
            self.onLoadSuccess = onLoadSuccess
        }
        /// Intercepts navigation actions like sms:// or error://
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let requestURL = navigationAction.request.url, let urlScheme = requestURL.scheme?.lowercased() else {
                decisionHandler(.allow)
                return
            }
            
            // Static error scheme triggers fail
            if urlScheme == "error" {
                onLoadFailure()
                decisionHandler(.cancel)
                return
            }
            
            // Dynamically handle non-http(s) schemes
            let requestURLString = requestURL.absoluteString.lowercased()
            let canHandleURL = UIApplication.shared.canOpenURL(requestURL)
            
            if !requestURLString.hasPrefix("http") && canHandleURL {
                UIApplication.shared.open(requestURL, options: [:]) { _ in
                    self.onLoadFailure()
                }
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }

         func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let code = (error as NSError).code
            if code == NSURLErrorCancelled {
                print("Ignore -999 on didFail")
            } else{
                onLoadFailure()
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let code = (error as NSError).code
            if code == NSURLErrorCancelled {
                print("Ignore -999 on didFailProvisionalNavigation")
            } else{
                onLoadFailure()
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            onLoadSuccess()
        }
    }
}