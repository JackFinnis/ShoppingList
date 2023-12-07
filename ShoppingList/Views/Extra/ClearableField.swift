//
//  View.swift
//  ShoppingList
//
//  Created by Jack Finnis on 21/05/2023.
//

import SwiftUI

struct ClearableField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding(.trailing, 25)
            .overlay(alignment: .trailing) {
                if text.isNotEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(.placeholderText))
                    }
                    .buttonStyle(.borderless)
                }
            }
    }
}
