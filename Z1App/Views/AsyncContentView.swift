//
//  AsyncContentView.swift
//  Z1App
//
//  Created by Antonio Calvo Elorri on 11/10/22.
//

import Foundation
import SwiftUI

struct AsyncContentView<Source: BaseViewModel & LoadableObject, Content: View>: View {
	public init(source: Source, content: @escaping (Source.Output) -> Content) {

		self.source = source
		self.content = content
	}

	@ObservedObject private var source: Source
	var content: (Source.Output) -> Content
	@State private var showAlert = false

	public var body: some View {
		switch source.state {
		case .idle:
			Color.clear
				.onAppear {
				Task{
					await source.load()
				}

			}
		case .loading:
			ProgressView()

		case let .failed(error):
			Color.clear
				.onAppear {
					showAlert = true
				}
				.alert(isPresented: $showAlert) {
					Alert(title: Text("Se ha producido un error"),
						  message: Text(String(describing: error)),
						  dismissButton: .default(Text("Aceptar"), action: { exit(EXIT_FAILURE) }))
				}
		case let .loaded(output):
			content(output)
				.alert(isPresented: $source.showAlert) {
					Alert(title: Text("Se ha producido un error"),
						  message: Text("No se ha podido cargar la información solicitada"),
						  dismissButton: .default(Text("Aceptar"), action: { exit(EXIT_FAILURE) }))
				}
		}
	}
}

