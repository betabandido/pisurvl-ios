//
//  SurveillanceManager.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 5/1/17.
//  Copyright © 2017 example. All rights reserved.
//

import Foundation

class SurveillanceManager {
  public func requestCameraState(completionHandler: @escaping (Error?) -> Void) {
    DispatchQueue.global().async {
      let requestManager = RequestManager.sharedInstance
      let request = requestManager.createRequest(command: .QueryState)
      requestManager.submitRequest(
        request: request,
        completionHandler: { (requestId, error) in
          requestManager.waitForResponse(
            requestId: requestId,
            completionHandler: { (response, error) in
              var responseError = error
              if responseError == nil {
                if let enabled = (response["enabled"] as? Bool) {
                  // TODO: move CameraState into SurveillanceManager.
                  CameraState.sharedInstance.enabled = enabled
                } else {
                  responseError = ResponseError.InvalidResponse
                }
              }
    
              DispatchQueue.main.async { completionHandler(responseError) }
          })
      })
    }
  }
  
  public func requestCameraStateChange(enable: Bool,
                                       completionHandler: @escaping (Error?) -> Void) {
    let action = enable
      ? RequestCommand.Enable
      : RequestCommand.Disable
    
    DispatchQueue.global().async {
      let requestManager = RequestManager.sharedInstance
      let request = requestManager.createRequest(command: action)
      requestManager.submitRequest(
        request: request,
        completionHandler: { (requestId, error) in
          requestManager.waitForResponse(
            requestId: requestId,
            completionHandler: { (response, error) in
              var responseError = error
              if responseError == nil {
                if let enabled = (response["enabled"] as? Bool) {
                  // TODO: move CameraState into SurveillanceManager.
                  CameraState.sharedInstance.enabled = enabled
                } else {
                  responseError = ResponseError.InvalidResponse
                }
              }
              
              DispatchQueue.main.async { completionHandler(responseError) }
          })
      })
    }
  }
  
  public func requestCameraLatestImage(completionHandler: @escaping (Data?, Error?) -> Void) {
    let requestManager = RequestManager.sharedInstance
    let request = requestManager.createRequest(command: .Peek)
    
    requestManager.submitRequest(
      request: request,
      completionHandler: { (requestId, error) in
        requestManager.waitForResponse(
          requestId: requestId,
          completionHandler: { (response, error) in
            var image: Data? = nil
            var responseError = error
            if responseError == nil {
              if let imageString = response["image"] as? String {
                image = Data(base64Encoded: imageString)
              } else {
                responseError = ResponseError.InvalidResponse
              }
            }
            
            DispatchQueue.main.async { completionHandler(image, responseError) }
        })
    })
  }
}
