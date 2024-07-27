//
//  PreView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/26.
//

import NvStreamingSdkCore
import UIKit

class PreView: UIView {
    @IBOutlet var livewindow: NvsLiveWindow!

    @IBOutlet var playBtn: UIButton!

    @IBOutlet var durationTime: UILabel!
    @IBOutlet var currentTime: UILabel!
    var playBackAction: ((_ btn: UIButton) -> Void)? = nil
    var rectView = RectView()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(rectView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rectView.frame = livewindow.frame
    }

    @IBAction func playClick(_ sender: UIButton) {
        playBackAction?(sender)
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
        let view = nib.instantiate(withOwner: self).first as? Self
        return view
    }
}
