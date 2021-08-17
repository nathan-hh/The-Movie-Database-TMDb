//
//  Movie.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import RealmSwift

struct Genre : Decodable {
    var id : Int?
    var name : String?
}

class Movie: Object,Decodable {
    @objc dynamic var id : Int
    @objc dynamic var popularity : Float
    @objc dynamic var voteAverage : Float
    @objc dynamic var title : String
    @objc dynamic var overview : String
    @objc dynamic var releaseDate : String?
    var budget : Int?
    var revenue : Int?
    private var genres : [Genre]?
    @objc dynamic var voteCount : Float
    @objc dynamic private var backdropPath : String?
    @objc dynamic private var posterPath : String?
    
    override class func primaryKey() -> String? {
        return #keyPath(id)
    }
}

extension Movie{

    var genresDisplay:String?{
        get{
            return genres?.compactMap{$0.name}.joined(separator: ", ")
        }
    }
    
    var backdropPathUrl:String?{
        guard let backdropPath = backdropPath else {
            return nil
        }
        return TheMoviedbAPI.imagesBase +  backdropPath
    }
    var posterUrl:String?{
        guard let posterPath = posterPath else {
            return nil
        }
        return TheMoviedbAPI.imagesBase +  posterPath
    }
}
