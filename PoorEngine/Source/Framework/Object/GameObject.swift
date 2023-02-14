//
//  GameObject.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

class GameObject: Transformable {
    var transform = Transform()
    let objectId: UInt32
    let name: String
    
    init(name: String, objectId: UInt32 = 0){
        self.name = name
        self.objectId = objectId
    }
    
}
