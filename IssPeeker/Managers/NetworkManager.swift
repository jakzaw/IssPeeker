//
//  NetworkManager.swift
//  IssPeeker
//
//  Created by jakzaw on 11/09/2018.
//  Copyright © 2018 jakzaw. All rights reserved.
//

import Foundation
import RxSwift

enum NetworkError : Error {
    case urlCantBeCreated
    case unknownError
}

protocol NetworkManagerProtocol {
    func getIssPosition() -> Single<IssPositionResponse>
    func getAstronauts() -> Single<AstronautsResponse>
}

class NetworkManager : NetworkManagerProtocol {
    private let session = URLSession(configuration: .default)
    private let scheme = "http"
    private let host = "api.open-notify.org"
    
    func getIssPosition() -> Single<IssPositionResponse>  {
        let path = "iss-now.json"
        return self.performDataTask(path: path, classToParse: IssPositionResponse.self)
    }
    
    func getAstronauts() -> Single<AstronautsResponse>  {
        let path = "astros.json"
        return self.performDataTask(path: path, classToParse: AstronautsResponse.self)
    }
    
    private func performDataTask<T: Decodable>(path: String, classToParse: T.Type) -> Single<T> {
        return Single<T>.create(subscribe: { [weak self] single -> Disposable in
            let dataTask = self?.createResumedDataTask(path: path, classToParse: classToParse) { (parsedResponse, error) in
                if let parsedResponse = parsedResponse {
                    single(SingleEvent.success(parsedResponse))
                }
                else if let error = error {
                    single(SingleEvent.error(error))
                }
                else {
                    //shouldn't happen
                    single(SingleEvent.error(NetworkError.unknownError))
                }
            }
            return Disposables.create { dataTask?.cancel() }
        })
        
    }
    
    private func createResumedDataTask<T: Decodable>(path: String, classToParse: T.Type, completion: @escaping (T?, Error?) -> Void) -> URLSessionDataTask? {
        guard let url = self.prepareUrlForPath(path: path) else {
            completion(nil, NetworkError.urlCantBeCreated)
            return nil
        }
        
        let dataTask = session.dataTask(with: url) { (data, _, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let parsedResponse = try decoder.decode(classToParse, from: data)
                    completion(parsedResponse, nil)
                }
                catch let error {
                    completion(nil, error)
                }
            }
            else {
                completion(nil, error)
            }
        }
        dataTask.resume()
        return dataTask
    }
    
    private func prepareUrlForPath(path : String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = self.scheme
        urlComponents.host = self.host
        urlComponents.path = "/" + path
        return urlComponents.url
    }
}
