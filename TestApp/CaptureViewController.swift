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
    @IBOutlet weak var rectView: RectView!
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var capture: CaptureService?
    deinit {
        capture?.clear()
        capture = nil
        streamingContext.stop()
        NvsStreamingContext.destroyInstance()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        capture = CaptureService()
        capture?.startPreview(livewindow: livewindow)
        // Do any additional setup after loading the view.
    }

    @IBAction func recordClick(_ sender: UIButton) {
        var text = ""
        if sender.isSelected {
            capture?.stopRecording()
            text = "Record"
        } else {
            capture?.startRecording()
            text = "Stop"
        }
        sender.isSelected = !sender.isSelected
        sender.setTitle(text, for: .normal)
    }

    @IBAction func filterClick(_ sender: UIButton) {
        let filterView = AssetView.newInstance() as! AssetView
        view.addSubview(filterView)
        filterView.filterService = capture?.filterService
        filterView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, 300)
        UIView.animate(withDuration: 0.25) {
            filterView.frame = CGRectMake(0, self.view.frame.size.height - 300, self.view.frame.size.width, 300)
        }
    }

    @IBAction func switchCamera(_ sender: UISwitch) {
        capture?.switchCamera()
    }
    
    @IBAction func captionClick(_ sender: Any) {
        guard let capture = capture else { return }
        let captionView = CaptionView.newInstance() as! CaptionView
        view.addSubview(captionView)
        captionView.show()
        
        rectView.moveable = capture.captionService
        capture.captionService.rectable = rectView
        captionView.captionService = capture.captionService
        _ = capture.captionService.addCaption(text: "请输入字幕")
        
        captionView.didViewClose = { [weak self] in
            self?.rectView.moveable = nil
        }
    }
    
    @IBAction func sticker(_ sender: Any) {
        
    }
    
    @IBAction func comCaption(_ sender: Any) {
        
    }
    
    @IBAction func props(_ sender: Any) {
        guard let capture = capture else { return }
        let propView = PropView.newInstance() as! PropView
        view.addSubview(propView)
        propView.show()
        
        rectView.moveable = capture.captionService
        capture.captionService.rectable = rectView
        propView.arsceneService = capture.arsceneService

    }
    
}
