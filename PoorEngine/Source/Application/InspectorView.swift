//
//  InspectorView.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import SwiftUI

struct InspectorView: View {
    @ObservedObject var op: Options
    
    var body: some View {
        List{
            Text("Inspector").font(.largeTitle).padding(.bottom, 4)
            Section(header: Text("AAAAA")){
                Picker("Draw mode", selection: $op.renderChoice){
                    ForEach(RenderChoice.allCases, id: \.id){choice in
                        Text(choice.name).tag(choice)
                    }
                }
                .pickerStyle(.menu)
            }
            Section(header: Text("BBBBB")){
                
            }
            Section(header: Text("CCCCC")){
                
            }
        }
        
    }
}

