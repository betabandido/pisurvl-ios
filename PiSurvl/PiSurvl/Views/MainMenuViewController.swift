//
//  MainMenuViewController.swift
//  PiSurvl
//
//  Created by Victor Jimenez on 3/6/17.
//  Copyright © 2017 example. All rights reserved.
//

import UIKit

class MainMenuViewController: UITableViewController {
  @IBOutlet weak var stateSwitch: UISwitch!
  private var activityViewController: ActivityViewController?
  

  override func viewDidLoad() {
    super.viewDidLoad()
    
    stateSwitch.isOn = CameraState.sharedInstance.enabled
  }

  @IBAction func stateValueChanged(_ sender: UISwitch) {
    activityViewController = ActivityViewController()
    present(activityViewController!, animated: true, completion: nil)
    
    SurveillanceManager().requestCameraStateChange(
      enable: sender.isOn,
      completionHandler: { (error) in
        self.activityViewController!.dismiss(animated: true, completion: nil)
        if error == nil {
          self.setCameraState(enabled: CameraState.sharedInstance.enabled)
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
  
  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return tableView.cellForRow(at: indexPath)?.reuseIdentifier == "Peek"
      ? CameraState.sharedInstance.enabled
      : true
  }
  
  private func setCameraState(enabled: Bool) {
    self.stateSwitch.isOn = CameraState.sharedInstance.enabled
//    self.tableView.reloadData()
  }
}
