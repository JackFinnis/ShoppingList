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
    
    func clearable(text: Binding<String>) -> some View {
        self
            .padding(.trailing, 25)
            .overlay(alignment: .trailing) {
                ClearButton(text: text)
            }
    }
}

struct ClearButton: View {
    @Binding var text: String
    
    var body: some View {
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
