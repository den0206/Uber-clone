//
//  HomeController.swift
//  Uber=clone
//
//  Created by 酒井ゆうき on 2020/02/08.
//  Copyright © 2020 Yuuki sakai. All rights reserved.
//

import UIKit
import Firebase
import MapKit

private let reuserIdentifier = "LocationCell"
private let annotationIdentifer = "DriverAnnotation"

enum ActionButtonConfioguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeController : UIViewController {
    
    private let mapview = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let rideActionView = RideActionView()
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    
    private var user : FUser? {
        didSet {
            if user?.accountType == .passanger {
                fetchDrivers()
                configureLocationActivationView()
            } else {
                // Driver
                obserbeTrips()
            }
        }
    }
    
    private var trip : Trip? {
        didSet {
            guard let trip = trip else {return}
            let controller = PickupController(trip: trip)
            
            if #available(iOS 13.0, *) {
                controller.modalPresentationStyle = .fullScreen
            }
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    private let tableView = UITableView()
    private final let locationInputViewHeight : CGFloat = 200
    private final let rideActionViewHeight : CGFloat = 300
    
    private var searchRersults = [MKPlacemark]()
    private var actionButtonConfigure = ActionButtonConfioguration()
    private var route : MKRoute?
    
    private let actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(seleceActionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.isHidden = true
        // check Login
        checkUserIsLogin()
        enableLocationaService()
       
        
        
        
        
    }
    
    //MARK: API
    
    private func checkUserIsLogin() {
        
        if Auth.auth().currentUser?.uid == nil {
            // aync
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginViewController())
                if #available(iOS 13.0, *) {
                    nav.isModalInPresentation = true
                }
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configure()
        } 
    }
    
    func fetchUserData() {
        guard let currentid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserData(uid: currentid) { (user) in
            self.locationInputView.titleLabel.text = user.fullname
            self.user = user
            
        }
    }
    func fetchDrivers() {
        // throw if user is passanger
//        guard user?.accountType == .passanger else {
//            print("User is Driver")
//            return}
    
        guard let location = locationManager?.location else {return}
        Service.shared.fetchDrivers(location: location) { (driver) in
            // 座標
            guard let coodinate = driver.location?.coordinate else {return}
            let driverAnnotation = DriverAnnotation(_uid: driver.uid, _coodinate: coodinate)
            
            var driverIsVisble : Bool {
                
                return self.mapview.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else {return false}
                    
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(withCoodinate: coodinate)
                        return true
                    }
                    return false
                }
                
            }
            
            if !driverIsVisble {
                // add Annotation
                self.mapview.addAnnotation(driverAnnotation)
                
            }
            
        }
    }
    
    func obserbeTrips() {
        Service.shared.obserebeTrip { (trip) in
            self.trip = trip
        }
    }
    
    //MARK: Selectors
    
    @objc func seleceActionButtonPressed() {
        
        switch actionButtonConfigure {
        case .showMenu:
            print("SideMenu")
        case .dismissActionView :
            
            removeAnnotaionsandOverlays()
            
            // Expire Zoom
            mapview.showAnnotations(mapview.annotations, animated: true)
            
            
            // return show menu
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                // dismiss Ride VIew
                self.animateRideActionView(shoudShow: false)
            }
            
            
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            // aync
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginViewController())
                if #available(iOS 13.0, *) {
                    nav.isModalInPresentation = true
                }
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } catch {
            print("can't Sign Out")
        }
    }
    
    func configure() {
        configureUI()
        fetchUserData()
//        fetchDrivers()
    }
    
    //MARK: Helpers
    
    
    func configureUI() {
        configureMapView()
        configuyreRideActionView()
        
        
        view.addSubview(actionButton)
        actionButton.anchor(top : view.safeAreaLayoutGuide.topAnchor, left:  view.safeAreaLayoutGuide.leftAnchor, paddingTop: 16,paddingLeft: 20, width: 30,height: 30)
        
       
        // hidedn
        inputActivationView.alpha = 0
        UIView.animate(withDuration: 2) {
            // present
            self.inputActivationView.alpha = 1
        }
        
        configureTableView()
        
    }
    
    func configureLocationActivationView() {
        
        guard let user = user else {return}
        
        guard user.accountType == .passanger else {return}
        // add activationView
        view.addSubview(inputActivationView)
        inputActivationView.centerX(InView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        inputActivationView.delegate = self
    }
    
    func configureActionButton(config : ActionButtonConfioguration) {
        
        switch config {
        case .showMenu:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            // return SHow Menu
            actionButtonConfigure = .showMenu
        case .dismissActionView :
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfigure = .dismissActionView
        }
    }
    
    func configureMapView() {
        view.addSubview(mapview)
        mapview.frame = view.frame
        
        // User Location
        mapview.showsUserLocation = true
        mapview.userTrackingMode = .follow
        mapview.delegate = self
    }
    
    func configuyreRideActionView() {
        view.addSubview(rideActionView)
        // init hidden View
        rideActionView.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: rideActionViewHeight)
        rideActionView.delegate = self
        
    }
    
    func animateRideActionView(shoudShow : Bool, destination : MKPlacemark? =  nil) {
        
        if shoudShow {
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height - self.rideActionViewHeight
            }
            
            guard let destination = destination else {return}
            rideActionView.destination = destination
        } else {
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
            
        }
        
        //        let  yOrigin = shoudShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
    }
    
    
    
    
}

//MARK: Mapview Helper
private extension HomeController {
    //MARK: Search
    func searchBy(naturalLabguageQuery : String, completion : @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapview.region
        request.naturalLanguageQuery = naturalLabguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {return}
            
            response.mapItems.forEach { (item) in
                // add Item
                results.append(item.placemark)
            }
            completion(results)
        }
    }
    
    //MARK: Direction Line
    
    func generatePolyLine(toDestination destination : MKMapItem) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else {return}
            self.route = response.routes[0]
            
            guard let polyLine = self.route?.polyline else {return}
            self.mapview.addOverlay(polyLine)
        }
    }
    
    //MARK: Remove Direction Line
    
    func removeAnnotaionsandOverlays() {
        
        // remove annotations
        mapview.annotations.forEach { (annotations) in
            if let anno = annotations as? MKPointAnnotation {
                mapview.removeAnnotation(anno)
            }
        }
        
        // remove direction Line
        if mapview.overlays.count > 0 {
            mapview.removeOverlay(mapview.overlays[0])
        }
        
    }
}

//MARK: Mapview delegate

extension HomeController : MKMapViewDelegate {
    
    //MARK: ANnotaion
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifer)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        
        return nil
    }
    
    //MARK: direction Map
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyLine = route.polyline
            let lineRenderer = MKPolylineRenderer(polyline: polyLine)
            
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        
        return MKOverlayRenderer()
    }
}

extension HomeController {
    
    func enableLocationaService() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted , .denied:
            locationManager?.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("Always")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    
}

//MARK: Activation VIew Delegate

extension HomeController : LocationInputActivationViewDelegate {
    
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
}

//MARK: InputVIew Delegate

extension HomeController : LocationInputViewDelegate {
    
    func executeSearch(query: String) {
        searchBy(naturalLabguageQuery: query) { (results) in
            // convert class Ver
            self.searchRersults = results
            self.tableView.reloadData()
            
        }
    }
    
    
    func handleBackBUttonTapped() {
        locationInputView.removeFromSuperview()
        
        UIView.animate(withDuration: 1) {
            // dismiss tableView
            self.tableView.frame.origin.y = self.view.frame.height
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureLocationInputView() {
        
        // inputVIew
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        locationInputView.delegate = self
        
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { (_) in
            
            UIView.animate(withDuration: 0.5) {
                
                // 始点
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }
        
    }
    
    
}

//MARK: tableView delegate

extension HomeController : UITableViewDelegate, UITableViewDataSource {
    
    // set tableview
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuserIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height , width: view.frame.width, height: height)
        
        
        view.addSubview(tableView)
        
        
    }
    
    // delegate Method
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //        return section == 0 ? 2 : 5
        
        if section == 0 {
            return 2
        }
        
        return searchRersults.count
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1 {
            cell.placeMark = searchRersults[indexPath.row]
        }
        
        return cell
    }
    
    // Gray Title
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // blank not nil
        return "   "
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlaceMark = searchRersults[indexPath.row]
        //        var annotaions = [MKAnnotation]()
        
        self.configureActionButton(config: .dismissActionView)
        
        // change MKMapItem
        let destination = MKMapItem(placemark: selectedPlaceMark)
        
        // add deirection Map
        generatePolyLine(toDestination: destination)
        
        handleBackBUttonTapped()
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedPlaceMark.coordinate
        self.mapview.addAnnotation(annotation)
        
        mapview.selectAnnotation(annotation, animated: true)
        
        // Zoom Selected Annotations
        //
        //        mapview.annotations.forEach { (annotation) in
        //            if let anno = annotation as? MKUserLocation {
        //                annotaions.append(anno)
        //            }
        //
        //            if let anno = annotation as? MKPointAnnotation {
        //                annotaions.append(anno)
        //            }
        //        }
        //
        
        let annotaions = self.mapview.annotations.filter({ !$0.isKind(of: DriverAnnotation.self)})
//        mapview.showAnnotations(annotaions, animated: true)
        
        // custom ZoomUo
        mapview.zoomToFit(annotations: annotaions)
        
        animateRideActionView(shoudShow: true, destination: selectedPlaceMark)
        
        // pass
//        rideActionView.destination = selectedPlaceMark
        
    }
    

    
}

extension HomeController : RideActionViewDelegate {
    
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoodinates = locationManager?.location?.coordinate else {return}
        guard let destinationCoodinates = view.destination?.coordinate else {return}
        
        Service.shared.uploadTrip(pickupCoodinates, desitinationCoodinates: destinationCoodinates) { (error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            print("Succecc Trip")
        }
    }
    

}

