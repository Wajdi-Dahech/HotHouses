//
//  AboutViewController.swift
//  HotHouses
//
//  Created by Katsu on 6/30/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var about: UILabel!
 
    @IBOutlet weak var dummyText: UITextView!
    @IBOutlet weak var dAd: UILabel!
    @IBOutlet weak var by: UILabel!
    @IBOutlet weak var imageDTT: UIImageView!
    @IBOutlet weak var urlWebsite: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        about.text = StringUsed.About
        about.font = UIFont.init(name: FontNames.GothamSSm.GothamSSmBold, size: 18)
        about.textColor = AppColor.OverAllColors.Title
        
        
        dummyText.text = StringUsed.DummyText
        dummyText.backgroundColor = AppColor.OverAllColors.Background
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        let attributes = [NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.font : UIFont(name: FontNames.GothamSSm.GothamSSmLight, size: 12), NSAttributedString.Key.foregroundColor: AppColor.OverAllColors.Description]
        dummyText.attributedText = NSAttributedString(string: dummyText.text, attributes:attributes as [NSAttributedString.Key : Any])
        
        dAd.text = StringUsed.DaD
        dAd.font = UIFont.init(name: FontNames.GothamSSm.GothamSSmBold, size: 18)
        dAd.textColor = AppColor.OverAllColors.Title
        
        by.text = StringUsed.By
        by.font = UIFont.init(name: FontNames.GothamSSm.GothamSSmBook, size: 12)
        by.textColor = AppColor.OverAllColors.Title
        
        
        imageDTT.image = UIImage(named: "dtt_logo")
        
        
        urlWebsite.text = StringUsed.url
        urlWebsite.backgroundColor = AppColor.OverAllColors.Background
        urlWebsite.font = UIFont.init(name: FontNames.GothamSSm.GothamSSmBook, size: 12)
        let attributedString = NSMutableAttributedString(string: urlWebsite.text)
        let url = URL(string: "https://www.d-tt.nl")!

        // Set the 'd-tt.nl' substring to be the link
        attributedString.setAttributes([.link: url], range: NSMakeRange(0, attributedString.length))

        self.urlWebsite.attributedText = attributedString
        self.urlWebsite.isUserInteractionEnabled = true
        self.urlWebsite.isEditable = false

        // Set how links should appear: blue
        self.urlWebsite.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
        ]
        
    }


}
