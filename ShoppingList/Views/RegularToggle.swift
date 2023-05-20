//
//  RegularToggle.swift
//  ShoppingList
//
//  Created by Jack Finnis on 21/05/2023.
//

import SwiftUI

struct RegularToggle: View {
    @EnvironmentObject var vm: ViewModel
    
    let item: String
    
    var body: some View {
        Button {
            toggleRegular(item)
        } label: {
            let regular = vm.regulars.contains(item)
            Image(systemName: regular ? "star.fill" : "star")
                .foregroundColor(.yellow)
        }
        .buttonStyle(.borderless)
    }
    
    func toggleRegular(_ item: String) {
        if vm.regulars.contains(item) {
            vm.regulars.removeAll(item)
        } else {
            vm.regulars.append(item)
        }
        Haptics.tap()
    }
}
