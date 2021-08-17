//
//  DataService.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import RealmSwift
import Combine_Realm
import Combine

protocol Repository {
    associatedtype ITEM
    func write(items:[ITEM])
    func delete(ids:[Int])
    func getAll() -> AnyPublisher<[ITEM], Error>
    func getAll() -> [ITEM]
    func getItem(id: Int) -> AnyPublisher<ITEM, Error>?
}

extension Repository where ITEM : Object{
    func getAll() -> [ITEM] {
        return RealmService.realm.objects(ITEM.self).toArray()
    }
    
    func getAll() -> AnyPublisher<[ITEM], Error> {
        return RealmPublishers.array(from: RealmService.realm.objects(ITEM.self))
    }
    
    func delete(ids: [Int]) {
        try? RealmService.realm.write {
            let items = ids.compactMap{RealmService.realm.object(ofType: ITEM.self, forPrimaryKey: $0)}
            RealmService.realm.delete(items)
        }
    }
    
    func write(items:[ITEM])  {
        try? RealmService.realm.write {
            RealmService.realm.add(items, update: Realm.UpdatePolicy.modified)
        }
    }
    
    func getItem(id: Int) -> AnyPublisher<ITEM, Error>? {
        if let item = RealmService.realm.object(ofType: ITEM.self, forPrimaryKey: id){
            return RealmPublishers.from(object: item)
        }
        return nil
    }
    
}

protocol MovieRepository:Repository where ITEM == Movie {

}

protocol UserRepository:Repository {
    func updateUserSearch(id:Int,query:String)
}

struct RealmService  {
    private init() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration()
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
    }
    
    static let realm  = { () -> Realm in
        let _ = RealmService.init()
        return try! Realm()
    }()
}


struct MoviesService: MovieRepository{
    
    private init() {}

    static let instance = MoviesService()

}

struct UsersService:UserRepository{
    static let instance = UsersService()

    typealias ITEM = User

    private init() {}

    func updateUserSearch(id:Int,query:String)  {
        if let user = RealmService.realm.object(ofType: ITEM.self, forPrimaryKey: id){
            try? RealmService.realm.write {
                if user.lastSearchList == nil{
                    user.lastSearchList = ""
                }
                if !user.lastSearchList!.contains(query){
                    user.lastSearchList?.append(",\(query)")
                }
            }
        }
    }

}
