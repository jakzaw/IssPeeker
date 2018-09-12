//
//  Observable+Ext.swift
//  IssPeeker
//
//  Created by jakzaw on 12/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType where Self.E : FixedWidthInteger {
    static func intervalWithInstantInitialValue(_ period: RxTimeInterval, scheduler: SchedulerType) -> Observable<E> {
        return Observable<E>.just(0).concat(Observable<E>.interval(period, scheduler: scheduler).map{ $0.advanced(by: 1) })
    }
}

extension ObservableType {
    func mapErrorToNil() -> Observable<E?> {
        return self.mapToOptional().catchErrorJustReturn(nil) 
    }
    
    func mapToOptional() -> Observable<E?> {
        return self.map{ e in return e as E? }
    }
}
