//
//  ContentView.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import SwiftUI

struct MainView: View {
    @State var options = Options()
    var body: some View {
        HStack{
            SceneView(options: options).frame(width: 400, height: 400).border(Color.black, width: 2)
            InspectorView().frame(width: 200, height: 400).border(Color.black, width: 2)
        }
        .padding()
    }
}

struct MainVIew_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
