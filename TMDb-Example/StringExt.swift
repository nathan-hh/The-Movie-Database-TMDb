//
//  StringExt.swift
//  TMDb-Example
//
//  Created by nati on 24/01/2021.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
extension String{
    var escaped: String{
        return replacingOccurrences(of: " ", with: "+")
    }
}
