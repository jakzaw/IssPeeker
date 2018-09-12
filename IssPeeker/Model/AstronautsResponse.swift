//
//  PeopleResponse.swift
//  IssPeeker
//
//  Created by jakzaw on 11/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import Foundation

struct AstronautsResponse: Codable {
    let message : String
    let people : [Person]
    let number : Int
}
