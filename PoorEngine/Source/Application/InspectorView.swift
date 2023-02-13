//
//  InspectorView.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import SwiftUI

struct InspectorView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct InspectorView_Previews: PreviewProvider {
    static var previews: some View {
        InspectorView()
    }
}
