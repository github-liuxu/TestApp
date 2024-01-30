//
//  CaptureViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/30.
//

import UIKit
import NvStreamingSdkCore

class CaptureViewController: UIViewController {

    @IBOutlet weak var livewindow: NvsLiveWindow!
    var streamingContext = NvsStreamingContext.sharedInstance()
    let capture = CaptureAction()
    override func viewDidLoad() {
        super.viewDidLoad()
        livewindow.fillMode = NvsLiveWindowFillModePreserveAspectFit
        capture.startPreview(livewindow: livewindow)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func recordClick(_ sender: UIButton) {
        var text = ""
        if (sender.isSelected) {
            capture.stopRecording()
            text = "Record"
        } else {
            capture.startRecording()
            text = "Stop"
        }
        sender.isSelected = !sender.isSelected
        sender.setTitle(text, for: .normal)
    }
    
    @IBAction func switchCamera(_ sender: UISwitch) {
        capture.switchCamera()
    }

}
