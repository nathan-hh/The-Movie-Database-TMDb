//
//  TheMoviedbAPI.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import Combine


protocol APIProtocol {
    static func getPopularMovies(region: String,page:Int) -> AnyPublisher<Results, Error>
    static func searchMovies(page:Int,query: String) -> AnyPublisher<Results, Error>
    static func getUser(sessionId: String) -> AnyPublisher<User, Error>
}

enum RequestMethod : String {
    case post = "POST"
    case delete = "DELETE"
}

enum TheMoviedbAPI  {
    static let agent = Agent()
    
    static let scheme = "https"
    static let apiKey = "36b639195de764331ba7d4e6b7994f70"
    static let version = "/3"
    static let imagesBase = "https://image.tmdb.org/t/p/w500"
    static let base =  "api.themoviedb.org"
    static let popular = "\(version)/movie/popular"
    static let searchMovie = "\(version)/search/movie"
    static let movieDetails = "\(version)/movie"
    static let account = "\(version)/account"
    static let authentication = "\(version)/authentication"
    static let reqeustToken = "\(authentication)/token/new"
    static let reqeustSession = "\(authentication)/session/new"
    static let login = "\(authentication)/token/validate_with_login"
    static let logOut = "\(authentication)/session"
    
}

extension TheMoviedbAPI : APIProtocol{
    
    static func getUser(sessionId: String) -> AnyPublisher<User, Error> {
        let params = ["session_id":sessionId]
        let url = URLWithParams(params: params, path: account)
        return run(URLRequest(url: url))
    }

    static func createToken() -> AnyPublisher<Token, Error> {
        let url = URLWithParams(params: nil, path: reqeustToken)
        return run(URLRequest(url: url))
    }
    
    static func createSession(token:String) -> AnyPublisher<Session, Error> {
        let url = URLWithParams(params: nil, path: reqeustSession)
        let params: [String: Any] = [
            "request_token": token,
        ]
        let request = requestWithParams(method: .post, params: params, url: url)
        return run(request)
    }
    
    static func login(username:String,password:String,token:String) -> AnyPublisher<Token, Error> {
        let url = URLWithParams(params: nil, path: login)
        let params: [String: Any] = [
            "username": username,
            "password": password,
            "request_token": token
        ]
        let request = requestWithParams(method: .post, params: params, url: url)
        return run(request)
    }
    
    static func logOut(sessionId:String) -> AnyPublisher<Session, Error> {
        let url = URLWithParams(params: nil, path: logOut)
        let params: [String: Any] = [
            "session_id": sessionId
        ]
        let request = requestWithParams(method: .delete, params: params, url: url)
        return run(request)
    }
        
    static func getPopularMovies(region: String = NSLocale.current.regionCode ?? "" ,page:Int) -> AnyPublisher<Results, Error> {
        var params = ["region":region]
        params["page"] = "\(page)"

        let url = URLWithParams(params: params, path: popular)
        return run(URLRequest(url: url))
    }
    
    static func getMovieDetails(id:Int) -> AnyPublisher<Movie, Error> {
        let url = URLWithParams(params: nil, path: "\(movieDetails)/\(id)")
        return run(URLRequest(url: url))
    }
    
    static func searchMovies(page:Int,query: String) -> AnyPublisher<Results, Error> {
        var params = ["page":"\(page)"]
        params["query"] = query.escaped

        let url = URLWithParams(params: params, path: searchMovie)
        return run(URLRequest(url: url))
    }
    
    static func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return agent.run(request, decoder)
            .map(\.value)
            .eraseToAnyPublisher()
    }    
    
    private static func requestWithParams(method:RequestMethod,params: [String:Any]?, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        return request
    }
    
    private static func URLWithParams(params: [String:String]?, path: String) -> URL {
        var components = URLComponents()
        components.host  = base
        components.path  = path
        components.scheme  = scheme
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        params?.forEach({ (key, value) in
            components.queryItems?.append(URLQueryItem(name: key, value: value))
        })
        return components.url!
    }
}

