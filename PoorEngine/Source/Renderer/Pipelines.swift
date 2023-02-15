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
    
    static func createShadowPSO() -> MTLRenderPipelineState {
        let vertexFunction = RHI.library?.makeFunction(name: "vertex_depth")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexDescriptor = .defaultLayout
        return createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createGBufferPSO(colorPixelFormat: MTLPixelFormat, tiled: Bool = false) -> MTLRenderPipelineState {
        let vertexFunction = RHI.library?.makeFunction(name: "vertex_main")
        let fragmentFunction = RHI.library?.makeFunction(name: "fragment_gBuffer")
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
    
    static func createSunLightPSO(colorPixelFormat: MTLPixelFormat, tiled: Bool = false) -> MTLRenderPipelineState {
        let vertexFunction = RHI.library?.makeFunction(name: "vertex_quad")
        let fragment = tiled ? "fragment_tiled_deferredSun" : "fragment_deferredSun"
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
    
    static func createPointLightPSO(colorPixelFormat: MTLPixelFormat, tiled: Bool = false) -> MTLRenderPipelineState {
        let vertexFunction = RHI.library?.makeFunction(name: "vertex_pointLight")
        let fragment = tiled ? "fragment_tiled_pointLight" : "fragment_pointLight"
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
        
        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        let attachment = pipelineDescriptor.colorAttachments[0]
        attachment?.isBlendingEnabled = true
        attachment?.rgbBlendOperation = .add
        attachment?.alphaBlendOperation = .add
        attachment?.sourceRGBBlendFactor = .one
        attachment?.sourceAlphaBlendFactor = .one
        attachment?.destinationRGBBlendFactor = .one
        attachment?.destinationAlphaBlendFactor = .zero
        attachment?.sourceRGBBlendFactor = .one
        attachment?.sourceAlphaBlendFactor = .one
        return createPSO(descriptor: pipelineDescriptor)
    }
}

extension MTLRenderPipelineDescriptor {
    func setGBufferPixelFormats() {
        colorAttachments[RenderTarget0.index].pixelFormat = .bgra8Unorm
        colorAttachments[RenderTarget1.index].pixelFormat = .rgba16Float
        colorAttachments[RenderTarget2.index].pixelFormat = .rgba16Float
    }
}

