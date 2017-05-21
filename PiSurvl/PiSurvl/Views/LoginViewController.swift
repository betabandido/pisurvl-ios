//
//  ViewController.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 3/2/17.
//  Copyright © 2017 example. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleAPIClientForREST

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
  @IBOutlet weak var signInButton: GIDSignInButton!
  @IBOutlet weak var statusText: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  private var activityViewController: ActivityViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(LoginViewController.receiveToggleAuthUINotification(_:)),
      name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
      object: nil)
    
    AuthenticationManager.sharedInstance.configure(
      scopeList: [kGTLRAuthScopeDrive],
      delegate: self)
    
    GIDSignIn.sharedInstance().uiDelegate = self
    
    statusText.text = "Initializing..."
    toggleAuthUI()

    /*
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.locationManager = CLLocationManager()
    appDelegate.locationManager.delegate = appDelegate
    appDelegate.locationManager.requestAlwaysAuthorization()
    appDelegate.locationManager.startMonitoringSignificantLocationChanges()
    
    if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways {
      print("!!!! Not authorized to use location services")
    }
    */
  }
  
  deinit {
    NotificationCenter.default.removeObserver(
      self,
      name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
      object: nil)
  }
  
  @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
    if notification.name.rawValue == "ToggleAuthUINotification" {
      toggleAuthUI()
      if notification.userInfo != nil {
        guard let userInfo = notification.userInfo as? [String:String] else { return }
        self.statusText.text = userInfo["statusText"]!
      }
    }
  }
  
  func sign(_ signIn: GIDSignIn!,
            didSignInFor user: GIDGoogleUser!,
            withError error: Error!) {
    AuthenticationManager.sharedInstance.sign(
      signIn, didSignInFor: user, withError: error)
  }
  
  func sign(_ signIn: GIDSignIn!,
            didDisconnectWith user: GIDGoogleUser!,
            withError error: Error!) {
    AuthenticationManager.sharedInstance.sign(
      signIn, didDisconnectWith: user, withError: error)
  }

  private func toggleAuthUI() {
    if GIDSignIn.sharedInstance().hasAuthInKeychain() {
      self.signInButton.isHidden = true
      if AuthenticationManager.sharedInstance.user != nil {
        self.connectToSurveillanceSystem()
      }
    } else {
      self.signInButton.isHidden = false
      statusText.text = "Sign in to your\nGoogle account"
    }
  }
  
  private func connectToSurveillanceSystem() {
    puts(">>>>>>>>> Trying to connect")
    activityViewController = ActivityViewController()
    present(activityViewController!, animated: true, completion: nil)

    SurveillanceManager().requestCameraState(completionHandler: { (error) in
      self.activityViewController!.dismiss(animated: true, completion: nil)
      if error == nil {
        self.nextButton.isHidden = false
      } else {
        let alert = UIAlertController(
          title: "Connection Error",
          message: error!.localizedDescription,
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again",
                                      style: .default,
                                      handler: { (action) in self.connectToSurveillanceSystem() }))
        self.present(alert, animated: true)
        print("After alert!!!!!!!!!!!!!!")
      }
    })
  }
}
