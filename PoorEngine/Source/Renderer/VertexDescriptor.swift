//
//  VertexDescriptor.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/13.
//

import MetalKit

extension MTLVertexDescriptor {
    static var defaultLayout: MTLVertexDescriptor? {
        MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
    }
    static var skyboxLayout: MTLVertexDescriptor? {
        MTKMetalVertexDescriptorFromModelIO(.skyboxLayout)
    }
}

extension MDLVertexDescriptor {
    static var defaultLayout: MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        //顶点坐标
        vertexDescriptor.attributes[Position.index] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: 0,
            bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float3>.stride
        
        //顶点法线
        vertexDescriptor.attributes[Normal.index] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float3>.stride
        vertexDescriptor.layouts[VertexBuffer.index] = MDLVertexBufferLayout(stride: offset)
        
        //uv
        vertexDescriptor.attributes[UV.index] = MDLVertexAttribute(
            name: MDLVertexAttributeTextureCoordinate,
            format: .float2,
            offset: 0,
            bufferIndex: UVBuffer.index)
        vertexDescriptor.layouts[UVBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<float2>.stride)
        
        //color
        vertexDescriptor.attributes[Color.index] = MDLVertexAttribute(
            name: MDLVertexAttributeColor,
            format: .float3,
            offset: 0,
            bufferIndex: ColorBuffer.index)
        vertexDescriptor.layouts[ColorBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        
        //切线
        vertexDescriptor.attributes[Tangent.index] =
        MDLVertexAttribute(
            name: MDLVertexAttributeTangent,
            format: .float3,
            offset: 0,
            bufferIndex: TangentBuffer.index)
        vertexDescriptor.layouts[TangentBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        
        //次切线
        vertexDescriptor.attributes[Bitangent.index] =
        MDLVertexAttribute(
            name: MDLVertexAttributeBitangent,
            format: .float3,
            offset: 0,
            bufferIndex: BitangentBuffer.index)
        vertexDescriptor.layouts[BitangentBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<float3>.stride)
        
        return vertexDescriptor
    }
    
    static var skyboxLayout: MDLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        //顶点坐标
        vertexDescriptor.attributes[Position.index] = MDLVertexAttribute(
            name: MDLVertexAttributePosition,
            format: .float3,
            offset: 0,
            bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float3>.stride
        
        //顶点法线
        vertexDescriptor.attributes[Normal.index] = MDLVertexAttribute(
            name: MDLVertexAttributeNormal,
            format: .float3,
            offset: offset,
            bufferIndex: VertexBuffer.index)
        offset += MemoryLayout<float3>.stride
        
        vertexDescriptor.layouts[VertexBuffer.index] = MDLVertexBufferLayout(stride: offset)
        
        return vertexDescriptor
    }
}

extension Attributes {
  var index: Int {
    return Int(self.rawValue)
  }
}

extension BufferIndices {
  var index: Int {
    return Int(self.rawValue)
  }
}

extension TextureIndices {
    var index: Int {
        return Int(self.rawValue)
    }
}

extension RenderTargetIndices {
    var index: Int {
        return Int(rawValue)
    }
}

