//
//  AutflashMenuViewSUI.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.04.2025.
//

import SwiftUI

import UIKit
import SwiftUIIntrospect

struct AutflashMenuViewSUI: View {
   
    var body: some View {
        if #available(iOS 16.0, *) {
            List {
                listContent()
            }
            .scrollContentBackground(.hidden)
            .background(Color.black.opacity(0.75))
        } else {
            ios15List()
        }
    }
    
    @ViewBuilder private func listContent() -> some View {
        Section(
            footer: Text("Mircophone is used to detect music rhytm and create color flashes").listRowBackground(Color.clear)
        ) {
            HStack {
                Image(systemName: "microphone.fill")
                Text("Microphone status:")
            }
            .listRowBackground(Color.black.opacity(0.1))
            HStack {
                Button("") {
                    print("123")
                }
                Text("Not provided (tap to enable)")
                    .foregroundStyle(.red)
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(Font.system(.caption).weight(.bold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }
            .listRowBackground(Color(uiColor: .red).opacity(0.1))
        }
    }

    @ViewBuilder private func ios15List() -> some View {
        List {
            listContent()
        }
        .listStyle(.plain)
        .introspect(.list, on: .iOS(.v13, .v14, .v15)) { tableView in
            tableView.backgroundColor = .black.withAlphaComponent(0.4)
        }
        .introspect(.list, on: .iOS(.v16, .v17, .v18)) { collectionView in
            collectionView.backgroundColor = .black.withAlphaComponent(0.4)
        }
    }
}

#Preview {
    AutflashMenuViewSUI()
}
