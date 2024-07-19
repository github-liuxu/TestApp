//
//  Livewindow.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/26.
//

import UIKit
import NvStreamingSdkCore

class PreView: UIView {

    @IBOutlet weak var livewindow: NvsLiveWindow!
    
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    var playBackAction: ((_ btn: UIButton)->())? = nil
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
        let view =  nib.instantiate(withOwner: self).first as? Self
        return view
    }
}
