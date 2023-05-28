//
//  ViewModel.swift
//  ShoppingList
//
//  Created by Jack Finnis on 20/05/2023.
//

import Foundation

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
        setupStorage()
    }
    
    func setupStorage() {
        NotificationCenter.default.addObserver(self, selector: #selector(receivedNewKeyValue), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        guard NSUbiquitousKeyValueStore.default.synchronize() else {
            fatalError()
        }
    }
    
    @objc
    func receivedNewKeyValue(_ notification: Notification) {
        DispatchQueue.main.async {
            if let items = NSUbiquitousKeyValueStore.default.object(forKey: "items") as? [String] {
                self.items = items
            }
            if let regulars = NSUbiquitousKeyValueStore.default.object(forKey: "regulars") as? [String] {
                self.regulars = regulars
            }
        }
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
        Haptics.tap()
    }
    
    func emptyList() {
        recentlyRemovedItems.append(contentsOf: items)
        items.removeAll()
        Haptics.success()
    }
    
    func toggleRegular(_ item: String) {
        if regulars.contains(item) {
            regulars.removeAll(item)
        } else {
            regulars.append(item)
        }
        Haptics.tap()
    }
    
    func addItem(_ item: String) {
        items.append(item)
        recentlyRemovedItems.removeAll(item)
    }
    
    func removeItem(_ item: String) {
        guard !recentlyRemovedItems.contains(item) else { return }
        recentlyRemovedItems.append(item)
        Haptics.tap()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.items.removeAll(item)
        }
    }
}
