//
//  AutflashMenuViewSUI.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.04.2025.
//

import SwiftUI
import UIKit
import SwiftUIIntrospect

final class AutflashMenuViewModel: ObservableObject {
    var didTapViewHandler: (() -> Void)?
}

struct AutflashMenuViewSUI: View {
    @ObservedObject private var viewModel = AutflashMenuViewModel()
    
    init(viewModel: AutflashMenuViewModel = AutflashMenuViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            List {
                listContent()
            }
            .scrollContentBackground(.hidden)
        } else {
            ios15List()
        }
    }
    
    @ViewBuilder private func listContent() -> some View {
        Section {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text("This functionality is in beta-testing. After being tested it gonna became paid")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .padding([.bottom], 5)
                    .padding([.top], 15)
                Spacer()
                VStack {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding([.trailing], -7)
                        .padding([.top], 8)
                        .foregroundColor(.white.opacity(0.3))
                    Spacer()
                }
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black.opacity(0.1))
            )
        }
        Section(
            footer: Text("Mircophone is used to detect music rhytm and create color flashes")
                .listRowBackground(Color.clear)
        ) {
            HStack {
                Image(systemName: "microphone.fill")
                Text("Microphone status:")
            }
            .listRowBackground(Color.black.opacity(0.1))
            ZStack {
                
                HStack {
                    Text("Not provided (tap to enable)")
                        .foregroundStyle(.red)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.system(.caption).weight(.bold))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                   
                }
                Button("") {
                    print("button")
                }
            }
            .listRowBackground(Color(uiColor: .red).opacity(0.25))
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
            collectionView.backgroundColor = .clear
        }
    }
}

#Preview {
    AutflashMenuViewSUI()
}
