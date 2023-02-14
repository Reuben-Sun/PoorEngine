//
//  GameObject.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

class GameObject: Transformable {
    var transform = Transform()
    let name: String
    let meshName: String
    let meshExten: String
    
    init(name: String, meshName: String, exten: String = "obj"){
        self.name = name
        self.meshName = meshName
        self.meshExten = exten
    }
    
}
