//
//  customAnnotation.swift
//  testMapView
//
//  Created by Peter on 2017/5/26.
//  Copyright © 2017年 Peter. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CustomClusterAnnotation: MKPointAnnotation {
    public var number: Int! = 0
    
    required init(_ number: Int!) {
        self.number = number
    }
    
    public func getNum() -> Int?{
        if number != 0 {
            return self.number!
        } else {
            return nil
        }
    }
}

class CustomSpaceAnnotation: MKPointAnnotation {
    
}
