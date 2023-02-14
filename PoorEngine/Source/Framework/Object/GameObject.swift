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
    
    init(name: String, meshName: String){
        self.name = name
        self.meshName = meshName
    }
    
}
