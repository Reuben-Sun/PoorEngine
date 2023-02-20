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
    
    static func createGBufferPassPSO(colorPixelFormat: MTLPixelFormat, options: Options) -> MTLRenderPipelineState {
        let vertexFunction = RHI.library?.makeFunction(name: "vertex_main")
        let fragmentFunction = RHI.library?.makeFunction(name: "fragment_gBuffer")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        pipelineDescriptor.setGBufferPixelFormats()

        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
        pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
        
        pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
        return createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createLightingPassPSO(colorPixelFormat: MTLPixelFormat, options: Options) -> MTLRenderPipelineState {
        let constantValues = createConstanntValue(options: options)
        let vertexFunction = RHI.library?.makeFunction(name: "vertex_quad")
        let fragment = "fragment_tiled_deferredLighting"
        // MARK: makeFunction后面添加constantValues用于开启宏，类似于#pragma keyword?
        let fragmentFunction = try! RHI.library?.makeFunction(name: fragment, constantValues: constantValues)
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        
        pipelineDescriptor.setGBufferPixelFormats()
        //pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
        pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
        
        return createPSO(descriptor: pipelineDescriptor)
    }
    
    static func createConstanntValue(options: Options) -> MTLFunctionConstantValues{
        let contantValues = MTLFunctionConstantValues()
//        var is_sharded = options.renderChoice == .shadered
//        var is_alebdo = options.renderChoice == .albdeo
//        contantValues.setConstantValue(&is_sharded, type: .bool, index: 0)
//        contantValues.setConstantValue(&is_alebdo, type: .bool, index: 1)
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
