//
//  RequestProcessor.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 3/4/17.
//  Copyright © 2017 example. All rights reserved.
//

import Foundation

protocol RequestProcessor {
  func submitRequest(request: Request,
                     completionHandler: @escaping (Int, Error?) -> Void)
  
  func waitForResponse(id: Int,
                       completionHandler: @escaping (Response, Error?) -> Void)
}
