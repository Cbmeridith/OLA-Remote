//
//  ColorPickerViewController.swift
//  Pi-Mote
//
//  Created by Cody Meridith on 10/26/16.
//  Copyright © 2016 Cody Meridith. All rights reserved.
//

import Foundation
import UIKit

class ColorPickerViewController: UIViewController
{
    
    @IBOutlet weak var lblColorPicker: UILabel!
    
    var wheelCenter: CGPoint!
    var wheelOutline: CAShapeLayer!
    var zoom: CAShapeLayer!
    var zoomRadius: CGFloat!
    var circlePath: UIBezierPath!
    var wheelRadius: CGFloat!
    var xCenter: CGFloat!
    var yCenter: CGFloat!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        xCenter = self.view.frame.size.width / 2
        yCenter = self.view.frame.size.height / 2
        wheelRadius = CGFloat(180)
        zoomRadius = CGFloat(35)
        
        wheelCenter = CGPoint(x: xCenter, y: yCenter)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: xCenter,y: yCenter), radius: wheelRadius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        wheelOutline = CAShapeLayer()
        wheelOutline.path = circlePath.cgPath
        wheelOutline.fillColor = UIColor.clear.cgColor
        wheelOutline.strokeColor = UIColor.black.cgColor
        wheelOutline.lineWidth = 3.0
        
        let zoomPath = UIBezierPath(arcCenter: CGPoint(x: 0,y: 0), radius: zoomRadius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        zoom = CAShapeLayer()
        zoom.path = zoomPath.cgPath
        zoom.fillColor = UIColor.clear.cgColor
        zoom.strokeColor = UIColor.black.cgColor
        zoom.lineWidth = 3.0
        zoom.isHidden = true

        view.layer.addSublayer(wheelOutline)
        view.layer.addSublayer(zoom)

        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func inCircle(position: CGPoint) -> Bool
    {
        if sqrt(pow(position.x - wheelCenter.x, 2) + pow(position.y - wheelCenter.y,2)) <= wheelRadius
        {
            return true
        }
        return false
    }
    
    func getHue(position: CGPoint, thirdPoint: CGPoint) -> CGFloat
    {
        let verticalDist = abs(thirdPoint.y - position.y)
        let horizontalDist = abs(thirdPoint.x - wheelCenter.x)
        if position.x >= wheelCenter.x && position.y <= wheelCenter.y //first quad
        {
            return atan(verticalDist / horizontalDist) * CGFloat(180/M_PI)
        }
        else if position.x < wheelCenter.x && position.y <= wheelCenter.y //second quad
        {
            return 180 - (atan(verticalDist / horizontalDist) * CGFloat(180/M_PI))
        }
        else if position.x < wheelCenter.x && position.y > wheelCenter.y // third quad
        {
            return 180 + (atan(verticalDist / horizontalDist) * CGFloat(180/M_PI))
        }
        else //forth quad
        {
            return 360 - (atan(verticalDist / horizontalDist) * CGFloat(180/M_PI))
        }
    }

    func getInverseRGB(H: CGFloat, C: CGFloat, X: CGFloat) -> [CGFloat]
    {
        //dividing angle by 60 cuts the circle into 6 segments of 60 degrees
        let region = Int(H / 60)
        
        switch(region)
        {
            case 0: return [C, X, 0]
            case 1: return [X, C, 0]
            case 2: return [0, C, X]
            case 3: return [0, X, C]
            case 4: return [X, 0, C]
            case 5: return [C, 0, X]
            
            default: return [255,255,255]
        }
    }
    
    func getRGB(inverseRGB: [CGFloat], m: CGFloat) -> [Int]
    {
        var RGB = [0,0,0]
        for i in 0...2
        {
            RGB[i] = Int((inverseRGB[i] + m) * CGFloat(255))
        }
        return RGB
    }
    
    func calculateRGB(position: CGPoint) -> [Int]
    {
        let thirdPoint = CGPoint(x: position.x, y: wheelCenter.y) //Point right angle is on
        let verticalDist = abs(thirdPoint.y - position.y)
        let horizontalDist = abs(thirdPoint.x - wheelCenter.x)
        
        let hue = getHue(position: position, thirdPoint: thirdPoint)
        let saturation = sqrt(pow(horizontalDist, 2) + pow(verticalDist,2)) / wheelRadius
        let value = CGFloat(1) //Assume value is 100%. May change later
        
        let C = value * saturation
        let X = C * (1 - abs((hue / 60).truncatingRemainder(dividingBy: 2) - 1))
        let m = value - C
        
        let inverseRGB = getInverseRGB(H: hue,C: C, X: X)
        
        return getRGB(inverseRGB: inverseRGB, m: m)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let position = touch.location(in: self.view)
            if inCircle(position: position)
            {
                let RGB = calculateRGB(position: position)
                
                lblColorPicker.textColor = UIColor(red: CGFloat(RGB[0]) / 255, green: CGFloat(RGB[1]) / 255, blue: CGFloat(RGB[2]) / 255, alpha: 1)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let position = touch.location(in: self.view)
            if inCircle(position: position)
            {
                let RGB = calculateRGB(position: position)
                
                let currentColor = UIColor(red: CGFloat(RGB[0]) / 255, green: CGFloat(RGB[1]) / 255, blue: CGFloat(RGB[2]) / 255, alpha: 1)
                
                lblColorPicker.textColor = currentColor
                
                zoom.position.x = position.x
                zoom.position.y = position.y - (zoomRadius * 2)
                zoom.fillColor = currentColor.cgColor
                zoom.isHidden = false
                
            }
        }
    }
    
    
}
