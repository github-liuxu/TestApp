//
//  CaptureViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/30.
//

import NvStreamingSdkCore
import UIKit
import Combine

class CaptureViewController: UIViewController {
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet var livewindow: NvsLiveWindow!
    let rectView: RectView = RectView()
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var capture: CaptureService?
    var isLimitRecord = true
    private var cancellables = Set<AnyCancellable>()
    deinit {
        capture?.clear()
        capture = nil
        streamingContext.stop()
        NvsStreamingContext.destroyInstance()
        print("CaptureViewController: NvsStreamingContext.destroyInstance")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        livewindow.addSubview(rectView)
        rectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rectView.leadingAnchor.constraint(equalTo: livewindow.leadingAnchor),
            rectView.trailingAnchor.constraint(equalTo: livewindow.trailingAnchor),
            rectView.topAnchor.constraint(equalTo: livewindow.topAnchor),
            rectView.bottomAnchor.constraint(equalTo: livewindow.bottomAnchor)
        ])
        capture = CaptureService()
        livewindow.insertSubview(rectView, at: 0)
        capture?.startPreview(livewindow: livewindow)
        capture?.$isRecording
            .receive(on: RunLoop.main)
            .assign(to: \.isSelected, on: recordBtn)
            .store(in: &cancellables)
        // Do any additional setup after loading the view.
    }

    @IBAction func recordClick(_ sender: UIButton) {
        if isLimitRecord {
            if sender.isSelected {
                capture?.pauseRecording()
            } else {
                if capture!.streamingIsRecording() {
                    capture?.resumeRecording()
                } else {
                    capture?.startRecording(seconds: 15)
                }
            }
        } else {
            if sender.isSelected {
                capture?.stopRecording()
            } else {
                capture?.startRecording()
            }
        }
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
        capture.captionService.livewindow = livewindow
        captionView.captionService = capture.captionService
        _ = capture.captionService.addCaption(text: "请输入字幕")
        
        captionView.didViewClose = { [weak self] in
            self?.rectView.moveable = nil
        }
    }
    
    @IBAction func sticker(_ sender: Any) {
        if let stickerView = StickerView.newInstance() as? StickerView {
            view.addSubview(stickerView)
            stickerView.show()
            rectView.moveable = capture?.stickerService
            capture?.stickerService.livewindow = livewindow
            capture?.stickerService.rectable = rectView
            stickerView.stickerService = capture?.stickerService
            stickerView.didViewClose = { [weak self] in
                self?.rectView.moveable = nil
            }
        }
    }
    
    @IBAction func comCaption(_ sender: Any) {
        if let comCaptionView = CompoundCaptionView.newInstance() as? CompoundCaptionView {
            view.addSubview(comCaptionView)
            comCaptionView.show()
            rectView.moveable = capture?.comCaptionService
            capture?.stickerService.livewindow = livewindow
            capture?.stickerService.rectable = rectView
            comCaptionView.comCaptionService = capture?.comCaptionService
            comCaptionView.didViewClose = { [weak self] in
                self?.rectView.moveable = nil
            }
        }
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
