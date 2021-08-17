//
//  User.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//

import Foundation
import RealmSwift


struct Token: Decodable {
    var success : Bool
    var expiresAt : String?
    var requestToken : String?
    var statusCode : Int?
    var statusMessage : String?
}

struct Session: Decodable {
    var success : Bool
    var sessionId : String?
    var statusMessage : String?
}

class Avatar: Decodable {
    var gravatar : [String:String]?
    var tmdb : [String:String]?
    var avatarHash : String?{
        return gravatar?["hash"]
    }
    var avatarPath : String?{
        return tmdb?["avatar_path"]
    }
}


class User: Object,Decodable {
    @objc dynamic var id : Int
    @objc dynamic var name : String?
    @objc dynamic var username : String
    var avatar : Avatar?
    @objc dynamic var iso6391 : String?
    @objc dynamic var iso31661 : String?
    @objc dynamic var includeAdult : Bool
    @objc dynamic var lastSearchList : String?

    override class func primaryKey() -> String? {
        return #keyPath(id)
    }
}

