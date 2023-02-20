//
//  Pipelines.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import MetalKit

enum PipelineStates {
    static func createPSO(descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState {
        let pipelineState: MTLRenderPipelineState
        do {
            pipelineState = try RHI.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return pipelineState
    }
    
    static func createShadowPassPSO() -> MTLRenderPipelineState {
        let vertexFunction = RHI.library?.makeFunction(name: "vertex_depth")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor = .defaultLayout
        return createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createGBufferPassPSO(colorPixelFormat: MTLPixelFormat, tiled: Bool = false) -> MTLRenderPipelineState {
        //TODO: makeFunction后面添加constantValues，用于debug mode
        let constantValues = createConstanntValue()
        let vertexFunction = RHI.library?.makeFunction(name: "vertex_main")
        let fragmentFunction = try! RHI.library?.makeFunction(name: "fragment_gBuffer", constantValues: constantValues)
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
        
        if tiled {
            pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        }
        pipelineDescriptor.setGBufferPixelFormats()

        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
        pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
        
        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        return createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createLightingPassPSO(colorPixelFormat: MTLPixelFormat, tiled: Bool = false) -> MTLRenderPipelineState {
        let vertexFunction = RHI.library?.makeFunction(name: "vertex_quad")
        let fragment = "fragment_tiled_deferredLighting"
        let fragmentFunction = RHI.library?.makeFunction(name: fragment)
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        
        if tiled {
            pipelineDescriptor.setGBufferPixelFormats()
        }
        //pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
        pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
        
        return createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createConstanntValue() -> MTLFunctionConstantValues{
        let contantValues = MTLFunctionConstantValues()
        var is_sharded = true
        contantValues.setConstantValue(&is_sharded, type: .bool, index: 0)
        
        return contantValues
    }
}

extension MTLRenderPipelineDescriptor {
    func setGBufferPixelFormats() {
        colorAttachments[RenderTarget0.index].pixelFormat = .bgra8Unorm
        colorAttachments[RenderTarget1.index].pixelFormat = .rgba16Float
        colorAttachments[RenderTarget2.index].pixelFormat = .rgba16Float
    }
}
