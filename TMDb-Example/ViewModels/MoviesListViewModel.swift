//
//  MoviesListViewModel.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import Combine
import Foundation
import RealmSwift
import Combine_Realm

protocol MoviesListViewModelProtocol {
    func fetchMovies(query:String?)
    var arrMoviesItems : CurrentValueSubject<[Movie], Never> {get set}
    var downloading : CurrentValueSubject<Bool, Never>{get set}
    init(data:MoviesService ,api:APIProtocol.Type)
}

class MoviesListViewModel:MoviesListViewModelProtocol {
    
    var arrMoviesItems = CurrentValueSubject <[Movie], Never>([Movie]())
    var downloading = CurrentValueSubject <Bool, Never>(false)
    private var subscriptions = [AnyCancellable]()
    private var currentPage = 0
    
    private var data : MoviesService = MoviesService.instance
    private var api : APIProtocol.Type = TheMoviedbAPI.self

    private init() {  }

    required convenience init(data:MoviesService = MoviesService.instance,api:APIProtocol.Type = TheMoviedbAPI.self) {
        self.init()
        self.data = data
        self.api = api

        requestPopularMoviesApi()
    }
    
    func fetchMovies(query:String? = nil){
        requestPopularMoviesApi()
    }
    
    private func requestPopularMoviesApi(){
        downloading.send(true)
        DataNetworkService.getPopularMovies(dataService: data, api: api, page: currentPage+1).subscribe(on: RunLoop.main).sink { [weak self](err) in
            self?.downloading.send(false)
        } receiveValue: {[weak self] movies in
            self?.currentPage = movies.page
            self?.arrMoviesItems.send(movies.results)
            self?.downloading.send(false)
        }
        .store(in: &subscriptions)
    }

}
