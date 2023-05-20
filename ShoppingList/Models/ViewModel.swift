//
//  ViewModel.swift
//  ShoppingList
//
//  Created by Jack Finnis on 20/05/2023.
//

import Foundation

@MainActor
class ViewModel: ObservableObject {
    @Storage("items") var items = [String]() { didSet {
        objectWillChange.send()
    }}
    @Storage("regulars") var regulars = [String]() { didSet {
        objectWillChange.send()
    }}
    var suggestions: [String] {
        regulars.filter { !items.contains($0) }
    }
}
