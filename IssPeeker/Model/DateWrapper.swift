//
//  DateWrapper.swift
//  IssPeeker
//
//  Created by jakzaw on 12/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import Foundation

struct DateWrapper<E : Codable>: Codable {
    let value : E
    let date : Date
    
    init(value: E) {
        self.value = value
        self.date = Date()
    }
}
