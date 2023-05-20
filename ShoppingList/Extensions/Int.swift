//
//  Int.swift
//  ShoppingList
//
//  Created by Jack Finnis on 21/05/2023.
//

import Foundation

extension Int {
    func formatted(singular: String) -> String {
        "\(self) \(singular)\(self == 1 ? "" : "s")"
    }
}
