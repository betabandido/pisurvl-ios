//
//  ActivityViewController.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 4/24/17.
//  Copyright © 2017 example. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
  
  private let activityView = ActivityView()
  
  init() {
    super.init(nibName: nil, bundle: nil)
    modalTransitionStyle = .crossDissolve
    modalPresentationStyle = .overFullScreen
    view = activityView
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented)")
  }
}

private class ActivityView: UIView {
  let activityIndicatorView = UIActivityIndicatorView()
  
  init() {
    super.init(frame: CGRect.zero)
    
    activityIndicatorView.color = UIColor.darkGray
    activityIndicatorView.startAnimating()

    addSubview(activityIndicatorView)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented)")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    activityIndicatorView.frame.origin.x =
      ceil((bounds.width / 2.0) - (activityIndicatorView.frame.width / 2.0))
    activityIndicatorView.frame.origin.y =
      ceil((bounds.height / 2.0) - (activityIndicatorView.frame.height / 2.0))
  }
}
