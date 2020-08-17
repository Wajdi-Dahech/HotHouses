//
//  HouseTableViewCell.swift
//  HotHouses
//
//  Created by Katsu on 7/3/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import UIKit
import Kingfisher
import CoreLocation

class HouseTableViewCell: UITableViewCell {
    let locationService = LocationService()
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var houseImageView : UIImageView!
    @IBOutlet weak var housePrice : UILabel!
    @IBOutlet weak var houseAddress : UILabel!
    @IBOutlet weak var houseBed : UILabel!
    @IBOutlet weak var houseBath : UILabel!
    @IBOutlet weak var houseSize : UILabel!
    @IBOutlet weak var houseDistance : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // Configure Cell with proper data
    func configure(with viewModel : House) {
        
        let url = URL(string: APPURL.DomainURL + viewModel.image!)
        let scale = UIScreen.main.scale
        let processor = DownsamplingImageProcessor(size: houseImageView.bounds.size)
            |> RoundCornerImageProcessor(cornerRadius: 10)
            |> ResizingImageProcessor(referenceSize: CGSize(width: 80.0 * scale, height: 80.0 * scale))
        houseImageView.kf.indicatorType = .activity
        houseImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.7)),
                .cacheOriginalImage
        ])
        
        housePrice.text = "$" + String(viewModel.price!)
        houseAddress.textColor = AppColor.OverAllColors.Title
        houseAddress.text = viewModel.zip! + " " + viewModel.city!
        houseAddress.textColor = AppColor.OverAllColors.Description
        houseBed.text = String(viewModel.bedrooms!)
        houseBed.textColor = AppColor.OverAllColors.Description
        houseBath.text = String(viewModel.bathrooms!)
        houseBath.textColor = AppColor.OverAllColors.Description
        houseSize.text = String (viewModel.size!)
        houseSize.textColor = AppColor.OverAllColors.Description
        houseDistance.textColor = AppColor.OverAllColors.Description
        if (locationService.status == .authorizedWhenInUse) || (locationService.status == .authorizedAlways) {
            
            let houseCoordinate = CLLocation(latitude: viewModel.latitude!, longitude: viewModel.longitude!)
            locationService.getLocation()
            let userCurrentLocation = locationService.userLocation()
            let distance =  (userCurrentLocation.distance(from:houseCoordinate))/1000
            houseDistance.text = String(format:"%.2f km",distance)
            
        }
        else {
            houseDistance.text = "~"
        }
        
        
        
        
    }
    
    
    
}
