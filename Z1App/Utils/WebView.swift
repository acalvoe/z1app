//
//  WebView.swift
//  Z1App
//
//  Created by Antonio Calvo Elorri on 13/10/22.
//

import Foundation
import SwiftUI
import WebKit

class WebViewModel: ObservableObject {
	@Published var url: String
	@Published var isLoading = true
	var hasCloseButton = false

	init(url: String = "") {
		self.url = url
	}
}

private struct WebView: UIViewRepresentable {

	@ObservedObject var viewModel: WebViewModel

	let webView = WKWebView()

	func makeCoordinator() -> Coordinator {
#if DEBUG
		print("make coordinator \(viewModel.url)")
#endif
		return Coordinator(viewModel, self)
	}

	class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {

		private var viewModel: WebViewModel
		var parent: WebView

		init(_ viewModel: WebViewModel, _ parent: WebView) {
			self.viewModel = viewModel
			self.parent = parent
			viewModel.isLoading = true
		}

		func download(_ download: WKDownload, decideDestinationUsing
					  response: URLResponse, suggestedFilename: String,
					  completionHandler: @escaping (URL?) -> Void) {

		}

		func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {

			// confirm functionality goes here. THIS CRASHES THE APP
			let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)

			alertController.addAction(UIAlertAction(title: "Continuar", style: .default, handler: { (action) in
				completionHandler(true)
			}))

			alertController.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { (action) in
				completionHandler(false)
			}))

			if let controller = topMostViewController() {
				controller.present(alertController, animated: true, completion: nil)
			}
		}

		func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
			// Set the message as the UIAlertController message
			let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)

			// Add a confirmation action “OK”
			let okAction = UIAlertAction(title: "Continuar", style: .default, handler: { _ in
				// Call completionHandler
				completionHandler()
			}
			)
			alertController.addAction(okAction)
			// Display the NSAlert
			if let controller = topMostViewController() {
				controller.present(alertController, animated: true, completion: nil)
			}
		}

		private func topMostViewController() -> UIViewController? {
			guard let rootController = keyWindow()?.rootViewController else {
				return nil
			}
			return topMostViewController(for: rootController)
		}

		private func keyWindow() -> UIWindow? {
			return UIApplication.shared.connectedScenes
				.filter {$0.activationState == .foregroundActive}
				.compactMap {$0 as? UIWindowScene}
				.first?.windows.filter {$0.isKeyWindow}.first
		}

		private func topMostViewController(for controller: UIViewController) -> UIViewController {
			if let presentedController = controller.presentedViewController {
				return topMostViewController(for: presentedController)
			} else if let navigationController = controller as? UINavigationController {
				guard let topController = navigationController.topViewController else {
					return navigationController
				}
				return topMostViewController(for: topController)
			} else if let tabController = controller as? UITabBarController {
				guard let topController = tabController.selectedViewController else {
					return tabController
				}
				return topMostViewController(for: topController)
			}
			return controller
		}

		// ESTO PERMITE QUE SE PUEDA NAVEGAR A UNA PÁGINA EXTERNA EN EL WEBVIEW
		func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
			if navigationAction.targetFrame == nil {
				webView.load(navigationAction.request)
			}
			return nil
		}

		func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
			if navigationAction.shouldPerformDownload {
				decisionHandler(.download, preferences)
			} else {
				decisionHandler(.allow, preferences)
			}
		}

		func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
			if navigationResponse.canShowMIMEType {
				decisionHandler(.allow)
			} else {
				decisionHandler(.download)
			}
		}

		func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			webView.configuration.websiteDataStore.httpCookieStore.getAllCookies{ cookies in
				for cookie in cookies {
#if DEBUG
					print("COOKIE name: \(cookie.name) domain: \(cookie.domain) value: \(cookie.value)")
#endif
				}
			}
			viewModel.isLoading = false
		}

		//        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
		//
		//            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies{ cookies in
		//                for cookie in cookies {
		//#if DEBUG
		//                    print("COOKIE-- name: \(cookie.name) domain: \(cookie.domain) value: \(cookie.value)")
		//#endif
		//                }
		//            }
		//            decisionHandler(.allow)
		//
		//        }
	}

	//	private let text = "<html><script></script><body><div id='SI' style='display: none'><font size='30'>SI ME VES ES QUE SI</div><div id='NO' style='display: none'><font size='30'>SI ME VES ES QUE NO</div><br><br><button onclick=\"if (confirm('Are you sure you want to save this thing into the database?')) { document.getElementById('SI').style.display = 'block';document.getElementById('NO').style.display = 'none'; } else { document.getElementById('NO').style.display = 'block';document.getElementById('SI').style.display = 'none'; }\" style='font-size: 70px'>Click Me</button></body></html>"

	func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<WebView>) {

	}

	func makeUIView(context: Context) -> UIView {
		webView.navigationDelegate = context.coordinator
		webView.uiDelegate = context.coordinator
		webView.contentMode = .scaleAspectFit
		webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
		let store = WebKit.WKWebsiteDataStore.default()
		store.httpCookieStore.add(OnShiftWKHTTPCookieStoreObserver())
		webView.configuration.websiteDataStore = store
		if let url = URL(string: viewModel.url) {
			var request = URLRequest(url: url)
			request.httpShouldHandleCookies = true
			webView.load(request)
			//			webView.loadHTMLString(text, baseURL: nil)
		}
		return webView
	}
}
class OnShiftWKHTTPCookieStoreObserver: NSObject, WKHTTPCookieStoreObserver {
	@available(iOS 11.0, *)
	func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
#if DEBUG
		print("COOKIE cookiesDidChange")
#endif
		cookieStore.getAllCookies({(cookies: [HTTPCookie]) in
			cookies.forEach({(cookie: HTTPCookie) in
#if DEBUG
				print("COOKIE name: \(cookie.name) domain: \(cookie.domain) value: \(cookie.value)")
#endif
			})
		})
	}
}

struct WebViewContainer: View {
	let url: String
	@ObservedObject var model = WebViewModel()
	@Environment(\.presentationMode) var presentationMode

	init(url: String, hasCloseButton: Bool = false) {
		self.url = url
		model.url = url
		model.hasCloseButton = hasCloseButton
	}

	@ViewBuilder
	private var progressView: some View {
		if model.isLoading {
			ProgressView().frame(maxHeight: .infinity)
		}
	}

	var body: some View {

		VStack(spacing: 0) {
			if model.hasCloseButton {
				HStack {
					Button(action: {
						presentationMode.wrappedValue.dismiss()
					}) {
						Text("Cerrar").padding(.vertical, 5).padding(.horizontal, 15).foregroundColor(.black)
							.overlay(
								RoundedRectangle(cornerRadius: 6)
									.stroke(Color.black, lineWidth: 1)
							)
							.font(.caption)
					}
				}
				.frame(height: 40)
				.padding(.vertical, 10)
			}

			WebView(viewModel: self.model)
				.overlay(progressView)
		}
	}
}

