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
    var filterAsset = FilterAssetGetter()
    var filterInteraction: FilterInteraction?
    deinit {
        NvsStreamingContext.destroyInstance()
    }
    
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
    
    @IBAction func filterClick(_ sender: UIButton) {
        if let filterView = AssetView.LoadView() {
            view.addSubview(filterView)
            filterView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, 300)
            UIView.animate(withDuration: 0.25) {
                filterView.frame = CGRectMake(0, self.view.frame.size.height - 300, self.view.frame.size.width, 300)
            }
            filterInteraction = FilterInteraction(filterView, filterAction: self.capture)
        }
        
    }
    
    @IBAction func switchCamera(_ sender: UISwitch) {
        capture.switchCamera()
    }

}
