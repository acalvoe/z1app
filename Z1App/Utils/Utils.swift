//
//  Utils.swift
//  Z1App
//
//  Created by Antonio Calvo Elorri on 12/10/22.
//

import Foundation

var localeIdentifier = NSLocale.current.identifier

func getFormattedDate(_ strDate: String, format: DateFormatter.Style = .medium, identifier: String = localeIdentifier) -> String {
	let dateFormatter = DateFormatter()
	dateFormatter.locale = Locale(identifier: "en_US")
	dateFormatter.dateFormat = "MMMM d, yyyy"
	let date = dateFormatter.date(from: strDate) ?? Date.now
	dateFormatter.dateStyle = format
	if identifier.replacingOccurrences(of: "-", with: "_") != dateFormatter.locale.identifier {
		dateFormatter.locale = Locale(identifier: identifier)
	}
	return dateFormatter.string(from: date)
//	return date.formatted(date: format, time: .omitted).localizedCapitalized
}
