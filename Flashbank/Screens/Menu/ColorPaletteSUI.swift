//
//  ColorPaletteSUI.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 04.03.2024.
//

import SwiftUI

final class ColorPaletteSUIState: ObservableObject {
    init(colors: [UIColor] = []) {
        //self.colors = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .black, .green]
        self.colors = [
            .init(name: "1", color: .green)
        ]
    }
    
    @Published 
    var colors: [NamedColor]
}

struct ColorPaletteSUI: View {
    init(state: ColorPaletteSUIState) {
        self.state = state
    }
    
    @ObservedObject private var state: ColorPaletteSUIState
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(state.colors, id: \.name, content: { value in
                    Circle()
                        .foregroundStyle(Color(uiColor: value.color))
                        .frame(width: 35, height: 35)
                })
                .onTapGesture {
                    state.colors.append(.init(name: String((0 ... 1000).randomElement() ?? 0), color: .systemBlue))
                }
            }
            .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
        }
        .background(
            Color.black
                .opacity(0.2)
                .cornerRadius(11)
        )
        .padding(.bottom, 10)
        .padding(.top, 10)
    }
    
    /*
    private let rows = [
        GridItem(.fixed(50)),
        GridItem(.fixed(50))
    ]
    
    private let columns = [
        GridItem(.adaptive(minimum: 25)),  GridItem(.adaptive(minimum: 25)), GridItem(.adaptive(minimum: 25)),GridItem(.adaptive(minimum: 25)),GridItem(.adaptive(minimum: 25)),
    ]

    var body: some View {
        ZStack {
            LazyVGrid(
                columns: columns,
                alignment: .leading,
                content: {
                    ForEach(state.colors, id: \.name, content: { value in
                        Circle()
                            .foregroundStyle(Color(uiColor: value.color))
                    })
                })
            .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(
                Color.black
                    .opacity(0.3)
                    .cornerRadius(15)
            )
            .onTapGesture {
                state.colors.append(.init(name: String((0 ... 1000).randomElement() ?? 0), color: .systemBlue))
            }
        }
    }
     */
}

#Preview {
    ColorPaletteSUI(state: .init())
        //.frame(width: 150, height: 70)
        
}
