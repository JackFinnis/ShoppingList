//
//  ItemRow.swift
//  ShoppingList
//
//  Created by Jack Finnis on 21/05/2023.
//

import SwiftUI

struct ItemRow: View {
    @EnvironmentObject var vm: ViewModel
    
    let item: String
    let suggested: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if suggested {
                Button {
                    vm.addItem(item)
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
            } else {
                Button {
                    vm.removeItem(item)
                } label: {
                    let removed = vm.recentlyRemovedItems.contains(item)
                    Image(systemName: removed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(removed ? .accentColor : Color(.placeholderText))
                        .font(.title2)
                }
            }
            Text(item)
                .padding(.leading, 15)
            Spacer()
            Button {
                vm.toggleRegular(item)
            } label: {
                let regular = vm.regulars.contains(item)
                Image(systemName: regular ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
            .buttonStyle(.borderless)
        }
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ItemRow(item: "Milk", suggested: true)
        }
        .environmentObject(ViewModel())
    }
}
