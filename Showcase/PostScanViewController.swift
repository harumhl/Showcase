//
//  PostScanViewController.swift
//  Showcase
//
//  Created by Brian Ta on 9/18/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI
import Firebase

class PostScanViewController: UIViewController, CLLocationManagerDelegate{
    @IBOutlet weak var barcodeDataField: UILabel!
    var theBarcodeData: String = ""
    var address = ""
    var businessName = ""
    var currentAddr = [String : String]()
    
    @IBOutlet weak var longitudeText: UILabel!
    @IBOutlet weak var latitudeText: UILabel!
    @IBOutlet weak var placeholderText: UILabel!
    
    var longitude = 0.0
    var latitude = 0.0
    
    var ref: DatabaseReference!

    
    // Stuff that runs when the VC is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Print the barcode on a label on the top of the VC
        barcodeDataField.text = theBarcodeData
        barcodeDataField.adjustsFontSizeToFitWidth = true
        getLocation()
        addDataToDB()
    }
    
    // Built in XCode function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//****************************************** USER-DEFINED FUNCTIONS ******************************************

//****************************************** Database Functions **********************************************
    func addDataToDB() {
        ref = Database.database().reference()
        
         var email = "aaa"
        
        let user = Auth.auth().currentUser
        if let user = user {
            email = user.email!
        }
        
        let key = ref.childByAutoId().key
        let key2 = ref.childByAutoId().key

        let bookData = ["BookID": key, "BookISBN": theBarcodeData, "LocationID": key2, "Purchased": false ] as [String : Any]
        
        let locationData = ["LocationID": key2, "Long": longitudeText.text as String!, "Lat": latitudeText.text as String!]
        
        let userData = ["bookID": "bookKey"+key2]
        
        ref.child("/book/bookKey"+key).setValue(bookData)
        ref.child("/location/loc"+key2).setValue(locationData)
        ref.child("/user/"+email+"/books/").setValue(userData)
        
       // print("Data Added:\t" + bookData["BookID"]! + "\t" + bookData["BookISBN"]!)
        print("LocationID:\t" + locationData["LocationID"]!! + "\t" + locationData["Long"]!! + "\t" + locationData["Lat"]!!)
    }
    

//****************************************** GPS Functions ***************************************************
    // gets the GPS longitude and latitude, then passes to function to determine the business you are in
    func getLocation(){
        // get Longitude and Latitude
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        
        if( (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) ||
            (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways)){
            
            //currentLocation = locManager.location
            longitude = (locManager.location?.coordinate.longitude)!
            latitude = (locManager.location?.coordinate.latitude)!
            
            longitudeText.text = "Longitude: \(longitude)"
            latitudeText.text = "Latitude: \(latitude)"
            
            let originLocation = CLLocation(latitude: latitude, longitude: longitude)
            //let originLocation = CLLocation(latitude: 30.626792, longitude: -96.330823)
            //let originLocation = CLLocation(latitude: 30.624211, longitude: -96.329536)
            
            getPlacemark(forLocation: originLocation) {
                (originPlacemark, error) in
                if let err = error {
                    print(err)
                } else if let placemark = originPlacemark {
                    //print(placemark.name)
                    self.placemarkToAddress(placemark: placemark)
                    self.getBusiness()
                }
            }
        } else {
            longitudeText.text = "did not allow gps"
            latitudeText.text = "did not allow gps"
        }
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
    }
    
    // Determines if user is in a bookstore
    func getBusiness(){
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
            print ("getBusiness()\n")
            for item in (response?.mapItems)! {
//                print ("-----------------------\n")
//                print(item.placemark)
//                print("\n")
//                print(item.name!)
//                print("\n")
//                print(item.placemark.title!)
//                print("\n")
                let responseAddr = item.placemark.title!
                if(responseAddr == self.address){
                    print("Found Location\n")
                    buisness = item.name!
                    foundBusn = true

                }
            }
            if(foundBusn){
                print("You are in \(buisness) \n")
                self.placeholderText.text = "placeholder: " + buisness
                self.businessName = buisness
            } else {
                print("Sorry we could not determine your location \n")
                self.placeholderText.text = "placeholder: Sorry we could not determine your location"
            }
        }

    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
