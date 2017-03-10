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
    
    let pi = PiStream()
    var pathToSettings: String!
    var settings: NSMutableDictionary!
    
    var wheelCenter: CGPoint!
    var wheelOutline: CAShapeLayer!
    var zoom: CAShapeLayer!
    var zoomRadius: CGFloat!
    var circlePath: UIBezierPath!
    var wheelRadius: CGFloat!
    var xCenter: CGFloat!
    var yCenter: CGFloat!
    var lastSend = Timer.init(timeInterval: 0.25, target: self, selector: Selector(("timeUp")), userInfo: nil, repeats: false)
    var cannotSend = false


    @IBOutlet weak var fieldR: UITextField!
    @IBOutlet weak var fieldG: UITextField!
    @IBOutlet weak var fieldB: UITextField!
    @IBOutlet weak var buttonSend: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        buttonSend.isHidden = true
        xCenter = self.view.frame.size.width / 2
        yCenter = self.view.frame.size.height / 2
        wheelRadius = CGFloat(175)
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
    
    override func viewWillAppear(_ animated: Bool) {
        //get path to Settings plist
        let settingsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let settingsFullDestPath = NSURL(fileURLWithPath: settingsPath).appendingPathComponent("Settings.plist")
        let settingsFullDestPathString = settingsFullDestPath?.path
        pathToSettings = settingsFullDestPathString
        
        //read settings plist
        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)
        
        pi.IP = settings?.value(forKey: "Address") as? String
        pi.openConnection()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fieldR.text = ""
        fieldG.text = ""
        fieldB.text = ""
        pi.closeConnection()
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
    
    func isValidRGB() -> Bool
    {
        let fieldRLength = fieldR.text?.characters.count
        let fieldGLength = fieldG.text?.characters.count
        let fieldBLength = fieldB.text?.characters.count
        
        return (fieldRLength! > 0 && fieldGLength! > 0 && fieldBLength! > 0)
    }
    
    func sendRGB()
    {
        print(cannotSend)
        if(cannotSend){
            print("quitting early")
            return
        } else {
            print("invalidating timer")
            lastSend.invalidate()
            cannotSend = true
            lastSend = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(ColorPickerViewController.timeUp), userInfo: nil, repeats: false)
            
            //must force r,g,b to be non-optional through if-binding
            if let r = fieldR.text, let g = fieldG.text, let b = fieldB.text {
                var RGB = [r, g, b]
                var code = ""
                for i in 0..<RGB.count
                {
                    switch RGB[i].characters.count
                    {
                    case 1: RGB[i] = "00\(RGB[i])"; break;
                    case 2: RGB[i] = "0\(RGB[i])"; break;
                    default: break;
                    }
                    code = "\(code)\(RGB[i])"
                }
                pi.sendCode(code: code, length: code.characters.count)
                //print(code)
            }
        }
    }
    
    func timeUp()
    {
        print("timeUp!!!")
        cannotSend = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let position = touch.location(in: self.view)
            if inCircle(position: position)
            {
                let RGB = calculateRGB(position: position)
                fieldR.text = String(RGB[0])
                fieldG.text = String(RGB[1])
                fieldB.text = String(RGB[2])
            }
        }
        
        buttonSend.isHidden = true
        sendRGB()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let position = touch.location(in: self.view)
            if inCircle(position: position)
            {
                let RGB = calculateRGB(position: position)
                
                fieldR.text = String(RGB[0])
                fieldG.text = String(RGB[1])
                fieldB.text = String(RGB[2])
                
                let currentColor = UIColor(red: CGFloat(RGB[0]) / 255, green: CGFloat(RGB[1]) / 255, blue: CGFloat(RGB[2]) / 255, alpha: 1)
                
                zoom.position.x = position.x
                zoom.position.y = position.y - (zoomRadius * 2)
                zoom.fillColor = currentColor.cgColor
                zoom.isHidden = false
            }
        }
        
        buttonSend.isHidden = true
        sendRGB()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        zoom.isHidden = true
    }
    
    @IBAction func editingBegan(_ sender: UITextField) {
        buttonSend.isHidden = !isValidRGB()
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        let fieldText = sender.text
        let textLength = (sender.text?.characters.count)!
        //check textLength first to avoid exception on Int cast
        if textLength > 0 && (textLength > 3 || Int(fieldText!)! > 255)
        {
            sender.text = fieldText?.substring(to: (fieldText?.index(before: (fieldText?.endIndex)!))!)
        }
        buttonSend.isHidden = !isValidRGB()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        if sender == buttonSend && isValidRGB()
        {
            sendRGB()
            self.view.window?.endEditing(true)
        }
        
    }
    
}
