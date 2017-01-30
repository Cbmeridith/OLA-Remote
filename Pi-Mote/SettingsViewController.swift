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
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var fieldAddress: UITextField!
    @IBOutlet weak var segmentHaptic: UISegmentedControl!
    @IBOutlet weak var labelHaptic: UILabel!
    
    var pathToSettings: String!
    var settings: NSMutableDictionary!
    
    override func viewDidLoad() {
        buttonSave.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pathToSettings = Bundle.main.path(forResource: "Settings", ofType: "plist")
        settings = NSMutableDictionary(contentsOfFile: pathToSettings!)
        
        fieldAddress.text = settings?.value(forKey: "Address") as? String
        
        segmentHaptic.selectedSegmentIndex = Int((settings.value(forKey: "HapticStrength") as? String)!)!
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
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        if sender == buttonSave
        {
            settings?["Address"] = fieldAddress.text
            settings?.write(toFile: pathToSettings!, atomically: true)
        }
        
    }
    
    @IBAction func selectedSegmentChanged(_ sender: UISegmentedControl) {
        
        if sender == segmentHaptic
        {
            settings?["HapticStrength"] = String(segmentHaptic.selectedSegmentIndex)
            settings?.write(toFile: pathToSettings!, atomically: true)
        }
        
    }
    
}
