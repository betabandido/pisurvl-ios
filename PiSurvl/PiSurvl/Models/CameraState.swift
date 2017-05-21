//
//  CameraState.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 3/16/17.
//  Copyright © 2017 example. All rights reserved.
//

import Foundation

struct CameraState {
  static var sharedInstance = CameraState()
  
  var enabled: Bool = false
}
