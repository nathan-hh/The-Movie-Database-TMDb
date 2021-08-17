//
//  UserViewModel.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//

import Foundation
import Combine
import Combine_Realm

class UserViewModel {
    
    let user = CurrentValueSubject<User?, Never>(nil)
    private var subscriptions = [AnyCancellable]()
    let downloading = CurrentValueSubject <Bool, Never>(false)
    let loggedIn = CurrentValueSubject <Bool, Never>(false)
    let logErr = CurrentValueSubject <String?, Never>(nil)
    private var token = ""
    private var sessionId = ""

    private init() { }

    required convenience init(data:UsersService = UsersService.instance,api:APIProtocol.Type = TheMoviedbAPI.self) {
        self.init()
        createToken()
        data.getAll().sink(receiveCompletion: { (err) in
        }, receiveValue: {[weak self] users in
            if let user = users.last{
                self?.loggedIn.send(true)
                self?.user.send(user)
            }
        }).store(in: &subscriptions)
    }
    
    func getUserDetails() {
        guard user.value == nil else {return}

        downloading.send(true)
        TheMoviedbAPI.getUser(sessionId:sessionId).sink(receiveCompletion: {err  in
            
        }, receiveValue: {[weak self] (user) in
            self?.downloading.send(false)
            UsersService.instance.write(items: [user])
        })
        .store(in: &subscriptions)
    }
    
    func createToken()  {
        TheMoviedbAPI.createToken().sink { (err) in
        } receiveValue: {[weak self] (token) in
            self?.token = token.requestToken ?? ""
        }.store(in: &subscriptions)
    }
    
    func createSession()  {
        TheMoviedbAPI.createSession(token: self.token).sink { err in
        } receiveValue: {[weak self] (session) in
            if session.success{
                self?.sessionId = session.sessionId!
                self?.getUserDetails()
            }
        }.store(in: &subscriptions)
    }
    
    func login(name: String, pass: String)  {
        if token.isEmpty{
            createToken()
        }

        TheMoviedbAPI.login(username:name, password: pass, token: token).sink { (err) in
        } receiveValue: {[weak self] (token) in
            if token.success{
                self?.loggedIn.send(true)
                self?.createSession()
            }else{
                self?.logErr.send(token.statusMessage)
            }
        }.store(in: &subscriptions)
    }
    
    func logOut()  {
        TheMoviedbAPI.logOut(sessionId: sessionId).sink { (err) in
        } receiveValue: {[weak self] (session) in
            guard let self = self , let user = self.user.value else {return}
            if session.success{
                self.loggedIn.send(false)
                self.sessionId = ""
                self.token = ""
                UsersService.instance.delete(ids: [user.id])
            }else{
                self.logErr.send("LogOut faild")
            }
        }.store(in: &subscriptions)
    }
    
}
