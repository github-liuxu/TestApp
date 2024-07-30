//
//  CaptureViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/30.
//

import Combine
import NvStreamingSdkCore
import UIKit

class CaptureViewController: UIViewController {
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var livewindow: NvsLiveWindow!
    let rectView: RectView = .init()
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
            rectView.bottomAnchor.constraint(equalTo: livewindow.bottomAnchor),
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

    @IBAction func filterClick(_: UIButton) {
        let filterView = PackagePanel.newInstance()
        view.addSubview(filterView)
        filterView.show()
        if let filterView = filterView as? PackagePanel {
            let filterService = capture?.filterService
            filterView.packageService = filterService
            filterView.dataSource = filterService
        }
    }

    @IBAction func switchCamera(_: UISwitch) {
        capture?.switchCamera()
    }

    @IBAction func captionClick(_: Any) {
        guard let capture = capture else { return }
        let captionView = CaptionView.newInstance() as! CaptionView
        view.addSubview(captionView)
        captionView.show()

        rectView.moveable = capture.captionService
        capture.captionService.rectable = rectView
        capture.captionService.livewindow = livewindow
        captionView.captionService = capture.captionService
        _ = capture.captionService.addCaption(text: "请输入字幕")

        captionView.didViewClose = { [weak self] isCancelled in
            self?.rectView.moveable = nil
        }
    }

    @IBAction func sticker(_: Any) {
        let sticker = PackagePanel.newInstance()
        view.addSubview(sticker)
        sticker.show()
        sticker.didViewClose = { [weak self] isCancelled in
            self?.rectView.moveable = nil
        }
        if let sticker = sticker as? PackagePanel {
            rectView.moveable = capture?.stickerService
            capture?.stickerService.livewindow = livewindow
            capture?.stickerService.rectable = rectView
            let stickerService = capture?.stickerService
            sticker.packageService = stickerService            
            sticker.dataSource = stickerService
        }
    }

    @IBAction func comCaption(_: Any) {
        if let comCaptionView = PackagePanel.newInstance() as? PackagePanel {
            view.addSubview(comCaptionView)
            comCaptionView.show()
            let comCaptionService = capture?.comCaptionService
            rectView.moveable = comCaptionService
            comCaptionService?.livewindow = livewindow
            comCaptionService?.rectable = rectView
            comCaptionView.packageService = comCaptionService
            comCaptionView.dataSource = comCaptionService
        }
    }

    @IBAction func props(_: Any) {
        guard let capture = capture else { return }
        let propView = PackagePanel.newInstance()
        view.addSubview(propView)
        propView.show()
        if let propView = propView as? PackagePanel {
            let arsceneService = capture.arsceneService
            propView.packageService = arsceneService
            propView.dataSource = arsceneService
        }
    }
}
