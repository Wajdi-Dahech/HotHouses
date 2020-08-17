//
//  ViewController.swift
//  HotHouses
//
//  Created by Wajdi on 6/26/20.
//  Copyright © 2020 Wajdi. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftSpinner

class HousesViewController: UIViewController{
    
    var canVasView = UIView()
    var bgImage: UIImageView?
    var index = 0
    @IBOutlet fileprivate var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    fileprivate let housesViewModel = HousesViewModel()
    // Setting up refresh UI with proper action to reloadData
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(HousesViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.darkGray
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavBar()
        setupSearchBar()
        self.tableView.addSubview(self.refreshControl)
        tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = AppColor.OverAllColors.Background
        noResultsView()
        NotificationCenter.default.addObserver(self, selector: #selector(HousesViewController.networkStatusChanged(_:)), name: Notification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        
        Reach().monitorReachabilityChanges()
    }
    // check network status to detect offline&online and fetchData&reloadData once online again
    @objc func networkStatusChanged(_ notification: Notification) {
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            print("Not connected")
            SwiftSpinner.show("Please connect to the internet...", animated: true)
        case .online(.wwan):
            print("Connected via WWAN")
            attemptFetchHousess()
            SwiftSpinner.hide()
        case .online(.wiFi):
            print("Connected via WiFi")
            attemptFetchHousess()
            SwiftSpinner.hide()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        attemptFetchHousess()
    }
    // Create subview contain emptyBox and msg to let user know when his search did not find any results  in order to try again
    func noResultsView() {
        let myLayer = CALayer()
        let myImage = UIImage(named: "undraw_empty_xct9-2")?.cgImage
        myLayer.frame = CGRect(x: 50, y: 100, width: Int(Float(UIScreen.main.bounds.width) - 100), height: Int(Float(UIScreen.main.bounds.height) / 3))
        myLayer.contents = myImage
        
        let myTextLayer = CATextLayer()
        myTextLayer.string = "No results found! \n Perhaps try another search?"
        myTextLayer.font = FontNames.GothamSSm.GothamSSmLight as CFTypeRef
        myTextLayer.foregroundColor = AppColor.OverAllColors.Description?.cgColor
        myTextLayer.isWrapped = true
        myTextLayer.alignmentMode = .center
        myTextLayer.truncationMode = .end
        myTextLayer.fontSize = 16
        myTextLayer.frame = CGRect(x: 50, y: 400, width: Int(Float(UIScreen.main.bounds.width) - 100), height: Int(Float(UIScreen.main.bounds.height) / 3))
        canVasView.layer.addSublayer(myLayer)
        canVasView.layer.addSublayer(myTextLayer)
        self.view.addSubview(canVasView)
        self.canVasView.isHidden = true
    }
    
    var isSearchBarEmpty: Bool {
        
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    // Fetch Data from service
    fileprivate func attemptFetchHousess() {
        housesViewModel.fetchHouses { state in
            switch state {
            case .success: self.handleUIForSuccessFetchUsers()
            case .failure: print("Failed")
            }
        }
    }
    
    // ReloadData being fetched
    fileprivate func handleUIForSuccessFetchUsers() {
        self.tableView.reloadData()
    }
    
    
    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        setupCell()
    }
    
    fileprivate func setupCell() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Housecell")
    }
    // Customize SearchBar
    fileprivate func setupSearchBar() {
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.backgroundColor = AppColor.OverAllColors.Background
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a home"
        
        searchController.searchBar[keyPath: \.searchTextField].frame.size.height = 100
        
        searchController.searchBar[keyPath: \.searchTextField].font = UIFont.init(name: FontNames.GothamSSm.GothamSSmBook, size: 12)
        searchController.searchBar.showsCancelButton = false
        
        let searchIcon: UIImage = UIImage(named: "search")!
        searchController.searchBar.setImage(searchIcon.resized(to: CGSize(width: 14, height: 14)).withRenderingMode(.alwaysTemplate), for: .search, state: .normal)
        
        var closeIcon: UIImage = UIImage(named: "close-2")!
        closeIcon = closeIcon.withRenderingMode(.alwaysTemplate)
        searchController.searchBar.setImage(closeIcon.resized(to: CGSize(width: 12, height: 12)), for: .clear, state: .normal)
        
        navigationItem.searchController = searchController
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    // Customize NavBar
    fileprivate func setupNavBar() {
        
        let label = UILabel()
        label.text = "DTT REAL ESTATE"
        label.textAlignment = .right
        label.font = UIFont.init(name: FontNames.GothamSSm.GothamSSmBold, size: 18)
        label.textColor = AppColor.OverAllColors.Title
        let leftItem = UIBarButtonItem(customView: label)
        self.navigationItem.leftBarButtonItem = leftItem
        self.navigationController?.navigationBar.barTintColor = AppColor.OverAllColors.Background
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        
    }
    // Handle Refresh Action
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        
        attemptFetchHousess()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
}

// MARK: - UITableViewDataSource

extension HousesViewController: UITableViewDataSource {
    
    // Return houses count and check if Filter return result to show subview or hide it
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            
            if housesViewModel.filteredHouses.count == 0{
                self.canVasView.isHidden = false
                if index == 0 {
                    
                    
                    print(index)
                    index = index + 1
                }
                
            }
            else {
                self.canVasView.isHidden = true
                
                
                
            }
            
            return  housesViewModel.filteredHouses.count
        }
        self.canVasView.isHidden = true
        return housesViewModel.houses.count
        
    }
    // SetupCell content including filter ones
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HouseCell") as! HouseTableViewCell
        cell.backgroundColor = AppColor.OverAllColors.Background
        cell.cellView.layer.cornerRadius = 8
        self.tableView.rowHeight = 140
        let house:House
        if isFiltering {
            house = housesViewModel.filteredHouses[indexPath.row]
        } else {
            house = housesViewModel.houses[indexPath.row]
        }
        cell.configure(with: house)
        return cell
    }
    
}

extension HousesViewController: UISearchResultsUpdating {
    // Update tableView with filter result
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        
        housesViewModel.filterContentForSearchText(searchBar.text!)
        self.tableView.reloadData()
    }
}
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// MARK: - UITableViewDelegate

extension HousesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    // handle selected Row and fetch necessary paramaters
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let house = housesViewModel.houses[indexPath.row]
        let currentCell = tableView.cellForRow(at: indexPath)!
        guard let id = house.id else { return }
        guard let distance = currentCell.viewWithTag(777) as? UILabel else { return }
        showHouse(with: id,with: distance.text!)
    }
    // Push to HouseViewController with proper parameters
    func showHouse(with id: Int,with distance: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "HouseViewController") as? HouseViewController else {
            return
        }
        viewController.houseId = id
        viewController.distanceHouse = distance
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
