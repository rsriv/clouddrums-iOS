//
//  ViewController.swift
//  clouddrums iOS
//
//  Created by Rishi Srivastava on 2016-07-27.
//  Copyright © 2016 Rishi Srivastava. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    var kickSound: SystemSoundID = 0
    var snareSound: SystemSoundID = 0
    var hatSound: SystemSoundID = 0
var player1 = AVAudioPlayer()
    func  isNumeric (s: String) -> Bool{
        let n = Int (s)
        if (n != nil && n>=1 && n<10000){
            return true
        }
        else {
        return false}
        
    }
    
    func randInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    func hitOrNo (n: Int) -> Int {
        let i = randInt(0,max: 9);
        if (i < n) {
           return 1
        }
        else {
           return 0;
        }
    }
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    var playCount = 0, valid = 0;
    @IBOutlet var Picker1: UIPickerView!
    @IBOutlet weak var bpmField: UITextField!
    @IBOutlet weak var loopField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    @IBAction func play(sender: AnyObject) {
        
        var check = 0
        var bpm1 = 0, loopLength = 0
        
        //Validation
        if (isNumeric(bpmField.text!)){
            bpm1 = Int (bpmField.text!)!
            label1.text = ""
            check+=1
        }
        else {
            label1.text = "Invalid BPM"
        }
        
        if (isNumeric(loopField.text!)){
            loopLength = Int (loopField.text!)!
            label2.text = ""
            check+=1
            
        }
        else {
            label2.text = "Invalid Loop Length"
        }
        
       
        
        //Set button text
        if (playCount%2 == 0 && check == 2){
            
        }
       
        if (check == 2 && playCount%2 == 0){// mod makes it play once then stop, adjust playcount
        playCount+=1
        button.setTitle("Stop", forState: .Normal)
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
        //generate piano roll
        
        let num16ths = loopLength*16
        let bpm = Float (bpm1)
        let beatTime =  UInt32((Float (15/bpm)*Float(1000000.0000))/2)
        NSLog (String(beatTime))
        var beat = 1
        var kick = [Int](count: num16ths, repeatedValue: 0)
        var snare = [Int](count: num16ths, repeatedValue: 0)
        var hiHat = [Int](count: num16ths, repeatedValue: 0)
        
        //Load sounds
        var kickURL = NSBundle.mainBundle().URLForResource("hiphopkick", withExtension: "caf")
        var snareURL = NSBundle.mainBundle().URLForResource("hiphopsnare", withExtension: "caf")
        var hatURL = NSBundle.mainBundle().URLForResource("hiphophat", withExtension: "caf")
        if (self.kitType == "rock"){
            kickURL = NSBundle.mainBundle().URLForResource("rockkick", withExtension: "mp3")
            snareURL = NSBundle.mainBundle().URLForResource("rocksnare", withExtension: "mp3")
            hatURL = NSBundle.mainBundle().URLForResource("rockhat", withExtension: "mp3")
        }
        if (self.kitType == "bongos"){
            kickURL = NSBundle.mainBundle().URLForResource("bongolow", withExtension: "mp3")
            snareURL = NSBundle.mainBundle().URLForResource("bongomid", withExtension: "mp3")
            hatURL = NSBundle.mainBundle().URLForResource("bongohigh", withExtension: "mp3")
        }
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                try AVAudioSession.sharedInstance().setActive(true)

            self.player1 = try AVAudioPlayer(contentsOfURL: kickURL!)
            self.player1.numberOfLoops = 0
            self.player1.prepareToPlay()
            self.player1.play()
            }catch _ {
                return print("sound file not found")
            }
            
        AudioServicesCreateSystemSoundID(kickURL!, &self.kickSound)
          
        AudioServicesCreateSystemSoundID(snareURL!, &self.snareSound)
        AudioServicesCreateSystemSoundID(hatURL!, &self.hatSound)
        
     
        while (beat <= num16ths){
            //kick
            if (beat % 4 == 0 || (beat - 2) % 4 == 0) {
                kick[beat - 1] = self.hitOrNo(2)
            }
            if ((beat + 1) % 4 == 0) {
                kick[beat - 1] = self.hitOrNo(3)
            }
            if ((beat - 1) % 4 == 0) {
                kick[beat - 1] = self.hitOrNo(1)
            }
            if ((beat - 1) % 8 == 0) {
                kick[beat - 1] = 1;
            }
            
            //snare
            if ((beat - 1) % 8 == 0) {
                snare[beat - 1] = self.hitOrNo(1)
            }
            if (beat % 2 == 0 || (beat + 1) % 4 == 0) {
                snare[beat - 1] = self.hitOrNo(2)
            }
            if ((beat + 3) % 8 == 0) {
                snare[beat - 1] = self.hitOrNo(10)
            }
            
            //hiHat
            if ((beat - 1) % 2 == 0) {
                hiHat[beat - 1] = self.hitOrNo(10)
            }
            if ((beat + 2) % 4 == 0) {
                hiHat[beat - 1] = self.hitOrNo(3)
            }
            if (beat % 4 == 0) {
                hiHat[beat - 1] = self.hitOrNo(2)
            }
            
            beat += 1

        }
          
        beat = 1
        self.valid = 1
        var kickPlay = 0
        
        while (self.valid == 1) {
            beat = 1;
           
            while (beat <= (num16ths + 1) && self.valid == 1) {
              
                // Code to execute every beattime seconds
                kickPlay = 0;
                if (beat == (num16ths + 1) || self.valid == 0) {
                   break;
                }
                if (kick[beat - 1] == 1) {
                    kickPlay = 1;
                    // Play Kick
                    AudioServicesPlaySystemSound(self.kickSound);
                }
                
                //play snare
                if (snare[beat - 1] == 1 && kickPlay == 0) {
                    // Play Snare
                    AudioServicesPlaySystemSound(self.snareSound);
                }
               
                
                //play hiHat
                if (hiHat[beat - 1] == 1) {
                    // Play Hat
                    AudioServicesPlaySystemSound(self.hatSound);
                }
                //INSERT DELAY HERE
                usleep(beatTime)
                
                beat += 1
                }
            
            }
            self.playCount+=1
        })
        }
        else {
            button.setTitle("Play", forState: .Normal)
            self.valid = 0
            // not work self.playCount = 0
        }
    }
    func a1 () {
        AudioServicesPlaySystemSound(hatSound)
    }
    var Array = ["Hip Hop Kit",
                 "Rock Kit",
                 "Bongos"]
    var kitType = ""
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        Picker1.delegate = self
        Picker1.dataSource = self
        bpmField.delegate = self
        loopField.delegate = self
        label1.text = ""
        label2.text = ""
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array[row]
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Array.count
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (row == 2){
            kitType = "bongos"
        }
        else {
            if (row == 1){
                kitType = "rock"
            }
            else{
                kitType = "hiphop"
            }
        }
        NSLog(kitType)
        
    }


}

