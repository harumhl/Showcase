//
//  Location.swift
//  Showcase
//
//  Created by Brian Ta on 11/2/17.
//  Copyright © 2017 TamuCpse482. All rights reserved.
//

import Foundation

// The Location class stores the Book's location information
class Location {

    var longitude: Double
    var latitude: Double
    var storeName: String
    var address: String
    var associateTag: String
    
    init() {
        longitude      = -1.0
        latitude       = -1.0
        storeName = "Unidentified Store"
        address = "Address Unavailable"
        associateTag = "AssociateTag Not Available"
    }
    
    init(_long: Double, _lat: Double, _storeName: String, _address: String, _associateTag: String){
        self.longitude      = _long
        self.latitude       = _lat
        self.storeName = _storeName
        self.address = _address
        self.associateTag = _associateTag
    }
    
}
