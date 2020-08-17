//
//  LocationViewController.swift
//  HotHouses
//
//  Created by Katsu on 7/7/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationActions: class {
    func didTapAllow()
    func didTapDeny()
}
class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var allowButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    var didTapAllow: (() -> Void)?
    var didTapDeny: (() -> Void)?
    weak var delegate: LocationActions?
    override func viewDidLoad() {
      
        super.viewDidLoad()
        self.didTapAllow = {
            self.delegate?.didTapAllow()
        }
        self.didTapDeny = {
                   self.delegate?.didTapDeny()
               }
        
        
        // Do any additional setup after loading the view.
    }
    @IBAction func allowAction (_ sender: UIButton){
      didTapAllow?()
      }
    @IBAction func denyAction (_ sender: UIButton){
           didTapDeny?()
      }

}

