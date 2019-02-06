//
//  EarthquakePointAnnotation.swift
//  earthquake-catalog-api
//
//  Created by Robby King on 2/4/19.
//  Copyright © 2019 Robby King. All rights reserved.
//

import UIKit
import MapKit

class EarthquakePointAnnotation: MKPointAnnotation {    
    var detailsURL: String
    init(detailsURL: String) {
        self.detailsURL = detailsURL
        super.init()
    }
}
