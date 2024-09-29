//
//  BPMSliderView.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 29.09.2024.
//

import SwiftUI
import Combine

class BPMSliderViewModel: ObservableObject {
    @Published var sliderValue: Float = 0
}

struct BPMSliderView: View {
    @ObservedObject var viewModel: BPMSliderViewModel
    
    init(viewModel: BPMSliderViewModel = BPMSliderViewModel()) {
        self.viewModel = viewModel
    }
    
    private let mainElementsTextSize: CGFloat = 22
    
    var body: some View {
        HStack {
            Text("BPM")
                .padding(.trailing, 10)
                .font(.system(size: mainElementsTextSize, weight: .medium, design: .monospaced))
                .foregroundStyle(.blue)
            Slider(value: $viewModel.sliderValue, in: 0...255, step: 1, onEditingChanged: {
                _ in
            })
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                    .frame(width: 80, height: 50, alignment: .center)
                    .clipShape(.capsule)
                Text("\(Int(viewModel.sliderValue))")
                    .font(.system(size: mainElementsTextSize, weight: .medium, design: .monospaced))
                    .foregroundStyle(.blue)
            }
            .padding(.leading, 10)
        }
    }
}

#Preview {
    BPMSliderView()
}
