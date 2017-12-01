//
//  RootViewController.swift
//  Showcase
//
//  Created by Brandon Ellis on 9/21/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import MapKit
import CoreLocation
import AddressBookUI
import FacebookCore
import FacebookLogin

var locManager: CLLocationManager!

class RootViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var userNameLabel: UILabel!
    var address: String = ""
    var businessName: String = ""
    var currentAddr = [String : String]()
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    var myLoc = Location()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Remove te "back" button 
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        // asking for location permissions
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        var email = getUser().email
        var shortEmail = ""
        let letters = CharacterSet.letters
        let digits = CharacterSet.decimalDigits

        if email == "" {
            let myGroup = DispatchGroup() // Wait till email is fetched
            myGroup.enter()
            // The user is signed in with FaceBook
            let req = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET, apiVersion: FacebookCore.GraphAPIVersion.defaultVersion)
            req.start({ (response, result) in
                switch result {
                case .success(let graphResponse) :
                    if let resultDict = graphResponse.dictionaryValue {
                        email = resultDict["email"] as! String
                        print("FB Email1: ", email)
                        myGroup.leave()
                    }
                case .failed(_): break
                }
            })
            myGroup.notify(queue: .main) {
                print("FB Email2: ", email)
                shortEmail = email.substring(to: email.index(of: "@")!)
                var tempEmail = ""
                // Remove special characters from the email (Firebase)
                for c in shortEmail.unicodeScalars {
                    if letters.contains(c) || digits.contains(c) {
                        tempEmail += String(UnicodeScalar(c))
                    }
                }
                shortEmail = tempEmail
                self.userNameLabel.text = shortEmail
            }
        } else {
            // Regular login
            shortEmail = email.substring(to: email.index(of: "@")!)
            var tempEmail = ""
            // Remove special characters from the email (Firebase)
            for c in shortEmail.unicodeScalars {
                if letters.contains(c) || digits.contains(c) {
                    tempEmail += String(UnicodeScalar(c))
                }
            }
            shortEmail = tempEmail
            self.userNameLabel.text = shortEmail
        }
    }
    
    
    @IBAction func toScanner(_ sender: Any) {
        // get user location
        self.getLocation{ () -> () in
            print("prepare: a:\(self.address) b:\(self.businessName) lo:\(self.longitude) la:\(self.latitude)")
            let scannerVC: ScannerViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
            //let scannerVC = ScannerViewController()
            // pass the address long and lat and business name
            self.myLoc = Location(_long: self.longitude, _lat: self.latitude, _storeName: self.businessName, _address: self.address, _associateTag: "null")
            
            scannerVC.myLoc = self.myLoc
            self.navigationController?.pushViewController(scannerVC, animated: true)
            
            findStoreAssociateTag(address: self.myLoc.address, location: self.myLoc, handleComplete: {
                //send notification to PostScan
                let notifRefreshTag = Notification.Name("refreshTag")
                NotificationCenter.default.post(name: notifRefreshTag, object: nil)
            })
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide the navigation controller bar
        self.navigationController?.isNavigationBarHidden = false
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // When user responds to Locations preferences
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    
    // ****************************************** GPS Functions ***************************************************
    // gets the GPS longitude and latitude, then passes to function to determine the business you are in
    func getLocation(handleComplete:@escaping (()->())){
        //func getLocation(){
        // get Longitude and Latitude
        locManager.delegate = self as! CLLocationManagerDelegate
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        
        if( (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) ||
            (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways)){
            
            //currentLocation = locManager.location
            longitude = (locManager.location?.coordinate.longitude)!
            latitude = (locManager.location?.coordinate.latitude)!
            
            // let originLocation = CLLocation(latitude: latitude, longitude: longitude)
            let originLocation = CLLocation(latitude: 30.626792, longitude: -96.330823)
            //let originLocation = CLLocation(latitude: 30.624211, longitude: -96.329536)
            
            getPlacemark(forLocation: originLocation) {
                (originPlacemark, error) in
                if let err = error {
                    print(err)
                } else if let placemark = originPlacemark {
                    //print(placemark.name)
                    self.placemarkToAddress(placemark: placemark)
                    print("done getting address")
                    self.getBusiness{ () -> () in
                        print("handleComplete address \(self.businessName)")
                        handleComplete()
                    }
                    
                    print("done getting business")
                }
            }
        } else {
            
            // Ask Brian how did a pop up
            print("did not allow gps")
        }
        
        //wait a little bit for the gps to get the book store address.
        //         let when = DispatchTime.now() + 1.5
        //         DispatchQueue.main.asyncAfter(deadline: when) {
        //            print("handle complete")
        //            //handleComplete()
        //         }
        
    }
    
    // Gets the placemarker data
    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            
            if let err = error {
                completionHandler(nil, err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    completionHandler(placemark, nil)
                } else {
                    completionHandler(nil, "Placemark was nil")
                }
            } else {
                completionHandler(nil, "Unknown error")
            }
        })
    }
    
    
    // Converts placemarker to a physical address
    func placemarkToAddress(placemark: CLPlacemark) -> Void{
        self.address = ""
        print("Start placemarkToAddress")
        // Location name
        if let locationName = placemark.addressDictionary?["Name"] as? String {
            self.address += locationName + ", "
            currentAddr["locationName"] = locationName
        }
        
        // Street address
        // if let street = placemark.addressDictionary?["Thoroughfare"] as? String {
        //      self.address += street + ", "
        //      currentAddr["street"] = street
        // }
        
        // City
        if let city = placemark.addressDictionary?["City"] as? String {
            self.address += city + ", "
            currentAddr["city"] = city
        }
        if let state = placemark.addressDictionary?["State"] as? String {
            self.address += state + "  "
            currentAddr["state"] = state
        }
        
        // Zip code
        if let zip = placemark.addressDictionary?["ZIP"] as? String {
            self.address += zip + ", "
            currentAddr["zip"] = zip
        }
        
        // Country
        if let country = placemark.addressDictionary?["Country"] as? String {
            self.address += country
            currentAddr["country"] = country
        }
        
        print("Done placemarkToAddress \(self.address)")
        
    }
    
    // Determines if user is in a bookstore
    //func getBusiness(){
    func getBusiness(handleComplete:@escaping (()->())){
        print("start getBusiness")
        //https://stackoverflow.com/questions/42570636/can-i-get-a-store-name-restaurant-name-with-mapkitswift
        //https://www.youtube.com/watch?v=VZZ76kAdhNA
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "bookstores"  // or whatever you're searching for
        request.region = MKCoordinateRegion()
        request.region.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        var buisness = ""
        var foundBusn = false
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            
            // Prints out a list of the bookstores around you
            //print(response?.mapItems)
            print ("-----------------------")
            //print ("getBusiness()\n")
            for item in (response?.mapItems)! {
                let responseAddr = item.placemark.title!
                if(responseAddr == self.address){
                    print("Found Location\n")
                    buisness = item.name!
                    foundBusn = true
                }
            }
            if(foundBusn){
                print("You are in \(buisness) \n")
                self.businessName = buisness
                print("placeholder: " + self.businessName)
                handleComplete()
            } else {
                //print("Sorry we could not determine your location \n")
                print("placeholder: Sorry we could not determine your location"
                    + "\n-----------------------")
                handleComplete()
            }
        }
        print("done getBusiness")
        
    }
    
}
