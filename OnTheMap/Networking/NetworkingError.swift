//
//  NetworkingError.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import Foundation

enum NetworkingError: Error {
    case NetworkError(Error)
    case DataIsEmpty
    case UnableToParseData(Error)
}
