//
//  File.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//

import Foundation
import Combine

class MovieDetailsViewModel {
    let movie = CurrentValueSubject<Movie?, Never>(nil)
    private var subscriptions = [AnyCancellable]()

    class func create(from movie:Movie) -> MovieDetailsViewModel{
        let vm = MovieDetailsViewModel()
        vm.movie.send(movie)
        return vm
    }
    
    private init() {
    }
    
    func loadDetails(){
        TheMoviedbAPI.getMovieDetails(id: movie.value!.id).sink { (err) in
            
        } receiveValue: { (movie) in
            self.movie.send(movie)
        }.store(in: &subscriptions)

    }

}
