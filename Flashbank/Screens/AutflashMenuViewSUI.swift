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
    enum MirphoneAccessState {
        case notProvided
        case provided
    }
    
    @Published var mirphoneAccessState: MirphoneAccessState = .notProvided
    @Published var shouldPresentBetatestAlert = true
    @Published var isDebugMenuEnabled: Bool = false
    
    var didTapViewHandler: (() -> Void)?
    var didTapMircophoneAccessButtonHandler: (() -> Void)?
    var didChangeIsDebugMenuEnebled: ((Bool) -> Void)?
    var didCloseAlert: (() -> Void)?
    
    var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var tableViewWidth: CGFloat {
        return min(UIScreen.main.bounds.width / 2, 600)
    }
}

struct AutflashMenuViewSUI: View {
    @StateObject private var viewModel: AutflashMenuViewModel

    init(viewModel: AutflashMenuViewModel = AutflashMenuViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            if viewModel.isIPhone {
                List {
                    listContent()
                }
                .scrollContentBackground(.hidden)
                .animation(.easeInOut, value: viewModel.shouldPresentBetatestAlert)
                .animation(.default, value: viewModel.mirphoneAccessState)
            } else {
                List {
                    listContent()
                }
                .frame(width: viewModel.tableViewWidth)
                .scrollContentBackground(.hidden)
                .animation(.easeInOut, value: viewModel.shouldPresentBetatestAlert)
                .animation(.default, value: viewModel.mirphoneAccessState)
            }
        } else {
            if viewModel.isIPhone {
                ios15List()
                    .animation(.easeInOut, value: viewModel.shouldPresentBetatestAlert)
                    .animation(.default, value: viewModel.mirphoneAccessState)
            } else {
                ios15List()
                    .frame(width: viewModel.tableViewWidth)
                    .animation(.easeInOut, value: viewModel.shouldPresentBetatestAlert)
                    .animation(.default, value: viewModel.mirphoneAccessState)
            }
        }
    }

    @ViewBuilder private func betaTestAlert() -> some View {
        Section {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text("This functionality is in beta-testing. After being tested it gonna became paid")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .padding([.bottom], 5)
                    .padding([.top], 5)
                Spacer()
                VStack {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding([.trailing], -7)
                        .padding([.top], 8)
                        .foregroundColor(.white.opacity(0.3))
                        .onTapGesture {
                            viewModel.shouldPresentBetatestAlert = false
                            viewModel.didCloseAlert?()
                        }
                    Spacer()
                }
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black.opacity(0.25))
            )
        }
    }

    @ViewBuilder private func listContent() -> some View {
        if viewModel.shouldPresentBetatestAlert {
            betaTestAlert()
        }
        Section(
            footer: Text("Microphone is used to detect music rhythm and create color flashes")
        ) {
            HStack {
                Image(systemName: "microphone.fill")
                Text("Microphone status:")
            }
            .listRowBackground(Color.black.opacity(0.25))
            Button {
                self.viewModel.didTapMircophoneAccessButtonHandler?()
            } label: {
                HStack {
                    Text(
                        viewModel.mirphoneAccessState == .notProvided
                            ? "Not provided (tap to enable)"
                            : "Access is provided"
                        
                    )
                    .foregroundStyle(
                        viewModel.mirphoneAccessState == .notProvided
                        ? Color.red
                        : Color.green
                    )
                    Spacer()
                    if viewModel.mirphoneAccessState == .notProvided {
                        Image(systemName: "chevron.forward")
                            .font(.system(.caption).weight(.bold))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                }
            }
            .listRowBackground(
                viewModel.mirphoneAccessState == .notProvided
                    ? Color.red.opacity(0.25)
                    : Color.green.opacity(0.25)
            )
        }
        Section(
            footer: Text("Blue square with extra information inside")
        ) {
            HStack {
                Toggle("Show debug menu", isOn: $viewModel.isDebugMenuEnabled)
                    .onChange(of: viewModel.isDebugMenuEnabled) { newValue in
                        viewModel.didChangeIsDebugMenuEnebled?(newValue)
                    }
            }
            .listRowBackground(Color.black.opacity(0.25))
        }
    }

    @ViewBuilder private func ios15List() -> some View {
        List {
            listContent()
        }
        .listStyle(.insetGrouped)
        .introspect(.list, on: .iOS(.v13, .v14, .v15)) { tableView in
            tableView.backgroundColor = .clear//.black.withAlphaComponent(0.4)
        }
        .introspect(.list, on: .iOS(.v16, .v17, .v18)) { collectionView in
            collectionView.backgroundColor = .clear
        }
    }
}

#Preview {
    AutflashMenuViewSUI()
}
