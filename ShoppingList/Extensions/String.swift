//
//  String.swift
//  Text
//
//  Created by Jack Finnis on 20/05/2023.
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
