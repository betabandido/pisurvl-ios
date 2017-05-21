//
//  RequestManager.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 3/4/17.
//  Copyright © 2017 example. All rights reserved.
//

import Foundation

// TODO make this generic
func createRequestProcessor() -> RequestProcessor {
  let user = AuthenticationManager.sharedInstance.user
  print("user: \(String(describing: user))")
  if user != nil {
    print("auth: \(user!.authentication)")
  }
  return GoogleDriveRequestProcessor(
    authentication: (AuthenticationManager.sharedInstance.user?.authentication)!)
}

class RequestManager {
  /// Static instance to use as a singleton.
  static let sharedInstance = RequestManager(
    requestProcessor: createRequestProcessor())
  
  /// Next request id to use.
  private var nextId = 1;
  
  /// The request processor.
  private let requestProcessor: RequestProcessor
  
  private let commandStrings: [RequestCommand: String] = [
    .QueryState: "query-state",
    .Enable: "enable",
    .Disable: "disable",
    .Peek: "peek"
  ]
  
  /**
      Initializes a new RequestManager.
 
      - Parameter requestProcessor: The request processor to use.
  */
  internal init(requestProcessor: RequestProcessor) {
    self.requestProcessor = requestProcessor
  }
  
  /**
      Creates a new request.
 
      - Parameter command: The request command (e.g., "enable-camera")
      - Returns: The new request.
  */
  func createRequest(command: RequestCommand) -> Request {
    let request = ["id": nextId, "cmd": commandStrings[command]!] as Request
    nextId += 1
    return request
  }
  
  /**
      Submits a request for processing.
 
      - Parameter request: The request to submit.
      - Parameter completionHandler: The handler that will be called when the
                                     request has been submitted.
  */
  func submitRequest(request: Request,
                     completionHandler: @escaping (Int, Error?) -> Void) {
    requestProcessor.submitRequest(request: request,
                                   completionHandler: completionHandler)
  }
  
  /**
      Waits for a response to a previous request.
   
      - Parameters:
        - requestId: The identifier of the original request.
        - completionHandler: The handler that will be called once the response
                             has been received.
  */
  func waitForResponse(requestId: Int,
                       completionHandler: @escaping (Response, Error?) -> Void) {
    requestProcessor.waitForResponse(id: requestId,
                                     completionHandler: completionHandler)
  }
}
