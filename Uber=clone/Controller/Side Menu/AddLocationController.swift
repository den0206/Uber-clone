//
//  AddLocationController.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/17.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "Cell"

protocol AddlocationContollerDelegate : class {
    func updateLocation(locationString : String, type : LocationType)
}

class AddlocationController : UITableViewController {
    
    private let searchBar = UISearchBar()
    private let searchCompleter  = MKLocalSearchCompleter()
    private var searchResult = [MKLocalSearchCompletion]() {
        didSet {
            // when get set
            tableView.reloadData()
        }
    }
    private let type : LocationType
    private let location :CLLocation
    
    weak var delegate : AddlocationContollerDelegate?
    
    //MARK: - Life Cycle
    init(type : LocationType, location : CLLocation) {
        self.type = type
        self.location = location
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureSearchBar()
        configureSearchCompleter()
        
        print(type,location)
        
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        
        tableView.addShadow()
        
    }
    
    //MARK: - SearchBar
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    func configureSearchCompleter() {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchCompleter.region = region
        searchCompleter.delegate = self
        
    }
    
 
}

//MARK: - tableView delegate

extension AddlocationController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let result = searchResult[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = searchResult[indexPath.row]
        
        let title = result.title
        let subTitle = result.subtitle
        let locationString = title + " " + subTitle
        delegate?.updateLocation(locationString: locationString, type: type)
    }
    
}

//MARK: - SearchBar Delegate

extension AddlocationController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

//MARK: - MKLOcalSearch Delegate

extension AddlocationController : MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResult = completer.results
        
//        tableView.reloadData()
    }
}
