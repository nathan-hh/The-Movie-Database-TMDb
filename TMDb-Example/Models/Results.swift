//
//  Results.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation

struct Results :Decodable {
    var page : Int
    var results : [Movie]
}
