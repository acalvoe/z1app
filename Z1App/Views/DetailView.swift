//
//  DetailView.swift
//  Z1App
//
//  Created by Antonio Calvo Elorri on 11/10/22.
//

import SwiftUI
import RickMortySwiftApi

struct DetailView: View {

	let episode: RMEpisodeModel
	@StateObject var viewModel: CharactersViewModel

	init(episode: RMEpisodeModel) {
		self.episode = episode
		_viewModel = StateObject(wrappedValue: CharactersViewModel(urls: episode.characters))
	}

	private var gridItemLayout = [GridItem(.flexible()), GridItem(.flexible())]

	var body: some View {
		AsyncContentView(source: viewModel) { characters in
			VStack(alignment: .leading, spacing: 10) {
				Group {
					HStack {
						Spacer()
						Text(episode.name.uppercased())
							.font(.headline.bold())
							.foregroundColor(.orange)
							.multilineTextAlignment(.center)
							.padding(.vertical, 20)
						Spacer()
					}
						Text("Episodio: ").bold() + Text(episode.episode)
					Text("Fecha de emisión: ").bold() + Text(getFormattedDate(episode.airDate, format: .full))
				}
				.padding(.horizontal)
				Group {
					VStack {
						Text("Personajes")
							.foregroundColor(.black)
							.bold()
							.padding(.vertical, 10)
							.frame(maxWidth: .infinity)
							.background(Color.mint.opacity(0.4).gradient)
							.padding(.vertical, 20)
							.padding(.horizontal)
						ScrollView {
							LazyVGrid(columns: gridItemLayout, spacing: 20) {
								ForEach(characters, id: \.self) {
									Text($0)
										.font(.caption)
										.lineLimit(1)
								}
							}
							.padding(.horizontal)
						}
						Spacer()
					}
				}
			}
			.font(.caption)
			.navigationTitle("Detalles del episodio")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}
