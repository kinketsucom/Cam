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
    


    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let videoInput = try! AVCaptureDeviceInput(device: self.videoDevice!) as AVCaptureDeviceInput
        self.captureSession.addInput(videoInput)
        let audioInput = try! AVCaptureDeviceInput(device: self.audioDevice!)  as AVCaptureInput
        self.captureSession.addInput(audioInput)
        self.captureSession.addOutput(self.fileOutput)
        
        
        //プレビュー
        videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
        
        self.setupButton()
        self.captureSession.startRunning()
        
        


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
        self.view.addSubview(self.startButton);
        self.view.addSubview(self.stopButton);
    
    }

    
    
    @objc func onClickStartButton(sender: UIButton){
        if !self.isRecording {
            // start recording
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0] as String
            
            let now = NSDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let date_string = formatter.string(from: now as Date)
            
            
            let filePath : String? = "\(documentsDirectory)/\(date_string).mp4"
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
        //ライブラリ保存
        let assetsLib = ALAssetsLibrary()
        assetsLib.writeVideoAtPath(toSavedPhotosAlbum: outputFileURL as URL?, completionBlock: nil)
        
        
//        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let now = NSDate()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyyMMddHHmmss"
//        let string = formatter.string(from: now as Date)
//        //appendingPathComponentでURL型の最後に文字列を連結できる
//            let path_file_name = documentPath.appendingPathComponent( string+".mp4" )
//
//        do {
//            let fileData = NSData(contentsOf:try NSURL(resolvingAliasFileAt: outputFileURL) as URL)
//            fileData!.write(toFile: "\(path_file_name)", atomically: true)
//            //try Data(bytes: data, count: data.count).write(to: path_file_name)
//            print("成功")
//        } catch {
//            print("失敗")
//        }
        print("終了")
    }
}
