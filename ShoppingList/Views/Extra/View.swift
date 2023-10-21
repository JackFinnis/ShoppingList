//
//  View.swift
//  ShoppingList
//
//  Created by Jack Finnis on 21/05/2023.
//

import SwiftUI

extension View {
    func horizontallyCentred() -> some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            self
            Spacer(minLength: 0)
        }
    }
}

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
