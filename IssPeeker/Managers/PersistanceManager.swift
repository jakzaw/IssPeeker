//
//  DataProvider.swift
//  IssPeeker
//
//  Created by jakzaw on 11/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import Foundation

enum PersistanceError : Error {
    case dataIsCorrupted
}

protocol PersistanceManagerProtocol {
    func saveIssPositionResponse(issPositionResponseWrapped: DateWrapper<IssPositionResponse>) throws
    func getIssPositionResponse() throws -> DateWrapper<IssPositionResponse>
    func saveAstronautsResponse(astronautsResponseWrapped: DateWrapper<AstronautsResponse>) throws
    func getAstronautsResponse() throws -> DateWrapper<AstronautsResponse>
}

class PersistanceManager : PersistanceManagerProtocol {
    private enum UserDefaultsKeys : String {
        case issPosition
        case astronauts
    }
    
    func saveIssPositionResponse(issPositionResponseWrapped: DateWrapper<IssPositionResponse>) throws {
        try self.save(object: issPositionResponseWrapped, key: UserDefaultsKeys.issPosition)
    }
    
    func getIssPositionResponse() throws -> DateWrapper<IssPositionResponse> {
        return try self.get(objectType: DateWrapper<IssPositionResponse>.self, key: UserDefaultsKeys.issPosition)
    }
    
    func saveAstronautsResponse(astronautsResponseWrapped: DateWrapper<AstronautsResponse>) throws {
        try self.save(object: astronautsResponseWrapped, key: UserDefaultsKeys.astronauts)
    }
    
    func getAstronautsResponse() throws -> DateWrapper<AstronautsResponse> {
        return try self.get(objectType: DateWrapper<AstronautsResponse>.self, key: UserDefaultsKeys.astronauts)
    }
    
    private func save<T : Codable>(object : T, key: UserDefaultsKeys) throws {
        let encoded = try JSONEncoder().encode(object)
        UserDefaults.standard.set(encoded, forKey: key.rawValue)
    }

    private func get<T : Codable>(objectType : T.Type, key: UserDefaultsKeys) throws -> T {
        if let data = UserDefaults.standard.data(forKey: key.rawValue) {
            return try JSONDecoder().decode(objectType, from: data)
        }
        else {
            throw PersistanceError.dataIsCorrupted
        }
    }
}
