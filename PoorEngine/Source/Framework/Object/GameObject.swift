//
//  GameObject.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

class GameObject {
    let name: String
    let meshName: String
    let meshExten: String
    var model: Model
    var tag: GameObjectTag
    
    init(name: String, meshName: String, exten: String = "obj"){
        self.name = name
        self.meshName = meshName
        self.meshExten = exten
        self.model = Model(name: meshName, exten: exten)
        self.tag = .opaque
    }
}

enum GameObjectTag: String {
    case opaque = "opaque"
    case ground = "ground"
}
