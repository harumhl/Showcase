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


class PostScanViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var barcodeDataField: UILabel!
    var theBarcodeData: String = ""
    
    @IBOutlet weak var longitudeText: UILabel!
    @IBOutlet weak var latitudeText: UILabel!
    @IBOutlet weak var placeholderText: UILabel!
    
    var longitude = 0.0
    var latitude = 0.0
    
    // Stuff that runs when the VC is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Print the barcode on a label on the top of the VC
        barcodeDataField.text = theBarcodeData
        barcodeDataField.adjustsFontSizeToFitWidth = true
        getLocation()
    }
    
    // Built in XCode function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // gets Longitude and Latitude
    func getLocation(){
        // var locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        
        // var currentLocation = CLLocation!.self
        if( (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) ||
            (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways)){
            
            //currentLocation = locManager.location
            longitude = (locManager.location?.coordinate.longitude)!
            latitude = (locManager.location?.coordinate.latitude)!
            
            longitudeText.text = "Longitude: \(longitude)"
            latitudeText.text = "Latitude: \(latitude)"
            
            reverseGeocoding(latitude: latitude, longitude: longitude)
        } else {
            longitudeText.text = "did not allow gps"
            latitudeText.text = "did not allow gps"
        }
    }
    
    // converts Longitude and Latitude into a Placemaker
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print(error ?? "WUB A DUB DUB DUB")
                return
            }
            else if (placemarks?.count)! > 0 {
                let pm = placemarks![0]
                let address = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
                //let address = CNPostalAddressFormatter(pm.addressDictionary!, false)
                
                print("\n\(address)")
                
                /*
                if (pm.areasOfInterest != nil && (pm.areasOfInterest?.count)! > 0){
                    
                    if(pm.areasOfInterest?[0] == nil){
                        print("this thing is nil")
                    } else{
                        let areaOfInterest = pm.areasOfInterest?[0]
                        self.placeholderText.text = areaOfInterest
                    }
                    
                } else {
                    self.placeholderText.text = "Sorry, No placemarker found"
                    print("No area of interest found.")
                }
                */
            }
        })
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