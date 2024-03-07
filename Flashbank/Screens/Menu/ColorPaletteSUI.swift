//
//  ColorPaletteSUI.swift
//  Flashbank
//
//  Created by Dmytro Ostapchenko on 04.03.2024.
//

import SwiftUI

final class ColorPaletteSUIState: ObservableObject {
    init() {}
    
    @Published private(set) var colors: [NamedColor] = []
    
    func initalizeColors(_ colors: [NamedColor]) {
        self.colors = colors
    }
    
    func removeColor(_ color: NamedColor) {
        self.colors = colors.filter({ $0.name != color.name })
    }
    
    func addColor(_ color: NamedColor) {
        colors.append(color)
    }
    
    var didTapColor: ((NamedColor) -> Void)?
}

struct ColorPaletteSUI: View {
    init(state: ColorPaletteSUIState) {
        self.state = state
    }
    
    @ObservedObject private var state: ColorPaletteSUIState
    
    var body: some View {
        VStack {
            HStack {
                Text("Available colors")
                    .padding(.top, 25)
                    .padding(.leading, 30)
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.system(size: 14, weight: .regular, design: .default))
                Spacer()
            }
           
            if state.colors.isEmpty {
                ZStack {
                    Color.black
                        .opacity(0.2)
                        .cornerRadius(11)
                    ZStack {
                        Color.black.opacity(0.1)
                            .clipShape(.capsule)
                        Text("Empty")
                            .padding(.all, 7)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .frame(width: 80, height: 10)
                }
                .padding(.bottom, 10)
                
                .animation(.easeInOut, value: state.colors.isEmpty)
            }
            else {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(state.colors, id: \.name, content: { value in
                            Circle()
                                .foregroundStyle(Color(uiColor: value.color))
                                .frame(width: 31, height: 31)
                                .onTapGesture {
                                    self.state.didTapColor?(value)
                                }
                        })
                    }
                    .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                }
                .background(
                    Color.black
                        .opacity(0.2)
                        .cornerRadius(11)
                )
                .padding(.bottom, 10)
                .animation(.easeInOut, value: state.colors)
                .animation(.easeInOut, value: state.colors.isEmpty)
            }
        }
       
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
    ZStack {
        Color.black
            .opacity(0.5)
        ColorPaletteSUI(state: .init())
            
    }
    
        //.frame(width: 150, height: 70)
        
}
