//
//  LoadScanViewController.swift
//  Showcase
//
//  Created by ellisbrandon20 on 10/9/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI
import SwiftyXMLParser
import SwiftSoup
import Firebase

/******************************** HMAC algorithm for Amazon REST call Signature ********************************/
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
/******************************** (end of) HMAC algorithm for Amazon REST call Signature ******************************/


class LoadScanViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLbl: UILabel!
    
    var theBarcodeData: String = ""
    
    var address: String = ""
    var businessName: String = ""
    var currentAddr = [String : String]()
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    
    var scanBookArray = [Book]()
    var bookToPass: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start the spinning of the inidicator - stop it if we show the table
        self.loadingIndicator.hidesWhenStopped = true
        self.loadingIndicator.startAnimating()
        
        // user defined functions
        self.getLocation{ () -> () in
            // using closures to construct our object then perform the function selectBook()
            self.amazonSearch { () -> () in
                //self.getReviewsFromReviewURL() // TEMP TEMP TEMP
                self.selectBook()
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(scanBookArray.count == 1){
            let postScanVC: PostScanViewController = segue.destination as! PostScanViewController
            // Pass in the Book object that the user selects
            postScanVC.bookData = scanBookArray[bookToPass]
            print("segue")
            print(self.address)
            postScanVC.storeAddress = self.address
        }else if(scanBookArray.count > 1){
            let resultsTblVC: ResultsViewController = segue.destination as! ResultsViewController
            resultsTblVC.scanBookArray = scanBookArray
            resultsTblVC.storeAddress = self.address
        }
    }
    
    // ACTION - If only one book - perform segue to PostScanViewController for the user..
    //          otherwise we will display a table of the matching books we found and give them the option
    func selectBook() {
        if(scanBookArray.count == 1){
            // send the book data to the controller using prepare()
            bookToPass = 0
            performSegue(withIdentifier: "LoadToPost", sender: nil)
        }else if(scanBookArray.count > 1){
            // hide load label and animaiton
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true
            self.loadingLbl.isHidden = true
            
            // load the table with scanBookArray
            // segue to resultstable view controller
            performSegue(withIdentifier: "LoadToResults", sender: nil)
        } else{
            // OOPS we did not find there book.
            // segue to the scanner or the main menu and notify user that we did not find the book
        }
    }
    
// ****************************************** GPS Functions ***************************************************
    // gets the GPS longitude and latitude, then passes to function to determine the business you are in
    func getLocation(handleComplete:@escaping (()->())){
        // get Longitude and Latitude
        locManager.delegate = self as! CLLocationManagerDelegate
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        
        if( (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) ||
            (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways)){
            
            //currentLocation = locManager.location
            longitude = (locManager.location?.coordinate.longitude)!
            latitude = (locManager.location?.coordinate.latitude)!
            
            //print("Longitude: \(longitude)")
            //print("Latitude: \(latitude)")
            
            //let originLocation = CLLocation(latitude: latitude, longitude: longitude)
            let originLocation = CLLocation(latitude: 30.626792, longitude: -96.330823)
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
            
            // Ask Brian how did a pop up
            print("did not allow gps")
        }
        handleComplete()
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
            //print ("getBusiness()\n")
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
                print("placeholder: " + buisness)
                self.businessName = buisness
            } else {
                //print("Sorry we could not determine your location \n")
                print("placeholder: Sorry we could not determine your location"
                        + "\n-----------------------")
            }
        }
        
    }
  
    
// ****************************************** Book Search Functions ***************************************************
    func amazonSearch(handleComplete:@escaping (()->())) {
        /* http://docs.aws.amazon.com/AWSECommerceService/latest/DG/rest-signature.html */
        
        // Other ingo
        var itemId = theBarcodeData
        
        // 1. Get time stamp ready
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
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
        parameters += "ResponseGroup=Images,ItemAttributes,Reviews&"
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
        print("The URL: " + theURL + "\n-----------------------")
        
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
            // SwiftyXMLParser convert the XML data into an array of Book objects
            let xml = XML.parse(data!)
            let requestId = xml["ItemLookupResponse"]["OperationRequest"]["RequestId"].text
            
            // this is the list of items or books in the reponse
            let responseItems = xml["ItemLookupResponse"]["Items"]
            
            // loop through responseItems to find the correct Book
            for items in xml["ItemLookupResponse", "Items", "Item"]{
                let itemAttributes = items["ItemAttributes"]
                var itemISBN = "-1"
                itemISBN ?= itemAttributes["EAN"].text
                
                // create a book object when a match is found (can be more than one)
                if(itemISBN != nil && itemId == itemISBN){
                    var title = "Title Not Available"
                    title ?= itemAttributes["Title"].text!
                    
                    var author = "Author Not Available"
                    author ?= itemAttributes["Author"].text!
                    
                    let ISBN = self.theBarcodeData
                    
                    var price = "Price Not Available"
                    price ?= itemAttributes["ListPrice", "FormattedPrice"].text
                    
                    var imageURL = "DefaultImage.jpg"
                    imageURL ?= items["MediumImage", "URL"].text
                    
                    var reviewURL = "Reviews Not Available"
                    
                    for itemLink in items["ItemLinks", "ItemLink"]{
                        if (itemLink["Description"].text == "All Customer Reviews"){
                            reviewURL ?= itemLink["URL"].text
                        }
                    }
                    
                    let dateCreatedAt = dateFormatter.string(from: Date()) + " " +
                        timeFormatter.string(from: Date())
                    
                    let secsSince1970 = UInt(Date().timeIntervalSince1970)
                    
                    print("Book was created at: ", dateCreatedAt)
                    
                    var purchaseURL = "Purchase URL Not Available"
                    purchaseURL ?= items["DetailPageURL"].text
                    
                    var ASIN = "ASIN Not Available"
                    ASIN ?= items["ASIN"].text
                    
                    let tmpBook = Book.init(_title: title, _author: author, _ISBN: ISBN, _price: price, _imageURL: imageURL, _rating: -1, _reviewURL: reviewURL,
                                            _DateCreatedAt: dateCreatedAt, _SecondsSince1970: secsSince1970, _purchaseURL: purchaseURL, _ASIN: ASIN)
                    
                    // insert item into array of books
                    self.scanBookArray.append(tmpBook)
                    //print("book: Found a Match")
                    
                }
                else{
                    print("NOPE NOTE EQUAL")
                }
            }
            handleComplete()
            //print("CHECK THE BOOKS")
            
            // This stores the author, book title, etc
            let responseBook = responseItems["Item"]["ItemAttributes"]
        }
        task.resume() // start the XML parser
    }
    
    
    
    
    
    
    
    // Will not be used
    /*
    func goodReadsSearch(handleComplete:(()->())) {
        // https://www.goodreads.com/api
        var theURL = "https://www.goodreads.com/book/isbn/ISBN?"
        theURL += "format=xml&"
        theURL += "key=" + goodReadsKey + "&"
        theURL += "isbn=" + theBarcodeData
        print("good reads URL: " + theURL)
        
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
                print("GoodReads HTTP call parse success")
                //print(parser.Items.Request.ItemLookupRequest.ItemId)
            }
            else {
                print("GoodReads HTTP call parse failure")
            }
            
            // data gives:
            // author, book title, image url default size and small
            let xml = XML.parse(data!)
        }
        task.resume()
        handleComplete()
    } */ // End of goodReadsSearch()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
