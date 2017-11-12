//
//  YakModel.swift
//  CloudYak
//
//  Created by Jack Frysinger on 7/28/17.
//  Copyright © 2017 Jack Frysinger. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit

class YakModel : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    public var delegate: YakModelDelegate?
    
    let publicDb = CKContainer.default().publicCloudDatabase
    
    var recentResults = [String]()
    
    override init() {
        super.init()
        
        locationManager.delegate = self;
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization();
        }
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation();
        } else {
            delegate?.userLocationNotAvailable();
        }
    }
    
    public func refreshYaks() {
        if let l = locationManager.location {
            let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f", "location", l, 1.0)
            let query = CKQuery(recordType: "Yak", predicate: locationPredicate)
            publicDb.perform(query, inZoneWith: nil) {results, error in
                if let r = results {
                    self.recentResults = r.map({$0.object(forKey: "text") as! String})
                    self.delegate?.didRefreshYaks()
                } else {
                    self.delegate?.failedToRefreshYaks()
                }
            }
        }
    }
    
    public func postYak(message: String) {
        if let l = locationManager.location {
            let type = CKRecord(recordType: "Yak")
            type.setValue(message, forKey: "text")
            type.setObject(l, forKey: "location")
            self.publicDb.save(type) {record, error in
                if let e = error {
                    print(e)
                    self.delegate?.failedToPostYak()
                } else {
                    self.delegate?.didPostYak()
                }
            }
        } else {
            delegate?.userLocationNotAvailable()
        }
    }
    
}

protocol YakModelDelegate {
    
    func didRefreshYaks();
    
    func failedToRefreshYaks();
    
    func didPostYak();
    
    func failedToPostYak();
    
    func userLocationNotAvailable();
}
