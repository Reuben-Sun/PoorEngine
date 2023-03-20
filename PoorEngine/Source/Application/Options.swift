//
//  Options.swift
//  PoorEngine
//
//  Created by 孙政 on 2023/2/14.
//

import Foundation

enum RenderChoice: Int, CaseIterable {
    case shadered
    case normal
    case albdeo
    case metallic
    case roughness
    case ambientOcclusion
    case shininess
    case diffuse
    case specular
    case lightOnly
    case skybox
    
    var name: String{
        switch self{
        case .shadered: return "Shadered"
        case .normal: return "Normal"
        case .albdeo: return "Albedo"
        case .metallic: return "Metallic"
        case .roughness: return "Roughness"
        case .ambientOcclusion: return "AO"
        case .shininess: return "Shininess"
        case .diffuse: return "Diffuse"
        case .specular: return "Specular"
        case .lightOnly: return "LightOnly"
        case .skybox: return "Skybox"
        }
    }
}

enum ToneMappingMode: Int, CaseIterable {
    case none
    case linear
    case filmic
    case luma
    case white
    
    var name: String {
        switch self {
        case .none: return "None"
        case .linear: return "Linear"
        case .filmic: return "Filmic"
        case .luma: return "Luma"
        case .white: return "White"
        }
    }
}

extension RenderChoice: Identifiable{
    var id: Self {self}
}

extension ToneMappingMode: Identifiable {
    var id: Self {self}
}


class Options: ObservableObject {
    @Published var renderChoice = RenderChoice.shadered
    @Published var drawTriangle = true
    @Published var drawGameObject = true
    @Published var drawSkybox = true
    @Published var useHeightmap = true
    @Published var terrainReplacePlane = false
    @Published var tonemappingMode = ToneMappingMode.linear
}
