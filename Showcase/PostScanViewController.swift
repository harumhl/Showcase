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

/******** HMAC algorithm for Amazon REST call Signature ********/
enum HMACAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCHmacAlgorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
extension String {
    func hmac(algorithm: HMACAlgorithm, key: String) -> String {
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        var result = [CUnsignedChar](repeating: 0, count: Int(algorithm.digestLength()))
        CCHmac(algorithm.toCCHmacAlgorithm(), cKey!, Int(strlen(cKey!)), cData!, Int(strlen(cData!)), &result)
        let hmacData:NSData = NSData(bytes: result, length: (Int(algorithm.digestLength())))
        let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
        return String(hmacBase64)
    }
}
/******** (end of) HMAC algorithm for Amazon REST call Signature ********/

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
        SearchButtonClicked()
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
        
        var email = "testing"
        
        let user = Auth.auth().currentUser
        if let user = user {
            email = user.email!
            email = email.substring(to: email.index(of: "@")!)
            print("substring email: ", email)
        }
        
        let locKey = ref.childByAutoId().key
        let bookKey = ref.childByAutoId().key

        let bookData = ["BookID": bookKey, "BookISBN": theBarcodeData, "LocationID": locKey, "Purchased": false ] as [String : Any]
        let locationData = ["LocationID": locKey, "Long": longitudeText.text as String!, "Lat": latitudeText.text as String!]
        let userData = ["bookID": "bookKey"+bookKey]
        
        ref.child("/book/bookKey"+bookKey).setValue(bookData)
        ref.child("/location/loc"+locKey).setValue(locationData)
        
        // dont override a users books
        let bookRef = ref.child(byAppendingPath: "/user/"+email+"/books")
        let thisBookRef = bookRef.childByAutoId()
        thisBookRef.setValue(userData)
        
        
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
    
    func SearchButtonClicked() {
        /* http://docs.aws.amazon.com/AWSECommerceService/latest/DG/rest-signature.html */
        
        // Other ingo
        var itemId = theBarcodeData // = TextField.text!
        
        // 1. Get time stamp ready
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let timeStamp = dateFormatter.string(from: Date()) + "T" +
            timeFormatter.string(from: Date()) + "Z"
        
        // 2. Split parameter-value pairs & Sort by byte value
        //    (not alphabetically, lowercase parameters will be listed after uppercase ones)
        // https://console.aws.amazon.com/iam/home?#/security_credential
        var parameters = ""
        parameters += "AWSAccessKeyId=" + accessKeyId + "&"
        parameters += "AssociateTag=" + associateTag + "&"
        parameters += "IdType=ISBN&"
        parameters += "ItemId=" + itemId + "&"
        parameters += "Operation=ItemLookup&"
        parameters += "SearchIndex=All&"
        parameters += "Service=AWSECommerceService" + "&"
        //parameters += "Sort=relevancerank&"
        parameters += "Timestamp=" + timeStamp + "&"
        parameters += "Version=2013-08-01"
        
        // 3. Encode URL request's comma (,) and colon (:) characters
        parameters = parameters.replacingOccurrences(of: ":", with: "%3A")
        parameters = parameters.replacingOccurrences(of: ",", with: "%2C")
        
        // 4. Get GET request portion for encryption
        let getRequest = "GET\n" + "webservices.amazon.com\n" + "/onca/xml\n"
        
        // 5. Create a string to sign
        let stringToSign = getRequest + parameters
        
        // 6. Sign the string - Generating Signature
        var hmacResult:String = stringToSign.hmac(algorithm: HMACAlgorithm.SHA256, key: accessSecretKey)
        
        // 7. Encode URL request's plus (+) and equal (=) characters
        hmacResult = hmacResult.replacingOccurrences(of: "+", with: "%2B")
        hmacResult = hmacResult.replacingOccurrences(of: "=", with: "%3D")
        
        // 8. Complete the REST call URL
        let theURL = "http://webservices.amazon.com/onca/xml?" + parameters + "&Signature=" + hmacResult
        
        // 9. Display the Rest call URL
        print("The URL: " + theURL + "\n\n")
        
        /* Unpacking the XML (returned) data */
        /* https://grokswift.com/simple-rest-with-swift/ */
        
        // Check the validity of the URL ("guard" checks it)
        guard let url = URL(string: theURL) else {
            print("Error: cannot create URL")
            return
        }
        
        // Start URL session
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        // Unpack the returned XML data
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            let parser = XMLParser(data: responseData)
            if parser.parse() {
                print("Amazon rest call parse success")
                //print(parser.Items.Request.ItemLookupRequest.ItemId)
            }
            else {
                print("parse failure")
            }
            
            // parse the result as JSON, since that's what the API provides
            /*
             do {
             guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
             as? [String: Any] else {
             print("error trying to convert data to JSON")
             return
             }
             // now we have the todo
             // let's just print it to prove we can access it
             print("The todo is: " + todo.description)
             
             // the todo object is a dictionary
             // so we just access the title using the "title" key
             // so check for a title and print it if we have one
             guard let todoTitle = todo["title"] as? String else {
             print("Could not get todo title from JSON")
             return
             }
             print("The title is: " + todoTitle)
             } catch  {
             print("error trying to convert data to JSON")
             return
             }*/
        }
        task.resume()
        
        
        
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
