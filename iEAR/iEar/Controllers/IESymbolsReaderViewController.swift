//
//  ViewController.swift
//  Sesgoritma
//
//  Created by Arda Mavi on 21.03.2018.
//  Copyright © 2018 Sesgoritma. All rights reserved.
//

import UIKit
import AVKit
import Vision
import AVFoundation

class IESymbolsReaderViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession = AVCaptureSession()
    let synth = AVSpeechSynthesizer()
    var cameraPos = AVCaptureDevice.Position.front
    var captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: AVCaptureDevice.Position.back)
    var def_bright = UIScreen.main.brightness // Default screen brightness
    var old_char = ""
    let model = try? VNCoreMLModel(for: Sesgoritma().model)
    
    @IBOutlet var predictLabel: UILabel!
    @IBAction func stop_captureSession(_ sender: UIButton) {
        captureSession.stopRunning()
        synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        UIApplication.shared.isIdleTimerDisabled = false
        UIScreen.main.brightness = def_bright
    }
    @IBAction func change_camera(_ sender: Any) {
        captureSession.stopRunning()
        synth.stopSpeaking(at: AVSpeechBoundary.immediate)
        if cameraPos == AVCaptureDevice.Position.back{
            cameraPos = AVCaptureDevice.Position.front
        }else{
            if UIScreen.main.brightness != def_bright{
                UIScreen.main.brightness = def_bright
            }
            cameraPos = AVCaptureDevice.Position.back
        }
        if lightSwitch.isOn{
            lightSwitch.setOn(false, animated: true)
        }
        captureSession = AVCaptureSession()
        view.layer.sublayers?[0].removeFromSuperlayer()
        old_char = ""
        self.viewDidLoad()
    }
    @IBOutlet var lightSwitch: UISwitch!
    @IBAction func change_light(_ sender: UISwitch) {
        if cameraPos == AVCaptureDevice.Position.back{
            try? captureDevice?.lockForConfiguration()
            if sender.isOn{
                try? captureDevice?.setTorchModeOn(level: 1.0)
            }else{
                captureDevice?.torchMode = .off
            }
            captureDevice?.unlockForConfiguration()
        }else{
            if sender.isOn{
                def_bright = UIScreen.main.brightness
                UIScreen.main.brightness = CGFloat(1)
            }else{
                UIScreen.main.brightness = def_bright
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.shared.isIdleTimerDisabled = true // Deactivate sleep mode
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .defaultToSpeaker)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        captureSession.sessionPreset = .photo
        
        self.captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPos)
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice!) else {return}
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        
        connection.videoOrientation = AVCaptureVideoOrientation.portrait
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        
        let request = VNCoreMLRequest(model: model!){ (fineshedReq, err) in
            
            guard let results = fineshedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            
            // print(firstObservation.identifier, firstObservation.confidence)
            DispatchQueue.main.async {
                if firstObservation.confidence < 0.5{
                    
                    // For secondary vocalization
                    self.old_char = ""
                    self.predictLabel.text = ""
                    
                }else if self.old_char != String(firstObservation.identifier) && firstObservation.confidence > 0.9{
                    
                    self.transalteTextToEnglish(inputText: String(firstObservation.identifier))
//                    self.predictLabel.text =  String(firstObservation.identifier)
//                                        let utterance = AVSpeechUtterance(string: String(firstObservation.identifier))
//                                        utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
//                                        self.synth.stopSpeaking(at: AVSpeechBoundary.immediate) // For mute the previous speak.
//                                        self.synth.speak(utterance)
//                    self.old_char = String(firstObservation.identifier)
                }
            }
            
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func transalteTextToEnglish(inputText:String) {
        
        struct encodeText: Codable {
            var text = String()
        }
        let text2Translate = inputText
        var encodeTextSingle = encodeText()
        var toTranslate = [encodeText]()
        
        encodeTextSingle.text = text2Translate
        toTranslate.append(encodeTextSingle)
        
        let jsonEncoder = JSONEncoder()
        
        let azureKey = "8590c2258d4e44e7be46d773d4367700"
        
        let contentType = "application/json"
        let traceID = "A14C9DB9-0DED-48D7-8BBE-C517A1A8DBB0"
        let host = "dev.microsofttranslator.com"
        let apiURL = "https://dev.microsofttranslator.com/translate?api-version=3.0&from=tr&to=en"
        let jsonToTranslate = try? jsonEncoder.encode(toTranslate)
        let url = URL(string: apiURL)
        var request = URLRequest(url: url!)
        
        
        
        request.httpMethod = "POST"
        request.addValue(azureKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.addValue(traceID, forHTTPHeaderField: "X-ClientTraceID")
        request.addValue(host, forHTTPHeaderField: "Host")
        request.addValue(String(describing: jsonToTranslate?.count), forHTTPHeaderField: "Content-Length")
        request.httpBody = jsonToTranslate
        
        
        let config = URLSessionConfiguration.default
        let session =  URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            
            if responseError != nil {
                print("this is the error ", responseError!)
                
                let alert = UIAlertController(title: "Could not connect to service", message: "Please check your network connection and try again", preferredStyle: .actionSheet)
                
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
                
            }
            print("*****")
            self.parseJson(jsonData: responseData!)
        }
        task.resume()
        
        
    }
    
    
    func parseJson(jsonData: Data) {
        
        //*****TRANSLATION RETURNED DATA*****
        struct ReturnedJson: Codable {
            var translations: [TranslatedStrings]
        }
        struct TranslatedStrings: Codable {
            var text: String
            var to: String
        }
        
        let jsonDecoder = JSONDecoder()
        let langTranslations = try? jsonDecoder.decode(Array<ReturnedJson>.self, from: jsonData)
        let numberOfTranslations = langTranslations!.count - 1
        print(langTranslations!.count)
        
        //Put response on main thread to update UI
        DispatchQueue.main.async {
            let str = langTranslations![0].translations[numberOfTranslations].text
            self.predictLabel.text = str
            let utterance = AVSpeechUtterance(string: String(str))
            utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
            self.synth.stopSpeaking(at: AVSpeechBoundary.immediate) // For mute the previous speak.
            self.synth.speak(utterance)
            // self.old_char = String(str)
            
        }
    }
    
}

