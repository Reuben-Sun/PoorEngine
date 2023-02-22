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
        }
    }
}

extension RenderChoice: Identifiable{
    var id: Self {self}
}


class Options: ObservableObject {
    @Published var renderChoice = RenderChoice.shadered
    @Published var drawTriangle = true
    @Published var terrainFill = true
}
