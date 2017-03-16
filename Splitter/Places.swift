//
//  Places.swift
//  Splitter
//
//  Created by Wayne Rumble on 16/03/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import GooglePlaces

class Places {
    
    var placesClient: GMSPlacesClient!
    var nearestBarCafeRestaurant: String?
    
    init() {
        
        placesClient = GMSPlacesClient.shared()
        getNearestBarCafeRestaurant()
    }
    
    func getNearestBarCafeRestaurant() {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            
            if let error = error {
                
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                
                var places = placeLikelihoodList.likelihoods.filter() {
                    
                    if let type = ($0 as GMSPlaceLikelihood).place.types as [String]! {
                        
                        return type.contains("bar") || type.contains("restaurant") || type.contains("cafe")
                    } else {
                        
                        return false
                    }
                }
                
                places.sort {$0.likelihood > $1.likelihood}
                
                self.nearestBarCafeRestaurant = places[0].place.name
            }
        })
    }
}
