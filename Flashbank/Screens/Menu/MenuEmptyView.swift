//
//  MenuEmptyView.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 29.09.2024.
//

import SwiftUI

struct MenuEmptyView: View {
    var body: some View {
        ZStack {
            Color(uiColor: .black.withAlphaComponent(0.1))
            HStack {
                Image(systemName: "plus")
                    .foregroundStyle(.blue)
                Text("New color")
                    .font(.system(size: 22, weight: .medium, design: .monospaced))
                    .foregroundStyle(.blue)
            }
        }
        .clipShape(.capsule)
    }
}

#Preview {
    MenuEmptyView()
        .frame(width: 200, height: 100, alignment: .center)
}
