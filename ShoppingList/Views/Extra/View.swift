//
//  View.swift
//  ShoppingList
//
//  Created by Jack Finnis on 21/05/2023.
//

import SwiftUI

extension View {
    func horizontallyCentred() -> some View {
        HStack {
            Spacer(minLength: 0)
            self
            Spacer(minLength: 0)
        }
    }
}
