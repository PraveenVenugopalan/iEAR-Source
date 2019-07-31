//
//  IEVoiceRecognitionViewController.swift
//  iEar
//
//  Created by Vivek Anand John on 28/10/18.
//  Copyright © 2018 CTS. All rights reserved.
//

import UIKit
import Speech
import Foundation
import AVFoundation

class IEVoiceRecognitionViewController: UIViewController, SFSpeechRecognizerDelegate {

    
    @IBOutlet weak var viewStartRecording: UIView!
    
    @IBOutlet weak var viewTextRecord: UIView!
    
    @IBOutlet weak var textViewRecord: UITextView!
    
    @IBOutlet weak var stackViewRecordImage: UIStackView!
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var isButtonEnabled = false
    var isRecordingStarted = false
    
    var mainRecordedText = ""
    var placeArray : [String] = []
    var nameArray : [String] = []
    var harassmentArray : [String] = ["stupid","idiot","fool","freak","sexy","useless","fuck","fucker"]

    var organizationArray : [String] = []
    let tagger = NSLinguisticTagger(tagSchemes: [.tokenType, .language, .lexicalClass, .nameType, .lemma], options: 0)
    let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        speechRecognizer.delegate = self
        self.loadAudioSettings()
    }
    
    func loadAudioSettings() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            switch authStatus {
            case .authorized:
                self.isButtonEnabled = true
                
            case .denied:
                self.isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                self.isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                self.isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                if (self.isButtonEnabled) {
                    self.stackViewRecordImage.alpha = 1.0
                }
                else {
                    self.stackViewRecordImage.alpha = 0.4
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        if audioEngine.isRunning {
            mainRecordedText = ""
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isRecordingStarted = false
        }
        self.updateUIForStatusRecording(isRecording: false)
        if (synth.isPaused) || (synth.isSpeaking) {
            synth.stopSpeaking(at: .immediate)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        // Show the navigation bar on other view controllers
        harassmentArray = ["stupid","idiot","fool","freak","sexy","useless","fuck","fucker"]
        self.loadAudioSettings()
    }
    
    /*
     * Function Name : startRecording
     * Function : method calls when start recording button clicks.
     * Created By : Vivek, 28/10/18
     */
    func startRecording() {
        
        if recognitionTask != nil {  //Current task checking
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  // AVAudioSession
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: [])
            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
            if !isRecordingStarted {
                textViewRecord.text = "Say something, I'm listening!"
            }
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //SFSpeechRecognizer
        
        guard let inputNode = audioEngine.inputNode as? AVAudioInputNode else {
            fatalError("Audio engine has no input node")
        }
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in // Audio Recording task. Gets called each time when new audio recorded.
            
            var isFinal = false
            if result != nil {
                
                self.mainRecordedText = (result?.bestTranscription.formattedString)!  //Audio to Text Converting
                self.namedEntityRecognition(for: self.mainRecordedText)
                for (index, name) in self.harassmentArray.enumerated() {
                    if ((self.mainRecordedText.lowercased()).range(of:name) != nil) {
                        self.playWarningAudio()
                        self.harassmentArray.remove(at: index)
                    }
                }
                
                self.mainRecordedText = ProfanityFilter.cleanUp(self.mainRecordedText)
                
                self.textViewRecord.attributedText = self.highlightText()
                self.textViewRecord.font = UIFont.systemFont(ofSize: 20)
                

                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  // Recording Stoped
                self.mainRecordedText = ""
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recognitionRequest?.endAudio()
                
                if (self.isRecordingStarted) {
                    self.startRecording()
                }
                else {
                self.showCommonAlert(message: "Recording Stoped", title: "iEar")
                }
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            self.isRecordingStarted = true
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }

    /*
     * Function Name : speechRecognizer
     * Function : method calls when recognizer availabiliy changes
     * Created By : Vivek, 28/10/18
     */
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
          self.showCommonAlert(message: "Recording available now", title: "iEar")
        } else {
          self.showCommonAlert(message: "Recording not available now", title: "iEar")
        }
    }
    
    /*
     * Function Name : updateUIForStatusRecording
     * Function : Updating UI for start and stop recording
     * Created By : Vivek, 28/10/18
    */
    func updateUIForStatusRecording(isRecording:Bool) {
        self.textViewRecord.text = ""
        if isRecording {
            self.viewStartRecording.isHidden = true
        }
        else {
            self.viewStartRecording.isHidden = false
        }
    }
    
    /*
     * Function Name : btnClickedStopRecording
     * Function : for stop recording
     * Created By : Vivek, 28/10/18
     */
    @IBAction func btnClickedStopRecording(_ sender: Any) {
        if audioEngine.isRunning {
            mainRecordedText = ""
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isRecordingStarted = false
            harassmentArray = ["stupid","idiot","fool","freak","sexy","useless","fuck","fucker"]
        }
       self.updateUIForStatusRecording(isRecording: false)
        synth.pauseSpeaking(at: AVSpeechBoundary.immediate)
        if (synth.isPaused) || (synth.isSpeaking) {
            synth.pauseSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    /*
     * Function Name : btnClickStartRecording
     * Function : for start recording
     * Created By : Vivek, 28/10/18
     */
    @IBAction func btnClickStartRecording(_ sender: Any) {
        if (isButtonEnabled) {
            self.updateUIForStatusRecording(isRecording: true)
            startRecording()
        }
        else {
            
            
        }
    }
    
    // MARK: - NATURAL LANGUAGE
    
    func namedEntityRecognition(for text: String) {
        tagger.string = text
        let range = NSRange(location: 0, length: text.utf16.count)
        let tags: [NSLinguisticTag] = [.personalName, .placeName, .organizationName]

        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: options) { tag, tokenRange, stop in
            if let tag = tag, tags.contains(tag) {
                let name = (text as NSString).substring(with: tokenRange)
                print("\(name): \(tag.rawValue)")
                
                switch (tag.rawValue) {

                case "OrganizationName":
                    organizationArray.append(name)
                    break
                case "PlaceName":
                    placeArray.append(name)
                    break
                case "PersonalName":
                    nameArray.append(name)
                    break
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - ATTRIBUTE STRING COLORING
    
    func highlightText() -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: mainRecordedText)
        
        for name in placeArray {
            
            let highlightAttributes = [NSAttributedString.Key.foregroundColor: UIColor.green]
            
            let nsstr = mainRecordedText as NSString
            var searchRange = NSMakeRange(0, nsstr.length)
            
            while true {
                let foundRange = nsstr.range(of: name, options: [], range: searchRange)
                if foundRange.location == NSNotFound {
                    break
                }
                
                attributedString.setAttributes(highlightAttributes, range: foundRange)
                
                let newLocation = foundRange.location + foundRange.length
                let newLength = nsstr.length - newLocation
                searchRange = NSMakeRange(newLocation, newLength)
            }
        }
        
        for name in nameArray {
            
            let highlightAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue]
            
            let nsstr = mainRecordedText as NSString
            var searchRange = NSMakeRange(0, nsstr.length)
            
            while true {
                let foundRange = nsstr.range(of: name, options: [], range: searchRange)
                if foundRange.location == NSNotFound {
                    break
                }
                
                attributedString.setAttributes(highlightAttributes, range: foundRange)
                
                let newLocation = foundRange.location + foundRange.length
                let newLength = nsstr.length - newLocation
                searchRange = NSMakeRange(newLocation, newLength)
            }
        }
        
        for name in organizationArray {
            
            let highlightAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
            
            let nsstr = mainRecordedText as NSString
            var searchRange = NSMakeRange(0, nsstr.length)
            
            while true {
                let foundRange = nsstr.range(of: name, options: [], range: searchRange)
                if foundRange.location == NSNotFound {
                    break
                }
                
                attributedString.setAttributes(highlightAttributes, range: foundRange)
                
                let newLocation = foundRange.location + foundRange.length
                let newLength = nsstr.length - newLocation
                searchRange = NSMakeRange(newLocation, newLength)
            }
        }
        
        return attributedString
    }
    
    
    func playWarningAudio()
    {
        myUtterance = AVSpeechUtterance(string: "Please avoid verbal abuse")
        myUtterance.rate = 0.5
        audioEngine.pause()
        synth.speak(myUtterance)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.audioEngine.prepare()
            do {
                try self.audioEngine.start()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}


