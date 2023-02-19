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
            Text("Setting").font(.largeTitle).padding(.bottom, 8)
            Section(header: Text("AAAAA")){
                Picker("Select Option", selection: $op.renderPath){
                    ForEach(RenderPath.allCases, id: \.id){path in
                        Text(path.name).tag(path)
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

