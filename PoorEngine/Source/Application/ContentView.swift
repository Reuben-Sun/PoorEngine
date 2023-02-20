//
//  ContentView.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import SwiftUI

struct ContentView: View {
    let colors = ["Red", "Green", "Blue"]
    var threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        //TODO: 点击这些Circle后会切换场景、模型
        ScrollView{
            LazyVGrid(columns: threeColumnGrid){
                ForEach((0...6), id: \.self){item in
                    Circle().fill(Color.blue)
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
