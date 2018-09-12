//
//  MapDataProvider.swift
//  IssPeeker
//
//  Created by jakzaw on 12/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

import Foundation

protocol MapDataProviderProtocol {
    var issPosition : BehaviorRelay<DateWrapper<IssPositionResponse>?> { get }
    var astronauts : BehaviorRelay<DateWrapper<AstronautsResponse>?> { get }
}

class MapDataProvider : MapDataProviderProtocol {
    private let disposeBag = DisposeBag()
    private let networkManager : NetworkManagerProtocol
    private let persistanceManager : PersistanceManagerProtocol
    private let refreshInterval : Double
    
    let issPosition : BehaviorRelay<DateWrapper<IssPositionResponse>?>
    let astronauts : BehaviorRelay<DateWrapper<AstronautsResponse>?>
    
    init(networkManager: NetworkManagerProtocol, persistanceManager: PersistanceManagerProtocol, refreshInterval: Double) {
        self.networkManager = networkManager
        self.persistanceManager = persistanceManager
        self.refreshInterval = refreshInterval
        
        let issPositionFromDisk = try? self.persistanceManager.getIssPositionResponse()
        self.issPosition = BehaviorRelay<DateWrapper<IssPositionResponse>?>(value: issPositionFromDisk)
        
        let astronautsFromDisk = try? self.persistanceManager.getAstronautsResponse()
        self.astronauts = BehaviorRelay<DateWrapper<AstronautsResponse>?>(value: astronautsFromDisk)
        
        let refreshTrigger = Observable<Int>.intervalWithInstantInitialValue(self.refreshInterval, scheduler: MainScheduler.instance)

        let newIssPositionFromAPI = self.obtainAndWrapOnRefresh(refreshTrigger: refreshTrigger, networkRequest: { [weak self] in return self?.networkManager.getIssPosition().asObservable() })
        newIssPositionFromAPI.subscribe(onNext: { [weak self] issPositionResponseWrapped in
            try? self?.persistanceManager.saveIssPositionResponse(issPositionResponseWrapped: issPositionResponseWrapped)
        }).disposed(by: self.disposeBag)
        newIssPositionFromAPI.bind(to: self.issPosition).disposed(by: self.disposeBag)
        
        let newAstronautsFromApi = self.obtainAndWrapOnRefresh(refreshTrigger: refreshTrigger, networkRequest: { [weak self] in return self?.networkManager.getAstronauts().asObservable() })
        newAstronautsFromApi.subscribe(onNext: { [weak self] astronautsResponseWrapped in
            try? self?.persistanceManager.saveAstronautsResponse(astronautsResponseWrapped: astronautsResponseWrapped)
        }).disposed(by: self.disposeBag)
        newAstronautsFromApi.bind(to: self.astronauts).disposed(by: self.disposeBag)
    }
    
    private func obtainAndWrapOnRefresh<T : Codable, I : FixedWidthInteger>(refreshTrigger: Observable<I>, networkRequest: @escaping (() -> Observable<T>?) ) -> Observable<DateWrapper<T>> {
        return refreshTrigger
            .flatMapFirst({ _ -> Observable<T?> in
                return networkRequest()?.mapErrorToNil() ?? Observable.just(nil)
            })
            .filterNil()
            .map{ DateWrapper(value: $0) }
            .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }
}
