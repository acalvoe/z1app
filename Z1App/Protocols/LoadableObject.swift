//
//  LoadableObject.swift
//  Z1App
//
//  Created by Antonio Calvo Elorri on 11/10/22.
//

import Foundation

protocol LoadableObject: ObservableObject {

	associatedtype Output

	var showAlert:Bool { get set }
	var errorMessageCode:String { get set }

	@MainActor
	var state: LoadingState<Output> { get set }

	@MainActor
	func load() async
}
