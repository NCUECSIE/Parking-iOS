//
//  CustomAnnotationView.swift
//  testMapView
//
//  Created by Peter on 2017/5/27.
//  Copyright © 2017年 Peter. All rights reserved.
//

import Foundation
import MapKit



class ClusterAnnotationView: MKAnnotationView {
    var number: Int! = 1
    
    public func setNumber(_ number: Int!) {
        print("number: ")
        print(number)
        self.number = number
    }
    
    override func draw(_ rect: CGRect) {
        
        
        //Keep using the method addLineToPoint until you get to the one where about to close the path
        let number: Int! = self.number
        var size: Int! = number / 10
        if(size > 9) {
            size = 9
        } else if (size <= 0) {
            size = 0
        }
        
        
        
        let string: NSString = "\(number!)" as NSString
        
        
        
        let boundingRect = string.boundingRect(with: frame.size, options: .usesLineFragmentOrigin, attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize)
            ], context: nil)
        
        
        frame = CGRect(x: (bounds.width - boundingRect.width) / 2, y: (bounds.height - boundingRect.height) / 2, width: boundingRect.width, height: boundingRect.height)
        
        // 畫圖囉！
        //frame.size = CGSize(width: size, height: size)
        
        frame.size = CGSize(width: frame.width + CGFloat(size), height: frame.height + CGFloat(size))
        
        layer.backgroundColor = UIColor.clear.cgColor
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2), radius: CGFloat(10 + size), startAngle: CGFloat(0), endAngle:CGFloat(CGFloat.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        let textLayer = CATextLayer()
        textLayer.borderWidth = 0
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.isWrapped = true
        textLayer.isOpaque = false
        textLayer.string = String(number)
        textLayer.fontSize = CGFloat(10 + size)
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.frame = self.frame
        textLayer.position = CGPoint(x: (self.frame.width / 2), y: (self.frame.height / 2) + 2)
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.zPosition = 1
        
        shapeLayer.opacity = 1
        shapeLayer.backgroundColor = UIColor.black.cgColor
        shapeLayer.position = CGPoint(x: 0, y: 0)
        if(size >= 9) {
            shapeLayer.opacity = 0.9
        } else if (size >= 6) {
            shapeLayer.opacity = 0.7
        } else if (size >= 3) {
            shapeLayer.opacity = 0.6
        } else if (size >= 1) {
            shapeLayer.opacity = 0.4
        } else {
            shapeLayer.opacity = 0.2
        }
        print("size: " + String(size))
        
        //you can change the line width
        shapeLayer.lineWidth = 1.0
        shapeLayer.zPosition = 0
        //        shapeLayer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        //        shapeLayer.shadowOffset = CGSize(width: 5, height: 5)
        //        shapeLayer.shadowOpacity = 1
        //        shapeLayer.shadowRadius = 5.0
        
        
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(textLayer)
        
        layer.borderColor = UIColor.clear.cgColor
        layer.isOpaque = false
        layer.borderWidth = 0
        layer.setNeedsDisplay()
        isDraggable = false
    }
}

class SpaceAnnotationView: MKAnnotationView {
    var string: NSString = "P"
    
    override func draw(_ rect: CGRect) {
        let boundingRect = string.boundingRect(with: frame.size, options: .usesLineFragmentOrigin, attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize)
            ], context: nil)
        
        frame = CGRect(x: (bounds.width - boundingRect.width) / 2, y: (bounds.height - boundingRect.height) / 2, width: boundingRect.width, height: boundingRect.height)
        // 畫圖囉！
        //frame.size = CGSize(width: size, height: size)
        
        frame.size = CGSize(width: 20, height: 20)
        
        layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        layer.isOpaque = false
        layer.borderWidth = 2
        layer.cornerRadius = 5
        layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        layer.setNeedsDisplay()
        isDraggable = true
        
        string.draw(in: frame, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize)])
    }
    
}
