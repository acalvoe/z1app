//
//  EpisodeDetailViewModel.swift
//  Z1App
//
//  Created by Antonio Calvo Elorri on 12/10/22.
//

import Foundation
import RickMortySwiftApi

@MainActor
public class CharactersViewModel: BaseViewModel, LoadableObject {

	@Published public var state: LoadingState<[String]> = .idle
	var characters: [String] = []
	let urls: [String]

	init(urls: [String]) {
		self.urls = urls
	}

	public func load() async {
		do {
			state = .loading
			let rmClient = RMClient()
			for url in urls {
				let character = try await rmClient.character().getCharacterByURL(url: url)
				if !characters.contains(character.name) {
					characters.append(character.name)
				}
			}
			characters.sort()
			state = .loaded(characters)
		} catch {
			state = .failed(error)
		}
	}
}

