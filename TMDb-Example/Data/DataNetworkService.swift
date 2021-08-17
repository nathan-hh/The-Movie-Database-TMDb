//
//  DataNetworkService.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import Combine


//layer to deal with saved data before calling api
class DataNetworkService {
    static private var subscriptions = [AnyCancellable]()

    class func getPopularMovies(dataService: MoviesService, api: APIProtocol.Type,page:Int,batch:Int = 20)  -> AnyPublisher<Results, Error> {

        return dataService.getAll().map { (dbMovies) in
            let dbPage = dbMovies.count / batch
            if dbPage <= page{
                api.getPopularMovies(region: NSLocale.current.regionCode ?? "", page: page).sink(receiveCompletion: {_ in
                }, receiveValue: { (results) in
                    dataService.write(items: results.results)
                }).store(in: &subscriptions)
            }
            return Results(page: dbPage , results: dbMovies)

        }.eraseToAnyPublisher()
    }
    
}
