//
//  AppDelegate.swift
//  IssPeeker
//
//  Created by jakzaw on 11/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import UIKit
import CoreData
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let vc = self.window?.rootViewController as? MapViewController
        let networkManager = NetworkManager()
        let persistanceManager = PersistanceManager()
        let mapDataProvider = MapDataProvider(networkManager: networkManager, persistanceManager: persistanceManager, refreshInterval: 5.0)
        let mapViewModel = MapViewModel(dataProvider: mapDataProvider)
        vc?.customizeWithViewModel(viewModel: mapViewModel)
        
        return true
    }
}

