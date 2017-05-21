//
//  AuthenticationManager.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 3/5/17.
//  Copyright © 2017 example. All rights reserved.
//

import Foundation
import UIKit

// TODO: try to improve the design of this class (avoid singleton + configure)
class AuthenticationManager {
  static let sharedInstance = AuthenticationManager()
  
  var user: GIDGoogleUser?
  
  private init() {}
  
  func configure(scopeList: [String], delegate: LoginViewController) {
    var error: NSError?
    GGLContext.sharedInstance().configureWithError(&error)
    assert(error == nil,
           "Error configuring Google services: \(error!)")
    GIDSignIn.sharedInstance().delegate = delegate
    GIDSignIn.sharedInstance().scopes = scopeList
    GIDSignIn.sharedInstance().signInSilently()
//    GIDSignIn.sharedInstance().signOut()
  }
  
  func sign(_ signIn: GIDSignIn!,
            didSignInFor user: GIDGoogleUser!,
            withError error: Error!) {
    if (error == nil) {
      self.user = user
      let name = user.profile.givenName!
      NotificationCenter.default.post(
        name: Notification.Name(rawValue: "ToggleAuthUINotification"),
        object: nil,
        userInfo: ["statusText": "Hello \(name),\nPress Next to start."])
    } else {
      let errorCode = GIDSignInErrorCode(rawValue: (error as NSError).code)
      if errorCode == .hasNoAuthInKeychain {
        NotificationCenter.default.post(
          name: Notification.Name(rawValue: "ToggleAuthUINotification"),
          object: nil,
          userInfo: ["statusText": "Error signing in:\n\(error.localizedDescription)"])
      }
    }
  }
  
  func sign(_ signIn: GIDSignIn!,
            didDisconnectWith user: GIDGoogleUser!,
            withError error: Error!) {
    self.user = nil
  }
}
