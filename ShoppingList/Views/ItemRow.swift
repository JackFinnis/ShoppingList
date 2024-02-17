//
//  ItemRow.swift
//  ShoppingList
//
//  Created by Jack Finnis on 21/05/2023.
//

import SwiftUI

struct ItemRow: View {
    @EnvironmentObject var storage: StorageVM
    @State var bounce = false
    
    let item: String
    let suggested: Bool
    
    var body: some View {
        let regular = storage.regulars.contains(item)
        let removed = storage.recentlyRemovedItems.contains(item)
        
        HStack(spacing: 0) {
            if suggested {
                Button {
                    storage.addItem(item)
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                }
            } else {
                Button {
                    storage.removeItem(item)
                } label: {
                    Image(systemName: removed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(removed ? .accentColor : Color(.placeholderText))
                        .contentTransition(.symbolEffect(.replace))
                        .font(.title2)
                }
            }
            Text(item)
                .padding(.leading, 15)
            Spacer()
            Button {
                if !regular {
                    bounce.toggle()
                }
                storage.toggleRegular(item)
            } label: {
                Image(systemName: regular ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .symbolEffect(.bounce, value: bounce)
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
        .environmentObject(StorageVM())
    }
}
