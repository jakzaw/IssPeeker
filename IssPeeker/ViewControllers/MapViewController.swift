//
//  ViewController.swift
//  IssPeeker
//
//  Created by jakzaw on 11/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import UIKit
import Mapbox
import RxSwift
import RxCocoa

class MapViewController: UIViewController, MGLMapViewDelegate {
    let disposeBag = DisposeBag()
    var viewModel : MapViewModel?
    var mapView : MGLMapView!
    var annotation : MGLPointAnnotation?
    var positionSyncLabel : UILabel!
    var astronautsSyncLabel : UILabel!
    
    func customizeWithViewModel(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let mapView = MGLMapView()
        self.mapView = mapView
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mapView)
        mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        let positionSyncLabel = UILabel()
        self.positionSyncLabel = positionSyncLabel
        self.positionSyncLabel.backgroundColor = UIColor(white: 1, alpha: 0.5)
        positionSyncLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(positionSyncLabel)
        positionSyncLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        positionSyncLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40).isActive = true
        
        let astronautsSyncLabel = UILabel()
        self.astronautsSyncLabel = astronautsSyncLabel
        self.astronautsSyncLabel.backgroundColor = UIColor(white: 1, alpha: 0.5)
        astronautsSyncLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(astronautsSyncLabel)
        astronautsSyncLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        astronautsSyncLabel.bottomAnchor.constraint(equalTo: self.positionSyncLabel.topAnchor).isActive = true
        
        self.viewModel?.centerMap.drive(onNext: { [weak self] coordinate in
            self?.mapView.setCenter(coordinate, zoomLevel: 2, animated: false)
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.issPosition.drive(onNext: { [weak self] coordinate in
            self?.updateAnnotationCoordinate(coordinate: coordinate)
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.astronauts.drive(onNext: { [weak self] astronauts in
            self?.annotation?.subtitle = astronauts
        }).disposed(by: self.disposeBag)
        
        self.viewModel?.positionSyncDate.drive(self.positionSyncLabel.rx.text).disposed(by: self.disposeBag)
        self.viewModel?.astronautsSyncDate.drive(self.astronautsSyncLabel.rx.text).disposed(by: self.disposeBag)
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        let reuseIdentifier = "stationImage"
        return mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier) ?? MGLAnnotationImage(image: UIImage(named: "station")!, reuseIdentifier: reuseIdentifier)
    }
    
    private func updateAnnotationCoordinate(coordinate: CLLocationCoordinate2D) {
        if self.annotation == nil {
            let annotation = MGLPointAnnotation()
            self.annotation = annotation
            annotation.title = "Astronauts:"
            mapView.addAnnotation(annotation)
            self.annotation = annotation
        }
        self.annotation?.coordinate = coordinate
    }
}
