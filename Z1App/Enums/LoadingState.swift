//
//  LoadingState.swift
//  Z1App
//
//  Created by Antonio Calvo Elorri on 11/10/22.
//

import Foundation

public enum LoadingState<Value> {
	case loading
	case loaded(Value)
	case idle
	case failed(Error)
}
