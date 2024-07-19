//
//  CaptureViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/30.
//

import NvStreamingSdkCore
import UIKit

class CaptureViewController: UIViewController {
    @IBOutlet var livewindow: NvsLiveWindow!
    let streamingContext = NvsStreamingContext.sharedInstance()!
    let capture = CaptureService()
    deinit {
        streamingContext.stopRecording()
        NvsStreamingContext.destroyInstance()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        capture.startPreview(livewindow: livewindow)

        // Do any additional setup after loading the view.
    }

    @IBAction func recordClick(_ sender: UIButton) {
        var text = ""
        if sender.isSelected {
            capture.stopRecording()
            text = "Record"
        } else {
            capture.startRecording()
            text = "Stop"
        }
        sender.isSelected = !sender.isSelected
        sender.setTitle(text, for: .normal)
    }

    @IBAction func filterClick(_ sender: UIButton) {
        let filterView = AssetView.newInstance() as! AssetView
        view.addSubview(filterView)
        filterView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, 300)
        UIView.animate(withDuration: 0.25) {
            filterView.frame = CGRectMake(0, self.view.frame.size.height - 300, self.view.frame.size.width, 300)
        }
    }

    @IBAction func switchCamera(_ sender: UISwitch) {
        capture.switchCamera()
    }
}
