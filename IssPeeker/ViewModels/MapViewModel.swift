//
//  MapViewModel.swift
//  IssPeeker
//
//  Created by jakzaw on 11/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import MapKit

protocol MapViewModelProtocol {
    var centerMap : Driver<CLLocationCoordinate2D> { get }
    var issPosition : Driver<CLLocationCoordinate2D> { get }
    var astronauts : Driver<String> { get }
    var positionSyncDate : Driver<String> { get }
    var astronautsSyncDate : Driver<String> { get }
}

class MapViewModel : MapViewModelProtocol {
    private let disposeBag = DisposeBag()
    private let dataProvider : MapDataProviderProtocol
    
    let centerMap : Driver<CLLocationCoordinate2D>
    let issPosition : Driver<CLLocationCoordinate2D>
    let astronauts : Driver<String>
    let positionSyncDate : Driver<String>
    let astronautsSyncDate : Driver<String>
    
    init(dataProvider: MapDataProviderProtocol) {
        self.dataProvider = dataProvider
        
        self.centerMap = self.dataProvider.issPosition.map{ $0?.value.iss_position.coordinate }.filterNil().take(1).asDriver(onErrorDriveWith: Driver.never())
        self.issPosition = self.dataProvider.issPosition.asDriver().map{ $0?.value.iss_position.coordinate }.filterNil()
        self.astronauts = self.dataProvider.astronauts.asDriver().map{ $0?.value.people.map{ $0.name }.joined(separator: ", ") }.filterNil()
        
        //create formatter here to avoid its recreation in .map blocks
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        self.positionSyncDate = self.dataProvider.issPosition.asDriver().map{ position -> String in
            let dateString = (position.map{ dateFormatter.string(from: $0.date) } ?? "never")
            return "position synced: " + dateString
        }
        
        self.astronautsSyncDate = self.dataProvider.astronauts.asDriver().map{ position -> String in
            let dateString = (position.map{ dateFormatter.string(from: $0.date) } ?? "never")
            return "astronauts synced: " + dateString
        }
    }
}

