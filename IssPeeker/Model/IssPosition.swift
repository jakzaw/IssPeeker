//
//  IssPosition.swift
//  IssPeeker
//
//  Created by jakzaw on 11/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import Foundation
import CoreLocation

struct IssPosition : Codable {
    let latitude : String
    let longitude : String
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.latitude = try values.decode(String.self, forKey: .latitude)
        self.longitude = try values.decode(String.self, forKey: .longitude)
    }
}

extension IssPosition {
    var coordinate : CLLocationCoordinate2D? {
        if let lat = Double(self.latitude), let lon = Double(self.longitude) {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        else {
            return nil
        }
    }
    
}
