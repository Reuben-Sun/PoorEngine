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
    
    // 创建常量缓冲
    static func createConstanntValue(options: Options) -> MTLFunctionConstantValues{
        let contantValues = MTLFunctionConstantValues()
        //        var is_sharded = options.renderChoice == .shadered
        //        var is_alebdo = options.renderChoice == .albdeo
        //        contantValues.setConstantValue(&is_sharded, type: .bool, index: 0)
        //        contantValues.setConstantValue(&is_alebdo, type: .bool, index: 1)
        return contantValues
    }
    
    // 创建Compute Shader Pipeline
    static func createComputePSO(function: String) -> MTLComputePipelineState {
        guard let kernel = RHI.library.makeFunction(name: function) else {
            fatalError("Unable to create \(function) PSO")
        }
        let pipelineState: MTLComputePipelineState
        do {
            pipelineState = try RHI.device.makeComputePipelineState(function: kernel)
        } catch {
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
    
    static func createTerrainPSO(colorPixelFormat: MTLPixelFormat) -> MTLRenderPipelineState {
        let vertexFunction = RHI.library?.makeFunction(name: "vertex_terrain")
        let fragmentFunction = RHI.library?.makeFunction(name: "fragment_terrain_gBuffer")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        pipelineDescriptor.setGBufferPixelFormats()
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
        pipelineDescriptor.stencilAttachmentPixelFormat = .depth32Float_stencil8
        //vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
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
