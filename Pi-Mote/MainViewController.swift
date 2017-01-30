//
//  FirstViewController.swift
//  Pi-Mote
//
//  Created by Cody Meridith on 10/24/16.
//  Copyright © 2016 Cody Meridith. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    let pi = PiStream()
    var pathToSettings: String!
    var settings: NSMutableDictionary!
    
    var lights = [false, false, false, false]
    
    @IBOutlet weak var buttonBlue: UIButton!
    @IBOutlet weak var buttonBrightDown: UIButton!
    @IBOutlet weak var buttonBrightUp: UIButton!
    @IBOutlet weak var buttonCyan: UIButton!
    @IBOutlet weak var buttonFlux: UIButton!
    @IBOutlet weak var buttonGreen: UIButton!
    @IBOutlet weak var buttonMovie: UIButton!
    @IBOutlet weak var buttonOff: UIButton!
    @IBOutlet weak var buttonOn: UIButton!
    @IBOutlet weak var buttonOrange: UIButton!
    @IBOutlet weak var buttonPink: UIButton!
    @IBOutlet weak var buttonPurple: UIButton!
    @IBOutlet weak var buttonRand: UIButton!
    @IBOutlet weak var buttonRed: UIButton!
    @IBOutlet weak var buttonSoftWhite: UIButton!
    @IBOutlet weak var buttonSwap: UIButton!
    @IBOutlet weak var buttonWhite: UIButton!
    @IBOutlet weak var buttonYellow: UIButton!
    @IBOutlet weak var buttonLight0: UIButton!
    @IBOutlet weak var buttonLight1: UIButton!
    @IBOutlet weak var buttonLight2: UIButton!
    @IBOutlet weak var buttonLight3: UIButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pathToSettings = Bundle.main.path(forResource: "Settings", ofType: "plist")
        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)
        
        pi.IP = settings?.value(forKey: "Address") as? String
        pi.openConnection()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pi.closeConnection()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func flipLight(i: Int) {
        lights[i] = !lights[i]
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
    }
    
    func turnOnAllModeButtons() {
        for i in 0...lights.count - 1 {
            lights[i] = true
        }
    }

    func calculateMode() -> String {

        var binaryMode = ""
        for i in 0...lights.count - 1 {
            if lights[lights.count - (1 + i)] {
                binaryMode += "1"
            }
            else {
                binaryMode += "0"
            }
        }
        
        print("binary mode: \(binaryMode)")
        if let decMode = Int(binaryMode, radix: 2) {
            print("dec mode: \(decMode)")
            return String(decMode)
        }
        return "ERROR"
    }
    
    @IBAction func buttonPressed(_ sender: UIButton)
    {
        let pathToColors = Bundle.main.path(forResource: "Colors", ofType: "plist")
        let colors = NSDictionary(contentsOfFile: pathToColors!)
        
        var code = ""
        switch sender {
            
            case buttonBlue: code = colors?.value(forKey: "Blue") as! String; break
            case buttonBrightDown: code = "BRIGHTDOWN"; break
            case buttonBrightUp: code = "BRIGHTUP"; break
            case buttonCyan: code = colors?.value(forKey: "Cyan") as! String; break
            case buttonFlux: code = "FLUX"; break
            case buttonGreen: code = colors?.value(forKey: "Green") as! String; break
            case buttonLight0: flipLight(i: 0); code = calculateMode(); break
            case buttonLight1: flipLight(i: 1); code = calculateMode(); break
            case buttonLight2: flipLight(i: 2); code = calculateMode(); break
            case buttonLight3: flipLight(i: 3); turnOnAllModeButtons(); code = calculateMode(); break
            case buttonMovie: code = "MOVIE"; break
            case buttonOff: code = "OFF"; break
            case buttonOn: code = "ON"; break
            case buttonOrange: code = colors?.value(forKey: "Orange") as! String; break
            case buttonPink: code = colors?.value(forKey: "Pink") as! String; break
            case buttonPurple: code = colors?.value(forKey: "Purple") as! String; break
            case buttonRand: code = "RAND"; break
            case buttonRed: code = colors?.value(forKey: "Red") as! String; break
            case buttonSoftWhite: code = colors?.value(forKey: "SoftWhite") as! String; break
            case buttonSwap: code = "SWAP"; break
            case buttonWhite: code = colors?.value(forKey: "White") as! String; break
            case buttonYellow: code = colors?.value(forKey: "Yellow") as! String; break
            
            default: break
            
        }
                
        //pi.sendCode(code: code, length: code.characters.count)
    }
/*
    @IBAction func selectedSegmentChanged(_ sender: UISegmentedControl) {
        
        var code = ""
        switch sender.selectedSegmentIndex {
            case 0: code = "MODE1"; break;
            case 1: code = "MODE2"; break;
            case 2: code = "MODE3"; break;
            default: break;
        }
        
        pi.sendCode(code: code, length: code.characters.count)
    }
*/
}
 

