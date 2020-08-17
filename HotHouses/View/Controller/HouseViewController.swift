//
//  HouseViewController.swift
//  HotHouses
//
//  Created by Katsu on 7/6/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import UIKit
import MapKit
import Kingfisher
import Contacts

// Custom Pin for draw on Map
class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageName: String!
    
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D, imageName:String) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
        self.imageName = imageName
    }
}

class HouseViewController: UIViewController {
    
    
    @IBOutlet weak var cornerRadiusView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var image: UIImageView!
    var housePin:customPin?
    let locationService = LocationService()
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var desc: UITextView!
    @IBOutlet weak var descTitle: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var bath: UILabel!
    @IBOutlet weak var bed: UILabel!
    @IBOutlet weak var price: UILabel!
    let houseAnnotation = MKPointAnnotation()
    var mapItem: MKMapItem?
    var distanceHouse: String?
    var houseId: Int?
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
    lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    fileprivate let viewModel = HouseViewModel()
    
    override func viewDidLoad() {
        spinnerLoading()
        mapView.delegate = self
        registerMapAnnotationViews()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tap)
        
        // Customize back button
        let backBTN = UIBarButtonItem(image: UIImage(named: "left-arrow-2"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        
        super.viewDidLoad()
        
    }
    
    // Prevent app from potential crash when discard MapView
    deinit {
        
        mapView.annotations.forEach{mapView.removeAnnotation($0)}
        
        mapView.delegate = nil
        
    }
    // Register class as a reusable annotation view for customPin annotations
    private func registerMapAnnotationViews() {
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(customPin.self))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Customize navbar transparent Backrgound
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        guard let id = houseId else { return }
        attemptFetchHouse(with: id)
    }
    
    // Disable nabvar transparency after pressing Back
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = true
        
    }
    // Detect Double tap gesture to draw on map direction and setting up proper alert when location services are off
    @objc func doubleTapped() {
        
        if (locationService.status == .authorizedWhenInUse) || (locationService.status == .authorizedAlways) {
            
            drawDirection()
            
        }
        else {
            let alertController = UIAlertController (title: "Location Services are off", message: "To use background location, you must enable 'Always' in the Location Services settings", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
        
        
    }
    // Fech House Details
    fileprivate func attemptFetchHouse(with id: Int) {
        viewModel.fetchHouse(with: id) { state in
            switch state {
            case .success: self.updateViews()
            case .failure: print("failure")
            }
        }
    }
    // update view with correspond data and display house location on Map
    fileprivate func updateViews() {
        
        let url = URL(string: APPURL.DomainURL + (viewModel.house?.image!)!)
        
        let processor = DownsamplingImageProcessor(size: image.bounds.size)
        image.kf.indicatorType = .activity
        image.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .transition(.fade(0.7)),
                .cacheOriginalImage
        ])
        
        price.text = "$" + String(viewModel.house?.price ?? 1)
        bed.text = String(viewModel.house?.bedrooms ?? 1)
        bath.text = String(viewModel.house?.bathrooms ?? 1)
        size.text = String(viewModel.house?.size ?? 1)
        desc.text = viewModel.house?.description ?? StringUsed.DummyText
        distance.text = distanceHouse
        let initialLocation = CLLocation(latitude: 52 , longitude:5)
        mapView.centerToLocation(initialLocation)
        
        houseAnnotation.coordinate = CLLocationCoordinate2D(latitude: 52, longitude: 5)
        houseAnnotation.title = "Property Location"
        let zip = viewModel.house?.zip ?? " "
        let city = viewModel.house?.city ?? " "
        let address = zip + " " + city
        houseAnnotation.subtitle = address
        mapView.addAnnotation(houseAnnotation)
        housePin =  customPin(pinTitle: "Property Location", pinSubTitle: address, location: houseAnnotation.coordinate,imageName: "finish")
        
        let addressDict = [CNPostalAddressStreetKey: houseAnnotation.title ?? "~"]
        let placemark = MKPlacemark(
            coordinate: houseAnnotation.coordinate,
            addressDictionary: addressDict)
        mapItem = MKMapItem(placemark: placemark)
        mapItem?.name = title
        
        
        dismiss(animated: false, completion: nil)
        self.blurEffectView.removeFromSuperview()
        
        
    }
    // Display spinning Loader while fetching data
    func spinnerLoading() {
        
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    // Add annotation to map view
    // Draw direction between user Location and house location
    func drawDirection(){
        
        
        let destinationLocation = CLLocationCoordinate2D(latitude:locationService.userLocation().coordinate.latitude , longitude: locationService.userLocation().coordinate.longitude)
        
        let destinationPin = customPin(pinTitle: "My Location", pinSubTitle: "", location: destinationLocation, imageName: "location")
        self.mapView.addAnnotation(housePin!)
        self.mapView.addAnnotation(destinationPin)
        
        
        
        let sourcePlaceMark = MKPlacemark(coordinate: housePin!.coordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }
            
            let route = directionResonse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
        self.mapView.delegate = self
    }
    
    
    /*
     
     */
}

private extension MKMapView {
    // Center Map to the property Location and diplay region represented by MKCoordinateRegion
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

extension HouseViewController: MKMapViewDelegate {
    
    // Configuring the annotation View
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? customPin {
            annotationView = setupDrawAnnotationView(for: annotation, on: mapView)
        }
        else if let annotation = annotation as? MKPointAnnotation {
            annotationView = setupOpenMapAnnotationView(for: annotation, on: mapView)
        }
        
        return annotationView
    }
    // Customize annotation pin image
    private func setupDrawAnnotationView(for annotation: customPin, on mapView: MKMapView) -> MKAnnotationView {
        let reuseIdentifier = NSStringFromClass(customPin.self)
        let flagAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
        
        flagAnnotationView.canShowCallout = true
        
        // Resize image
        let pinImage = UIImage(named: annotation.imageName)
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        // Provide the annotation view's image.
        flagAnnotationView.image = resizedImage
        
        return flagAnnotationView
    }
    // Setting up Callout bubble and action
    private func setupOpenMapAnnotationView(for annotation: MKPointAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        
        let identifier = "houseAnnotation"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
            
        } else {
            // 5
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier)
            view.canShowCallout = true
            view.image = UIImage(named: "house")
            view.calloutOffset = CGPoint(x: -5, y: 5)
            let mapsButton = UIButton(frame: CGRect(
                origin: CGPoint.zero,
                size: CGSize(width: 48, height: 48)))
            mapsButton.setBackgroundImage(#imageLiteral(resourceName: "Map"), for: .normal)
            view.rightCalloutAccessoryView = mapsButton
            view.leftCalloutAccessoryView = UIImageView(image: UIImage(named: "home")!.resized(to: CGSize(width: 16, height: 16)))
        }
        
        return view
    }
    // Open Map when callout AccessoryControlTapped
    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        mapItem?.openInMaps(launchOptions: launchOptions)
    }
    // Visual representation for polyline which going to be draw on Map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
}
