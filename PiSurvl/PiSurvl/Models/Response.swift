//
//  Response.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 3/4/17.
//  Copyright © 2017 example. All rights reserved.
//

typealias Response = [String: Any]

enum ResponseError: Error {
  case CannotConnect
  case InvalidResponse
}
