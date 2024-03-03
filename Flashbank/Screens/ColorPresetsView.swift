//
//  ColorPresetsView.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 03.03.2024.
//

import SwiftUI
import UIKit

class ColorPresetsState: ObservableObject {
    var selectedColorPreset: (([UIColor]) -> Void)? = nil
}

struct ColorPresetsView: View {
    @ObservedObject private var state = ColorPresetsState()
    typealias ColorPreset = [UIColor]
    private var colorPresets: [String: ColorPreset] = [
        "RGB": [.red, .blue, .green]
    ]
    
    var body: some View {
        List {
            ForEach(
                colorPresets.sorted(by: { $0.key < $1.key }),
                id: \.key
            ) { key, value in
                Button(key) {
                    state.selectedColorPreset?(value)
                }
            }
        }
    }
}

#Preview {
    ColorPresetsView()
}
