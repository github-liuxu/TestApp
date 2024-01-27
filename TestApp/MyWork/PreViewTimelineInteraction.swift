//
//  TimelineInteraction.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/27.
//

import Foundation

class PreViewTimelineInteraction {
    var timelineAction: TimelineAction!
    var preview: PreView
    
    init(timelineAction: TimelineAction, preview: PreView) {
        self.timelineAction = timelineAction
        self.preview = preview
        bind()
    }
    
    func bind() {
        preview.playBackAction = { [weak self] btn in
            self?.timelineAction.playClick(btn)
        }
        
        preview.valueChangedAction = { [weak self] slider in
            self?.timelineAction.sliderValueChanged(slider)
        }
        
        timelineAction.playStateChanged = { [weak self] isPlay in
            self?.preview.setPlayState(isPlay: isPlay)
        }
        timelineAction.timeValueChanged = { [weak self] currentTime, duration in
            self?.preview.currentTime.text = currentTime
            self?.preview.durationTime.text = duration
        }
        timelineAction.compileProgressChanged = { progress in
            print(progress)
        }
        
    }
    
    @objc func saveAction() {
        timelineAction.saveAction(nil)
    }
}
