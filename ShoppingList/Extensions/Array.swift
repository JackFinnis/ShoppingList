//
//  Array.swift
//  ShoppingList
//
//  Created by Jack Finnis on 20/05/2023.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeAll(_ value: Element) {
        removeAll { $0 == value }
    }
}
