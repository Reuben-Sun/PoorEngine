//
//  ContentView.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import SwiftUI

let size: CGFloat = 150

struct MainView: View {
    @StateObject var options: Options = Options()
    var body: some View {
        HStack{
            VStack{
                SceneView(options: options).frame(width:    size * 4, height: size * 3).border(Color.black, width: 2)
                
                ContentView().frame(width: size * 4, height: size).border(Color.black, width: 2)
            }
            
            InspectorView(op: options).frame(maxWidth: size * 2, maxHeight: .infinity).border(Color.black, width: 2)
        }
        .padding()
    }
}

struct MainVIew_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

