//
//  EpisodeListViewModel.swift
//  Z1App
//
//  Created by Antonio Calvo Elorri on 11/10/22.
//

import Foundation
import RickMortySwiftApi

@MainActor
public class EpisodeListViewModel: BaseViewModel, LoadableObject {

	@Published public var episodes: [RMEpisodeModel] = []
	@Published public var state: LoadingState<[RMEpisodeModel]> = .idle

	public func load() async {
		do {
			state = .loading
			let rmClient = RMClient()
			episodes = try await rmClient.episode().getAllEpisodes()
			state = .loaded(episodes)
		} catch {
			state = .failed(error)
		}
	}
}
