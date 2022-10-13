//
//  BaseViewModel.swift
//  Z1App
//
//  Created by Antonio Calvo Elorri on 11/10/22.
//

import Foundation

public class BaseViewModel: ObservableObject {

	@Published public var showAlert = false
	@Published public var errorMessageCode = "Se ha producido un error"
}
