//
//  ViewModel.swift
//  ShoppingList
//
//  Created by Jack Finnis on 20/05/2023.
//

import SwiftUI

@MainActor
class ViewModel: ObservableObject {
    // MARK: - Properties
    @Published var newItem = ""
    @Published var recentlyRemovedItems = [String]()
    
    @Storage("items", iCloudSync: true) var items = [String]() { didSet {
        objectWillChange.send()
    }}
    @Storage("regulars", iCloudSync: true) var regulars = [String]() { didSet {
        objectWillChange.send()
    }}
    var suggestions: [String] {
        regulars.filter { !items.contains($0) }.sorted()
    }
    
    // MARK: - Initialiser
    init() {
        setupiCloudStorage()
    }
    
    func setupiCloudStorage() {
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudStorageDidChange), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    @objc
    func iCloudStorageDidChange() {
        objectWillChange.send()
    }
    
    // MARK: - Methods
    func addNewItem() -> Bool {
        defer {
            newItem = ""
        }
        let trimmed = newItem.trimmed
        guard trimmed.isNotEmpty else { return false }
        if !items.contains(trimmed) {
            addItem(trimmed)
        }
        return true
    }
    
    func undoRemove() {
        guard let item = recentlyRemovedItems.popLast() else { return }
        items.append(item)
    }
    
    func emptyList() {
        recentlyRemovedItems.append(contentsOf: items)
        items.removeAll()
    }
    
    func toggleRegular(_ item: String) {
        if regulars.contains(item) {
            regulars.removeAll(item)
        } else {
            regulars.append(item)
            Haptics.tap()
        }
    }
    
    func addItem(_ item: String) {
        recentlyRemovedItems.removeAll(item)
        if !items.contains(item) {
            items.append(item)
        }
    }
    
    func addAllSuggestions() {
        suggestions.forEach { suggestion in
            addItem(suggestion)
        }
    }
    
    func removeItem(_ item: String) {
        guard !recentlyRemovedItems.contains(item) else { return }
        recentlyRemovedItems.append(item)
        Haptics.tap()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.items.removeAll(item)
        }
    }
    
    func copyList() {
        UIPasteboard.general.string = items.joined(separator: "\n")
        Haptics.tap()
    }
}
