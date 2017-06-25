//
//  SettingsViewController.swift
//  Pi-Mote
//
//  Created by Cody Meridith on 10/31/16.
//  Copyright © 2016 Cody Meridith. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
    let pi = PiStream()
    
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var fadeToggle: UIButton!
    @IBOutlet weak var fieldAddress: UITextField!
    @IBOutlet weak var segmentHaptic: UISegmentedControl!
    @IBOutlet weak var labelHaptic: UILabel!
    
    var pathToSettings: String!
    var settings: NSMutableDictionary!
    var code = ""
    var generator = UIImpactFeedbackGenerator()
    var hapticStrength: Int! = 0
    var haptic = false
    
    override func viewDidLoad() {
        buttonSave.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //get path to Settings plist
        let settingsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let settingsFullDestPath = NSURL(fileURLWithPath: settingsPath).appendingPathComponent("Settings.plist")
        let settingsFullDestPathString = settingsFullDestPath?.path
        pathToSettings = settingsFullDestPathString
        
        //read settings plist
        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)

        
        fieldAddress.text = settings?.value(forKey: "Address") as? String
        
        updateHaptic()
        
        pi.IP = settings?.value(forKey: "Address") as? String
        pi.openConnection()
    }
    
    func updateHaptic(){
        segmentHaptic.selectedSegmentIndex = Int((settings.value(forKey: "HapticStrength") as? String)!)!
        
        let hapticStrengthString = settings?.value(forKey: "HapticStrength") as? String
        
        // Make sure that the string is not nil
        if let unwrappedString = hapticStrengthString {
            
            // convert String to Int
            hapticStrength = Int(unwrappedString)
        }
        
        switch hapticStrength {
        case 0:
            haptic = false
        case 1:
            generator = UIImpactFeedbackGenerator(style: .light)
            haptic = true
        case 2:
            generator = UIImpactFeedbackGenerator(style: .medium)
            haptic = true
        case 3:
            generator = UIImpactFeedbackGenerator(style: .heavy)
            haptic = true
        default:
            haptic = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pi.closeConnection()
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        if(sender == fieldAddress)
        {
            let pattern = "^[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+$"
            
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            
            let matches = regex.matches(in: fieldAddress.text!, options: [], range: NSRange(location: 0, length: (fieldAddress.text?.characters.count)!))
            
            if(matches.count == 1)
            {
                buttonSave.isHidden = false
            }
            else
            {
                buttonSave.isHidden = true
            }
            
        }
    }
    
    @IBAction func buttonTouched(_ sender: UIButton){
        if(haptic){generator.impactOccurred()}
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        if sender == buttonSave
        {
            settings?["Address"] = fieldAddress.text
            settings?.write(toFile: pathToSettings!, atomically: true)
            self.view.window?.endEditing(true)
        }
        
        if sender == fadeToggle
        {
            code = "TOGFADE"
            pi.sendCode(code: code, length: code.characters.count)
        }
        
    }
    
    
    @IBAction func selectedSegmentChanged(_ sender: UISegmentedControl) {
        
        if sender == segmentHaptic
        {
            settings?["HapticStrength"] = String(segmentHaptic.selectedSegmentIndex)
            settings?.write(toFile: pathToSettings!, atomically: true)
            
            updateHaptic()
            
            if(haptic){generator.impactOccurred()}
        }
        
    }
    
}
