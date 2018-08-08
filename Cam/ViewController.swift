//
//  ViewController.swift
//  Cam
//
//  Created by admin on 2018/08/06.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var index = 2
    
    let captureSession = AVCaptureSession()
    let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
    let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    let fileOutput = AVCaptureMovieFileOutput()
    
    var startButton, stopButton ,changeViewButton: UIButton!
    var isRecording = false
    
    var videoLayer : AVCaptureVideoPreviewLayer!
    var isViewing = false
    
    //カレンダー表示
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // background image
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg")
        bg.contentMode = UIViewContentMode.scaleAspectFit
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
        
        let videoInput = try! AVCaptureDeviceInput(device: self.videoDevice!) as AVCaptureDeviceInput
        self.captureSession.addInput(videoInput)
        let audioInput = try! AVCaptureDeviceInput(device: self.audioDevice!)  as AVCaptureInput
        self.captureSession.addInput(audioInput)
        self.captureSession.addOutput(self.fileOutput)
        self.setupButton()
        self.captureSession.startRunning()
        
        var timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)

    }
    
    //NSTimerを利用して60分の1秒ごとに呼びたす。
    @objc func update() {
        nowTime()
    }
    
    func nowTime(){
        let now = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let string = formatter.string(from: now as Date)
        dateLabel.text = string
    }
    //1桁のものには0をつける。例えば1秒なら01秒に。
    func addZero(timeString:String,timeNuber:Int)->String{
        if(timeString.count == 1){
            return ("0\(timeNuber)")
        }else{
            return ("\(timeNuber)")
        }
    }
    func setupButton(){
        self.startButton = UIButton(frame: CGRect(x:0,y:0,width:120,height:50))
        self.startButton.backgroundColor = UIColor.red;
        self.startButton.layer.masksToBounds = true
        self.startButton.setTitle("start", for: .normal)
        self.startButton.layer.cornerRadius = 20.0
        self.startButton.layer.position = CGPoint(x: self.view.bounds.width/2 - 70, y:self.view.bounds.height-50)
        self.startButton.addTarget(self, action: #selector(self.onClickStartButton(sender:)), for: .touchUpInside)
        
        self.stopButton = UIButton(frame: CGRect(x:0,y:0,width:120,height:50))
        self.stopButton.backgroundColor = UIColor.gray;
        self.stopButton.layer.masksToBounds = true
        self.stopButton.setTitle("stop", for: .normal)
        self.stopButton.layer.cornerRadius = 20.0
        
        self.stopButton.layer.position = CGPoint(x: self.view.bounds.width/2 + 70, y:self.view.bounds.height-50)
        self.stopButton.addTarget(self, action: #selector(self.onClickStopButton(sender:)), for: .touchUpInside)
        
        self.changeViewButton = UIButton(frame: CGRect(x:0,y:0,width:120,height:50))
        self.changeViewButton.backgroundColor = UIColor.gray;
        self.changeViewButton.layer.masksToBounds = true
        self.changeViewButton.setTitle("hoge", for: .normal)
        self.changeViewButton.layer.cornerRadius = 20.0
        
        self.changeViewButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:50)
        self.changeViewButton.addTarget(self, action: #selector(self.onClickChangeViewButton(sender:)), for: .touchUpInside)
        
        
        self.view.addSubview(self.startButton);
        self.view.addSubview(self.stopButton);
        self.view.addSubview(self.changeViewButton);
    }
    @objc func onClickChangeViewButton(sender: UIButton){
        if(isViewing){
            isViewing = !isViewing
            self.changeViewButton.backgroundColor = UIColor.gray
            self.changeViewButton.setTitle("停止", for: .normal)
        }else{//false
            self.changeViewButton.backgroundColor = UIColor.blue
            self.changeViewButton.setTitle("監視", for: .normal)
            videoLayer = AVCaptureVideoPreviewLayer(session: self.captureSession) as AVCaptureVideoPreviewLayer
            videoLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 200)//self.view.bounds
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.view.layer.addSublayer(videoLayer)
            isViewing = !isViewing
        }
    }
    
    
    @objc func onClickStartButton(sender: UIButton){
        if !self.isRecording {
            // start recording
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0] as String
            let filePath : String? = "\(documentsDirectory)/temp.mp4"
            let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
            fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
            
            self.isRecording = true
            self.changeButtonColor(target: self.startButton, color: UIColor.gray)
            self.changeButtonColor(target: self.stopButton, color: UIColor.red)
        }
    }
    
    @objc func onClickStopButton(sender: UIButton){
        if self.isRecording {
            fileOutput.stopRecording()
            
            self.isRecording = false
            self.changeButtonColor(target: self.startButton, color: UIColor.red)
            self.changeButtonColor(target: self.stopButton, color: UIColor.gray)
        }
    }
    
    func changeButtonColor(target: UIButton, color: UIColor){
        target.backgroundColor = color
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?){
        let assetsLib = ALAssetsLibrary()
        assetsLib.writeVideoAtPath(toSavedPhotosAlbum: outputFileURL as URL?, completionBlock: nil)
        
    }
}
