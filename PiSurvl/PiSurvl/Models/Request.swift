//
//  Request.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 3/4/17.
//  Copyright © 2017 example. All rights reserved.
//

enum RequestCommand: String {
  case QueryState, Enable, Disable, Peek
}

typealias Request = [String: Any]
