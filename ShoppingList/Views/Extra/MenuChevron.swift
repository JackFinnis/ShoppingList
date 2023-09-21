//
//  MenuChevron.swift
//  News
//
//  Created by Jack Finnis on 13/01/2023.
//

import SwiftUI

struct MenuChevron: View {
    var body: some View {
        Image(systemName: "chevron.down.circle.fill")
            .font(.system(size: 15).weight(.heavy))
            .foregroundStyle(.secondary, Color(.tertiarySystemFill))
            .foregroundColor(.primary)
            .imageScale(.large)
    }
}
