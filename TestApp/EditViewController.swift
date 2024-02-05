//
//  EditViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2023/8/4.
//

import UIKit
import NvStreamingSdkCore
import Combine

class EditViewController: UIViewController {

    var albumUtils: OpenAlbumEnable?
    var localIdentifies = [String]()
    var preview: PreView!
    var timelineAction: TimelineAction?
    @IBOutlet weak var sequenceView: UIView!
    var sequence: SequenceView?
    var filterInteraction: FilterInteraction?
    
    @IBOutlet weak var sequenceTop: NSLayoutConstraint!
    deinit {
        NvsStreamingContext.destroyInstance()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = getVertionString()
        setup()
        timelineAction = TimelineAction(livewindow: preview.livewindow)
        guard let timelineAction = timelineAction else { return }
        
        bind()
        timelineAction.addClips(localIds: localIdentifies)
        sequence?.sequenceInitLoad(videoTrack: timelineAction.timeline.getVideoTrack(by: 0))
        let save = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAction))
        navigationItem.setRightBarButton(save, animated: true)
        // Do any additional setup after loading the view.

    }

    @IBAction func fliterClick(_ sender: UIButton) {
        if let filterView = AssetView.LoadView() {
            view.addSubview(filterView)
            filterView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, 300)
            UIView.animate(withDuration: 0.25) {
                filterView.frame = CGRectMake(0, self.view.frame.size.height - 300, self.view.frame.size.width, 300)
            }
            filterInteraction = FilterInteraction(filterView, filterAction: timelineAction!)
        }
    }
    
    @objc func saveAction() {
        timelineAction?.saveAction(nil)
    }
    
    func setup() {
        guard let livewidow = PreView.loadView() else { return }
        var navBottom = 30.0
        if let frame = navigationController?.navigationBar.frame {
            navBottom = CGRectGetMaxY(frame)
        }
        livewidow.frame = CGRect(x: 0, y: navBottom, width: view.frame.width, height: 300)
        preview = livewidow
        view.addSubview(livewidow)
        sequence = SequenceView.LoadView()
        guard let seq = sequence else { return }
        sequenceView.addSubview(seq)
        sequenceTop.constant = CGRectGetMaxY(livewidow.bounds)
    }
    
    func bind() {
        preview.playBackAction = { [weak self] btn in
            guard let weakSelf = self else { return }
            weakSelf.timelineAction?.playClick(btn)
        }
        
        timelineAction?.playStateChanged = { [weak self] isPlay in
            guard let weakSelf = self else { return }
            weakSelf.preview.setPlayState(isPlay: isPlay)
        }
        timelineAction?.timeValueChanged = { [weak self] currentTime, duration in
            guard let weakSelf = self else { return }
            weakSelf.preview.currentTime.text = currentTime
            weakSelf.preview.durationTime.text = duration
        }

        timelineAction?.compileProgressChanged = { progress in
            print(progress)
        }
        
        sequence?.valueChangedAction = { [weak self] value in
            guard let weakSelf = self else { return }
            weakSelf.timelineAction?.sliderValueChanged(value)
        }
        
        sequence?.addAlbmAction = { [weak self] in
            guard let weakSelf = self else { return }
            let time = weakSelf.timelineAction?.timeline.duration ?? 0
            weakSelf.albumUtils?.openAlbum(viewController: weakSelf, { phassets in
                weakSelf.timelineAction?.addClips(localIds: phassets.map({ phasset in
                    return phasset.localIdentifier
                }))
                weakSelf.sequence?.sequenceInitLoad(videoTrack: weakSelf.timelineAction!.timeline.getVideoTrack(by: 0))
                weakSelf.sequence?.seekValue(time)
            })
        }
        
        timelineAction?.didPlaybackTimelinePosition = {[weak self] position, progress in
            guard let weakSelf = self else { return }
            weakSelf.sequence?.seekValue(position)
        }
        
    }
}
