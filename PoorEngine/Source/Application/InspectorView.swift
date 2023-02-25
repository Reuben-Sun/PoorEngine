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
            Section(header: Text("Debug View")){
                Picker("Draw mode", selection: $op.renderChoice){
                    ForEach(RenderChoice.allCases, id: \.id){choice in
                        Text(choice.name).tag(choice)
                    }
                }
                .pickerStyle(.menu)

                Picker("Tone Mapping", selection: $op.tonemappingMode){
                    ForEach(ToneMappingMode.allCases, id: \.id){choice in
                        Text(choice.name).tag(choice)
                    }
                }
                .pickerStyle(.menu)
                
                Toggle("Draw Triangle", isOn: $op.drawTriangle).toggleStyle(.switch)
                
            }
            Section(header: Text("Terrain")){
                Toggle("Terrain Replace Plane", isOn: $op.terrainReplacePlane).toggleStyle(.switch)
                Toggle("Draw GameObject", isOn: $op.drawGameObject).toggleStyle(.switch)
                Toggle("Use Heightmap", isOn: $op.useHeightmap).toggleStyle(.switch)
            }
            Section(header: Text("CCCCC")){
                
            }
        }
        
    }
}

