//
//  TerrainQuad.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/22.
//

import Foundation
import Metal

class Quad: Transformable {
    var transform = Transform()
    var vertexBuffer: MTLBuffer
    
    // mac端最大细分数
    static let maxTessellation: Int = 64
    
    init() {
        vertexBuffer =  RHI.device.makeBuffer(bytes: vertices,
                                              length: MemoryLayout<float3>.stride * vertices.count, options: [])!
    }
    let vertices: [float3] = [
        [-1,  0,  1],
        [ 1,  0, -1],
        [-1,  0, -1],
        [-1,  0,  1],
        [ 1,  0,  1],
        [ 1,  0, -1]
    ]
}

extension Quad {
    static func createControlPoints(patches: (horizontal: Int, vertical: Int),
                            size: (width: Float, height: Float)
    )->[float3]{
        var points: [float3] = []
        
        let width = 1 / Float(patches.horizontal)
        let height = 1 / Float(patches.vertical)
        for i in 0..<patches.vertical {
            let row = Float(i)
            for j in 0..<patches.horizontal {
                let column = Float(j)
                
                let left = width * column
                let bottom = height * row
                let right = left + width
                let top = bottom + height
                
                points.append([left, 1, top])
                points.append([right, 1, top])
                points.append([right, 1, bottom])
                points.append([left, 1, bottom])
            }
        }
        
        points = points.map {
            [
                $0.x * size.width - size.width / 2,
                0,
                $0.z * size.height - size.height / 2
            ]
        }
        
        return points
    }
}
