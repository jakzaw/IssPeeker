//
//  PositionResponse.swift
//  IssPeeker
//
//  Created by jakzaw on 11/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import Foundation

struct IssPositionResponse: Codable {
    let message : String
    let iss_position : IssPosition
    let timestamp : Int
}
