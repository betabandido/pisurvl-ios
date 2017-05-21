//
//  PeekViewController.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 3/7/17.
//  Copyright © 2017 example. All rights reserved.
//

import UIKit

class PeekViewController: UIViewController {
  @IBOutlet weak var capturedImage: UIImageView!
  private var activityViewController: ActivityViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // TODO: check while preparing for segue whether camera is enabled
    requestLatestImage()
  }
  
  private func requestLatestImage() {
    activityViewController = ActivityViewController()
    present(activityViewController!, animated: true, completion: nil)

    SurveillanceManager().requestCameraLatestImage(completionHandler: { (data, error) in
      self.activityViewController!.dismiss(animated: true, completion: nil)
      
      if error == nil {
        self.capturedImage.image = UIImage(data: data!)
      } else {
        let alert = UIAlertController(
          title: "Connection Error",
          message: error!.localizedDescription,
          preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      }
    })
  }
}
