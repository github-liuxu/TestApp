//
//  Livewindow.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/26.
//

import UIKit
import NvStreamingSdkCore

protocol ConnectEnable {
    func connect(streamingContext: NvsStreamingContext, timeline: NvsTimeline?)
}

class PreView: UIView {

    @IBOutlet weak var livewindow: NvsLiveWindow!
    
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    var playBackAction: ((_ btn: UIButton)->())? = nil
    
    @IBAction func playClick(_ sender: UIButton) {
        playBackAction?(sender);
    }
    
    func setPlayState(isPlay: Bool) {
        if isPlay {
            playBtn.setTitle("Stop", for: .normal)
        } else {
            playBtn.setTitle("Play", for: .normal)
        }
    }
    
    static func loadView() -> Self? {
        let nib = UINib(nibName: "Livewindow", bundle: Bundle.main)
        return nib.instantiate(withOwner: self).first as? Self
    }
}

extension PreView: ConnectEnable {
    func connect(streamingContext: NvsStreamingContext, timeline: NvsTimeline?) {
        livewindow.fillMode = NvsLiveWindowFillModePreserveAspectFit
//        livewindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_Device
        streamingContext.connect(timeline, with: livewindow)
//        livewindow.setBackgroundColorWithRed(0, green: 0, blue: 0, alpha: 0);
    }
    
    
}
