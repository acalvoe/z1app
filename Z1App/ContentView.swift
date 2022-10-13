//
//  ContentView.swift
//  Z1App
//
//  Created by Antonio Calvo Elorri on 11/10/22.
//

import SwiftUI

struct ContentView: View {

	@StateObject private var viewModel = EpisodeListViewModel()
	@State private var showWebView = false

	private var url = "https://www.netflix.com/es/title/80014749"

	init() {
		UINavigationBar.appearance().backgroundColor = .magenta.withAlphaComponent(0.8)
		UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
	}

	var body: some View {

		AsyncContentView(source: viewModel) { episodes in
			NavigationStack {
				VStack {
					ZStack(alignment: .bottomTrailing) {
						Image("Banner")
							.resizable()
							.scaledToFit()
						Button {
							showWebView = true
						} label: {
							Text("Ver en Netflix")
								.font(.caption.bold())
								.foregroundColor(.white)
								.padding(7)
								.background(.red)
								.clipShape(RoundedRectangle(cornerRadius: 5))
								.offset(x: -5, y: -5)
						}

					}
					.padding(.bottom, -10)
					List(episodes) { episode in
						NavigationLink(destination: DetailView(episode: episode)) {
							HStack {
								Text(episode.name)
									.lineLimit(1)
									.foregroundColor(Color.init(red: 0.1, green: 0.6, blue: 0.2))
									.fontWeight(.bold)
								Spacer()
								Text(getFormattedDate(episode.airDate))
							}
							.font(.caption)
							.navigationTitle(Text("LISTADO DE EPISODIOS"))
							.navigationBarTitleDisplayMode(.inline)
						}
					}
					.listStyle(.grouped)
				}
				.sheet(isPresented: $showWebView) {
						WebViewContainer(url: url, hasCloseButton: true)
						.presentationDetents([.medium, .large])
				}
			}
			.accentColor(.white)
		}
	}
}
