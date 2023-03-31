//
//  Pawn.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/3/27.
//

import Foundation

class Pawn: GameObject {
    override init(name: String, meshName: String, exten: String = "obj"){
        super.init(name: name, meshName: meshName, exten: exten)
    }
    
    func move(camera: Camera){
        
        var forwardVector: float3 {
            //这个坐标系，y轴是垂直地面的，z轴向前，x轴向右
            normalize([sin(camera.rotation.y), 0, cos(camera.rotation.y)])
        }
        /// 水平向右
        var rightVector: float3 {
            [forwardVector.z, 0, -forwardVector.x]
        }
        
        let moveSpeed: Float = 0.1
        
        let input = InputController.shared
        
        if input.keysPressed.contains(.leftArrow){
            model.transform.position -= rightVector * moveSpeed
        }
        if input.keysPressed.contains(.rightArrow){
            model.transform.position += rightVector * moveSpeed
        }
        if input.keysPressed.contains(.upArrow){
            model.transform.position += forwardVector * moveSpeed
        }
        if input.keysPressed.contains(.downArrow){
            model.transform.position -= forwardVector * moveSpeed
        }
        
    }
}
