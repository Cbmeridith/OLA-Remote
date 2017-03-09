//
//  MainViewController.swift
//  Pi-Mote
//
//  Created by Cody Meridith on 10/24/16.
//  Copyright © 2016 Cody Meridith. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    let pi = PiStream()
    var pathToSettings: String!
    var pathToButtons: String!
    var settings: NSMutableDictionary!
    var buttonCodes: NSMutableDictionary!
    var buttons: [UIButton]!
    
    //TODO: store color of light buttons in array for expandibility
    var lights = [false, false, false, false]

    @IBOutlet weak var buttonOff: UIButton!
    @IBOutlet weak var buttonOn: UIButton!
    
    @IBOutlet weak var buttonLight0: UIButton!
    @IBOutlet weak var buttonLight1: UIButton!
    @IBOutlet weak var buttonLight2: UIButton!
    @IBOutlet weak var buttonLight3: UIButton!
                                            //Default Function:
    @IBOutlet weak var button0: UIButton!   //Movie
    @IBOutlet weak var button1: UIButton!   //Swap
    @IBOutlet weak var button2: UIButton!   //Random
    @IBOutlet weak var button3: UIButton!   //NightMode
    @IBOutlet weak var button4: UIButton!   //Red
    @IBOutlet weak var button5: UIButton!   //Green
    @IBOutlet weak var button6: UIButton!   //Blue
    @IBOutlet weak var button7: UIButton!   //SoftWhite
    @IBOutlet weak var button8: UIButton!   //Orange
    @IBOutlet weak var button9: UIButton!   //Purple
    @IBOutlet weak var button10: UIButton!  //Cyan
    @IBOutlet weak var button11: UIButton!  //BrightUp
    @IBOutlet weak var button12: UIButton!  //Yellow
    @IBOutlet weak var button13: UIButton!  //Pink
    @IBOutlet weak var button14: UIButton!  //White
    @IBOutlet weak var button15: UIButton!  //BrightDown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Decide on color
        buttonLight0.backgroundColor = UIColor.lightGray;
        buttonLight1.backgroundColor = UIColor.lightGray;
        buttonLight2.backgroundColor = UIColor.lightGray;
        buttonLight3.backgroundColor = UIColor.lightGray;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let fileManager = FileManager.default
        
        //copy SETTINGS plist file
        let settingsPath = Bundle.main.path(forResource: "Settings", ofType: "plist")
        let settingsDestPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let settingsFullDestPath = NSURL(fileURLWithPath: settingsDestPath).appendingPathComponent("Settings.plist")
        let settingsFullDestPathString = settingsFullDestPath?.path
        pathToSettings = settingsFullDestPathString
        
        do{
            try fileManager.copyItem(atPath: settingsPath!, toPath: settingsFullDestPathString!)
        }catch{
            print("\n")
            print(error) // file already exists (most likely)
        }

        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)
        
        
        //copy BUTTONS plist file
        let buttonsPath = Bundle.main.path(forResource: "Buttons", ofType: "plist")
        let buttonsDestPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let buttonsFullDestPath = NSURL(fileURLWithPath: buttonsDestPath).appendingPathComponent("Buttons.plist")
        let buttonsFullDestPathString = buttonsFullDestPath?.path
        pathToButtons = buttonsFullDestPathString
        
        do{
            try fileManager.copyItem(atPath: buttonsPath!, toPath: buttonsFullDestPathString!)
        }catch{
            print("\n")
            print(error) // file already exists (most likely)
        }
        
        buttonCodes = NSMutableDictionary(contentsOfFile: pathToButtons!)
        
        
        
        pi.IP = settings?.value(forKey: "Address") as? String
        pi.openConnection()
        
        //put all buttons in array for easy referencing
        buttons = [button0, button1, button2, button3, button4, button5, button6, button7, button8, button9, button10, button11, button12, button13, button14, button15]
        
        //pull RGB from assigned code for each button and set the background color of the button
        for i in 0...buttons.count - 1 {
            let currentCode = buttonCodes?.value(forKey: String(i)) as! String
            //RGB codes are 9 characters in length, set button color to RGB code
            //format: RRRGGGBBB
            if currentCode.characters.count == 9 {
                var startIndex = currentCode.startIndex
                var endIndex = currentCode.index(startIndex, offsetBy: 3)
                //no conversion from String -> CGFloat, must go String -> Float -> CGFloat
                let r = CGFloat(Float(currentCode.substring(with: startIndex ..< endIndex))!)
                
                startIndex = endIndex
                endIndex = currentCode.index(startIndex, offsetBy: 3)
                let g = CGFloat(Float(currentCode.substring(with: startIndex ..< endIndex))!)
                
                startIndex = endIndex
                endIndex = currentCode.index(startIndex, offsetBy: 3)
                let b = CGFloat(Float(currentCode.substring(with: startIndex ..< endIndex))!)
                
                buttons[i].backgroundColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
                
                //print("\(r), \(g), \(b)")
            }
            //Code is a function, set button to corresponding image
            else {
                switch currentCode {
                case "MOVIE": buttons[i].setImage(#imageLiteral(resourceName: "Movie"), for: .normal); break;
                    case "SWAP": buttons[i].setImage(#imageLiteral(resourceName: "Swap"), for: .normal); break;
                    case "RANDOM": buttons[i].setImage(#imageLiteral(resourceName: "Rand"), for: .normal); break;
                    case "NIGHT": buttons[i].setImage(#imageLiteral(resourceName: "Flux"), for: .normal); break;
                    case "BRIGHTUP": buttons[i].setImage(#imageLiteral(resourceName: "BrightUp"), for: .normal); break;
                    case "BRIGHTDOWN": buttons[i].setImage(#imageLiteral(resourceName: "BrightDown"), for: .normal); break;
                    default: print("Code Not Recognized!"); break;
                }
            }
            
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pi.closeConnection()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func setLight(i: Int, on: Bool) {
        //flips lights button color between on/off
        //TODO: read in from light array in a loop, instead of hardcoding lights
        lights[i] = on
        if lights[i] {
            switch i {
                case 0: buttonLight0.backgroundColor = UIColor.gray; break;
                case 1: buttonLight1.backgroundColor = UIColor.gray; break;
                case 2: buttonLight2.backgroundColor = UIColor.gray; break;
                case 3: buttonLight3.backgroundColor = UIColor.gray; break;
                default: break;
            }
        }
        else {
            switch i {
                case 0: buttonLight0.backgroundColor = UIColor.lightGray; break;
                case 1: buttonLight1.backgroundColor = UIColor.lightGray; break;
                case 2: buttonLight2.backgroundColor = UIColor.lightGray; break;
                case 3: buttonLight3.backgroundColor = UIColor.lightGray; break;
                default: break;
            }
        }
        
        //if a button is pressed other than all, flip all button accordingly
        if i <= lights.count - 1 && !on {
            buttonLight3.backgroundColor = UIColor.lightGray
            lights[lights.count - 1] = false
        }
        else {
            //if all lights are on, turn "All" button on
            var allOn = true
            for i in 0...lights.count - 2 {
                if !lights[i] {
                    allOn = false
                    break
                }
            }
            if allOn {
                buttonLight3.backgroundColor = UIColor.gray
                lights[lights.count - 1] = true
            }
        }
    }
    
    func flipAllModeButtons() {
        var on = false
        if lights[lights.count - 1] {
            on = true
        }
        
        for i in 0...lights.count - 1 {
            setLight(i: i, on: on)
        }
        
        
    }

    func calculateMode() -> String {

        var binaryMode = ""
        for i in 0...lights.count - 2 {
            if lights[lights.count - (2 + i)] {
                binaryMode += "1"
            }
            else {
                binaryMode += "0"
            }
        }
        
        if let decMode = Int(binaryMode, radix: 2) {
            return "MODE\(decMode)"
        }
        return "ERROR"
    }
    
    @IBAction func buttonPressed(_ sender: UIButton)
    {
        let pathToButtons = Bundle.main.path(forResource: "Buttons", ofType: "plist")
        let buttonCodes = NSDictionary(contentsOfFile: pathToButtons!)
        
        var code = ""
        switch sender {
            //ON/OFF
            case buttonOff: code = "OFF"; break
            case buttonOn: code = "ON"; break
            //MODE
            case buttonLight0: setLight(i: 0, on: !lights[0]); code = calculateMode(); break
            case buttonLight1: setLight(i: 1, on: !lights[1]); code = calculateMode(); break
            case buttonLight2: setLight(i: 2, on: !lights[2]); code = calculateMode(); break
            case buttonLight3: setLight(i: 3, on: !lights[3]); flipAllModeButtons(); code = calculateMode(); break
            //DYNAMIC BUTTONS
            case button0: code = buttonCodes?.value(forKey: "0") as! String; break
            case button1: code = buttonCodes?.value(forKey: "1") as! String; break
            case button2: code = buttonCodes?.value(forKey: "2") as! String; break
            case button3: code = buttonCodes?.value(forKey: "3") as! String; break
            case button4: code = buttonCodes?.value(forKey: "4") as! String; break
            case button5: code = buttonCodes?.value(forKey: "5") as! String; break
            case button6: code = buttonCodes?.value(forKey: "6") as! String; break
            case button7: code = buttonCodes?.value(forKey: "7") as! String; break
            case button8: code = buttonCodes?.value(forKey: "8") as! String; break
            case button9: code = buttonCodes?.value(forKey: "9") as! String; break
            case button10: code = buttonCodes?.value(forKey: "10") as! String; break
            case button11: code = buttonCodes?.value(forKey: "11") as! String; break
            case button12: code = buttonCodes?.value(forKey: "12") as! String; break
            case button13: code = buttonCodes?.value(forKey: "13") as! String; break
            case button14: code = buttonCodes?.value(forKey: "14") as! String; break
            case button15: code = buttonCodes?.value(forKey: "15") as! String; break
            default: break;
        }
        
        //print(code)
        pi.sendCode(code: code, length: code.characters.count)
    }
}
 

