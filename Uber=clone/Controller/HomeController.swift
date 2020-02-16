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
private enum AnnotaionType : String {
    case pickUp
    case destination
}

// for Side Menu

protocol HomeControllerDelegate : class {
    func handleMenuTpggle()
}

class HomeController : UIViewController {
    
    private let mapview = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let rideActionView = RideActionView()
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    
    weak var delegate : HomeControllerDelegate?
    
    var user : FUser? {
        didSet {
            guard let user = user else {return}
            self.locationInputView.titleLabel.text = user.fullname
            
            if user.accountType == .passanger {
                fetchDrivers()
                configureLocationActivationView()
                // for passanger
                observeCurrentTrip()
            } else {
                // Driver
                obserbeTrips()
            }
        }
    }
    
    private var trip : Trip? {
        didSet {
            
            guard let user = user else {return}
            
            if user.accountType == .passanger {
                print("Passanger trip")
            } else {
                guard let trip = trip else {return}
                
                
                let controller = PickupController(trip: trip)
                controller.delegate = self
                
                if #available(iOS 13.0, *) {
                    controller.modalPresentationStyle = .fullScreen
                }
                
                self.present(controller, animated: true, completion: nil)
                
            }
            
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
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.isHidden = true
        // check Login
        
        enableLocationaService()
        configureUI()
        
        
       
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else {
            print("no Trip")
            return}
        
       
    }
    
    //MARK: - API
    
   
    
    func fetchDrivers() {
        // throw if user is passanger
//        guard user?.accountType == .passanger else {
//            print("User is Driver")
//            return}
    
        guard let location = locationManager?.location else {return}
        PassangerService.shared.fetchDrivers(location: location) { (driver) in
            // 座標
            guard let coodinate = driver.location?.coordinate else {return}
            let driverAnnotation = DriverAnnotation(_uid: driver.uid, _coodinate: coodinate)
            
            var driverIsVisble : Bool {
                
                return self.mapview.annotations.contains { (annotation) -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else {return false}
                    
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(withCoodinate: coodinate)
                        self.zoomForActiveTrip(withDriverUid: driver.uid)
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
    
    //MARK: - Passanger API
    
    func observeCurrentTrip() {
        
        PassangerService.shared.observeCurrentTrip { (trip) in
            self.trip = trip
            guard let state = trip.state else {return}
            
            switch state {
                
            case .requested:
                break
            case .accepted:
                // dismiss Indicator
                self.shouldPresentLoadingView(false)
                self.removeAnnotaionsandOverlays()
        
                guard let drierUid = trip.driverUid else {
                    print("noDriver")
                    return}
                
                 // remove annotation except pickup driver & current User
                self.zoomForActiveTrip(withDriverUid: drierUid )
                
                Service.shared.fetchUserData(uid: drierUid) { (driver) in
                    self.animateRideActionView(shoudShow: true, config: .tripAccepted, user: driver)
                }
                
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .arrivedDestination :
                self.rideActionView.config = .endTrip
            case .completed:
              
                // Complete!
                PassangerService.shared.deleteTrip { (error) in
                    self.animateRideActionView(shoudShow: false)
                    self.centerMapOnUserLocation()
                    self.inputActivationView.alpha = 1
                    // return Show Menu
                    self.configureActionButton(config: .showMenu)
                    self.presentAlertController(withTitle: "Complete!", withMessage: "Thanks For Use")
                    
                }
            }
            
        }
    }
    
    func startTrip() {
        guard let trip = self.trip else {return}
        
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { (error) in
            
            if error != nil {
                print("Can't Start \(error!.localizedDescription))")
            }
            self.rideActionView.config = .tripInProgress
            self.removeAnnotaionsandOverlays()
            self.mapview.addAnnotationAndSelect(forCoodinate: trip.destinationCoodenates)
            
            let placeMark = MKPlacemark(coordinate: trip.pickupCoodinates)
            let mapItem = MKMapItem(placemark: placeMark)
            
            self.setCustomUserRegion(withType: .destination, withCoodinates: trip.destinationCoodenates)
            
            self.generatePolyLine(toDestination: mapItem)
            
            self.mapview.zoomToFit(annotations: self.mapview.annotations)
        }
    }
    
    //MARK: - Driver API
    func obserbeTrips() {
        DriverService.shared.obserebeTrip { (trip) in
            self.trip = trip
        }
    }
    
    func observeCancelTrip(trip : Trip) {
        DriverService.shared.observeTripCancelled(trip: trip) { (exist) in
            if !exist {
                self.removeAnnotaionsandOverlays()
                self.animateRideActionView(shoudShow: false)
                self.centerMapOnUserLocation()
            }
        }
    }
    
    //MARK: - Selectors
    
    @objc func seleceActionButtonPressed() {
        
        switch actionButtonConfigure {
        case .showMenu:
            // container Controller
            delegate?.handleMenuTpggle()
            
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
    
   

    
    //MARK: - Helpers
    
    
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
    
    func animateRideActionView(shoudShow : Bool, destination : MKPlacemark? =  nil, config : RidectionViewConfiguration? = nil, user : FUser? = nil) {
        
        if shoudShow {
            
            guard let config = config else {return}
            
            
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height - self.rideActionViewHeight
            }
            
//            guard let destination = destination else {return}
            if let destination = destination {
                rideActionView.destination = destination
            }
            
            if let user = user {
                rideActionView.user = user
            }
            
            rideActionView.config = config
        } else {
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
            
        }
        
        //        let  yOrigin = shoudShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
    }
    
    
    
    
}

//MARK: - Mapview Helper
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
    
    //MARK: - Remove Direction Line
    
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
    
    func centerMapOnUserLocation() {
        guard let coodinate = locationManager?.location?.coordinate else {return}
        
        let region = MKCoordinateRegion(center: coodinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapview.setRegion(region, animated: true)
    }
    
    func setCustomUserRegion(withType type : AnnotaionType,  withCoodinates coodenates : CLLocationCoordinate2D) {
        
        let region = CLCircularRegion(center: coodenates, radius: 25, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
        
        print("\(region)")
    }
    
    func zoomForActiveTrip(withDriverUid driverUid : String) {
       
        var annotations = [MKAnnotation]()
        self.mapview.annotations.forEach { (annotation) in
            
            if let anno  = annotation as? DriverAnnotation {
                if anno.uid == driverUid {
                    annotations.append(anno)
                }
            }
            
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        }
        self.mapview.zoomToFit(annotations: annotations)
        
        print(annotations)
    }
    
    
    
}

//MARK: - Mapview delegate

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
    
    // Real time User Locaction
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard  let user = self.user else {return}
        guard  user.accountType == .driver else {return}
        guard let location = userLocation.location else {return}
        
        DriverService.shared.updateDriverLocation(location: location)
    }
    
}


extension HomeController : CLLocationManagerDelegate{
    
    func enableLocationaService() {
        
        locationManager?.delegate = self
        
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
    
    // locationManager delegate
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        if region.identifier == AnnotaionType.pickUp.rawValue {
            print("Pickup Region\(region)")
        }
        
        if region.identifier == AnnotaionType.destination.rawValue {
            print("destination Region\(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        print("passanger region")
        guard let trip = self.trip else {return}
        
        if region.identifier == AnnotaionType.pickUp.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { (error) in
                
                if error != nil {
                    print("Can't update \(error!.localizedDescription)")
                }
                
                self.rideActionView.config = .pickupPassanger
            }
        }
        
        if region.identifier == AnnotaionType.destination.rawValue {
            DriverService.shared.updateTripState(trip: trip, state: .arrivedDestination) { (error) in
                
                if error != nil {
                    print("Can't update \(error!.localizedDescription)")
                }
                self.rideActionView.config = .endTrip
            }
        }
        
        
        
        
        
    }
    
}

//MARK: - Activation VIew Delegate

extension HomeController : LocationInputActivationViewDelegate {
    
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
}

//MARK: - InputVIew Delegate

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

//MARK: - tableView delegate

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
        
        self.mapview.addAnnotationAndSelect(forCoodinate: selectedPlaceMark.coordinate)
        
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
        
        animateRideActionView(shoudShow: true, destination: selectedPlaceMark, config: .requestRide)
        
        // pass
//        rideActionView.destination = selectedPlaceMark
        
    }
    

    
}

//MARK: - PickupCOntroller Delegate

extension HomeController : PickupControllerDelegate {
    
    func didAcceptTrip(_ trip: Trip) {
        self.trip?.state = .accepted
        
        mapview.addAnnotationAndSelect(forCoodinate: trip.pickupCoodinates)
        
        self.setCustomUserRegion(withType: .pickUp, withCoodinates: trip.pickupCoodinates)
        
        let placeMark = MKPlacemark(coordinate: trip.pickupCoodinates)
        let mapItem = MKMapItem(placemark: placeMark)
        
        generatePolyLine(toDestination: mapItem)
        
        
        mapview.zoomToFit(annotations: mapview.annotations)
        
        // check trip has Cancel
        
       observeCancelTrip(trip: trip)
     
        
        Service.shared.fetchUserData(uid: trip.passangerUId) { (passanger) in
            self.animateRideActionView(shoudShow: true, config: .tripAccepted, user: passanger)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}

extension HomeController : RideActionViewDelegate {

    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoodinates = locationManager?.location?.coordinate else {return}
        guard let destinationCoodinates = view.destination?.coordinate else {return}
        
        // Indicator View
        shouldPresentLoadingView(true, message: "Finding you a ride...")
        
        PassangerService.shared.uploadTrip(pickupCoodinates, desitinationCoodinates: destinationCoodinates) { (error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            // hide rideActionView
            
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
            
        }
    }
    
    func cancelTrip() {
        
        // delete Trip
        PassangerService.shared.deleteTrip { (error) in
            
            if error != nil {
                print("Couldn't delete Trip")
                return
            }
            self.animateRideActionView(shoudShow: false)
            self.removeAnnotaionsandOverlays()
            self.centerMapOnUserLocation()
            // show Error Alert
            self.presentAlertController(withTitle: "Oops Passange has decided Cancel", withMessage: "Passanger Cancel" )
            
            // return Show Menu
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfigure = .showMenu
            
            self.locationInputView.alpha = 1
            
            
        }
    }
    
    func pickUpPassanger() {
        startTrip()
    }
    
    func dropOffPassanger() {
        
        guard let trip = self.trip else {return}
        DriverService.shared.updateTripState(trip: trip, state: .completed) { (error) in
            if error != nil {
                print("Couldn't Complete")
                return
            }
            
            // Complete!!
            self.removeAnnotaionsandOverlays()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shoudShow: false)
            
            
        }
    }
    

}

