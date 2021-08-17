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


class SearchViewModel :MoviesListViewModelProtocol{
    
    var arrMoviesItems = CurrentValueSubject <[Movie], Never>([Movie]())
    private var arrTempFavoritesMoviesItems = [Movie]()
    private var query = ""
    var downloading = CurrentValueSubject <Bool, Never>(false)
    private var subscriptions = [AnyCancellable]()
    private var data : MoviesService = MoviesService.instance
    private var api : APIProtocol.Type = TheMoviedbAPI.self
    private var searchCurrentPage = 0

    private init() { }

    required convenience init(data:MoviesService = MoviesService.instance,api:APIProtocol.Type = TheMoviedbAPI.self) {
        self.init()
        self.data = data
        self.api = api
    }
    
    func fetchMovies(query:String? = nil){
        if let query = query{
            self.query = query
        }
        searchMoviesApi(newQuery:query != nil)
    }
    
    private func searchMoviesApi(newQuery:Bool){
        downloading.send(true)
        if newQuery{
            searchCurrentPage = 1
            saveQuary()
        }
        api.searchMovies(page: searchCurrentPage+1,query:query).subscribe(on: RunLoop.main).sink { [weak self](err) in
            self?.downloading.send(false)
        } receiveValue: {[weak self] response in
            let movies  = response.results
            self?.searchCurrentPage = response.page
            self?.downloading.send(false)
            if newQuery{
                self?.arrMoviesItems.send(movies)
            }else{
                self?.arrMoviesItems.value.append(contentsOf: movies)
            }
        }
        .store(in: &subscriptions)
    }
    
    private func saveQuary(){
        if let user = UsersService.instance.getAll().last{                UsersService.instance.updateUserSearch(id: user.id, query: self.query)
        }
    }

}
