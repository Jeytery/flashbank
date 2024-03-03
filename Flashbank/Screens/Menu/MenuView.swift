//
//  MenuView.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 28.02.2024.
//

import SwiftUI
import SwiftUIIntrospect
import UIKit

enum MenuViewOutputEvent {
    case tapAddColor
    case tapAddColorPreset
    case tapRemoveAllColors
}

class MenuViewState: ObservableObject {
    init(
        flashbomb: Flashbomb,
        outputEventHandler: ((MenuViewOutputEvent) -> Void)? = nil 
    ) {
        self.flashbomb = flashbomb
        self.outputEventHandler = outputEventHandler
        self.sliderValue = flashbomb.intensity
        self.colors = flashbomb.colors
    }
    
    var outputEventHandler: ((MenuViewOutputEvent) -> Void)?
    
    @Published fileprivate var flashbomb: Flashbomb
    @Published fileprivate var sliderValue: Double = 0
    @Published fileprivate var colors: [UIColor]
    
    func addColor(_ uiColor: UIColor) {
        colors.append(uiColor)
    }
    
    fileprivate func removeColor(_ uiColor: UIColor) {
        colors = colors.filter({
            uiColor.self == $0.self
        })
    }
}

struct MenuView: View {
    @ObservedObject private var state: MenuViewState
    
    init(state: MenuViewState) {
        self.state = state
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            AppearancesList()
                .navigationTitle("")
        }
    }
    
    @ViewBuilder private func ColorCell(index: Int, uiColor: UIColor) -> some View {
        HStack {
            Text("Color \(index)")
            Spacer()
            Circle()
                .foregroundStyle(Color(uiColor: uiColor))
                .frame(width: 20, height: 20)
        }
    }
    
    @ViewBuilder private func ColorsHeader() -> some View {
        HStack {
            Text("Colors")
            Spacer()
            Button("Edit") {
                
            }
        }
    }
    
    @ViewBuilder private func ApperancesSections() -> some View {
        Section(header: Text("Intensity")) {
            Slider.init(
                value: $state.sliderValue, in: 0 ... 3, step: 0.1)
            HStack {
                Spacer()
                Text(String(format: "%.2f", state.sliderValue))
            }
        }
        Section(header: ColorsHeader()) {
            ForEach.init(state.colors.indices, id: \.self) { index in
                ColorCell(index: index + 1, uiColor: state.colors[index])
            }
            Button("Add color") {
                self.state.outputEventHandler?(.tapAddColor)
            }
            .buttonStyle(.borderless)
            Button("Add colors preset") {
                self.state.outputEventHandler?(.tapAddColorPreset)
            }
            .buttonStyle(.borderless)
            Button("Remove all") {
                self.state.addColor(.white)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.red)
        }
    }
    
    @ViewBuilder private func AppearancesList() -> some View {
        List {
            ApperancesSections()
        }
        .introspect(.list, on: .iOS(.v16, .v17)) { collectionView in
            collectionView.backgroundView = UIView()
            collectionView.subviews.dropFirst(1).first?.backgroundColor = .clear
            collectionView.subviews.dropFirst(2).first?.backgroundColor = .clear
        }
        .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17)) { scrollView in
            scrollView.backgroundColor = .clear
        }
    }
}

#Preview {
    MenuView(state: .init(flashbomb: .init(intensity: 0.5, colors: [.red, .blue]), outputEventHandler: { _ in }))
}
