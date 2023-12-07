//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Jack Finnis on 20/05/2023.
//

import SwiftUI

@main
struct ShoppingListApp: App {
    @StateObject var vm = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ShoppingList()
                .fontDesign(.rounded)
        }
        .environmentObject(vm)
    }
}
