//
//  EditViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2023/8/4.
//

import UIKit
import NvStreamingSdkCore
import Dispatch
import AVFAudio
import Toast

class EditViewController: UIViewController {

    var albumUtils: OpenAlbumEnable?
    var localIdentifies = [String]()
    var preview: PreView!
    var timelineService: TimelineService?
    @IBOutlet weak var sequenceView: UIView!
    var sequence: SequenceView?
    var filterInteraction: FilterInteraction?
    var transitionInteraction: TransitionInteraction?
    var compoundCaptionInteraction: CompoundCaptionInteraction?
    
    @IBOutlet weak var sequenceTop: NSLayoutConstraint!
    deinit {
        NvsStreamingContext.destroyInstance()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = getVertionString()
        Subview()
        timelineService = TimelineService(connect: preview)
        guard let timelineService = timelineService else { return }
        
        Listen()
        timelineService.addClips(localIds: localIdentifies)
        sequence?.sequenceInitLoad(videoTrack: timelineService.timeline.getVideoTrack(by: 0))
        let save = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAction))
        navigationItem.setRightBarButton(save, animated: true)
        // Do any additional setup after loading the view.
//        timelineService.matting()
//        timelineService.addCaption()
        timelineService.addAnimationSticker()
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 0) + 3, execute: DispatchWorkItem(block: {
//            timelineService.streamingContext.setColorGainForSDRToHDR(5.0)
//            timelineService.seek(time: 8000000)
//        }))

    }

    @IBAction func fliterClick(_ sender: UIButton) {
        if let filterView = AssetView.LoadView() {
            view.addSubview(filterView)
            let height: CGFloat = 300
            filterView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, height)
            UIView.animate(withDuration: 0.25) {
                filterView.frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height)
            }
            filterInteraction = FilterInteraction(filterView, filterAction: timelineService!)
        }
    }
    
    @IBAction func captionClick(_ sender: UIButton) {
        let captionInteraction = ModulerCaptionInteraction(captionAction: timelineService!)
    }
    
    @IBAction func compoundCaptionClick(_ sender: UIButton) {
        let height: CGFloat = 300
        let compoundCaptionView = CompoundCaptionView.init(frame: CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height))
        view.addSubview(compoundCaptionView)
        compoundCaptionView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, height)
        UIView.animate(withDuration: 0.25) {
            compoundCaptionView.frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height)
        }
        compoundCaptionInteraction = CompoundCaptionInteraction(compoundCaptionView, compoundCaptionAction: timelineService!)
    }
    
    @objc func saveAction() {
        self.view.makeToastActivity(.center)
//        Toast.showLoading(string: "hskdjfhskdhksdhkdhsldfhl")
        timelineService?.saveAction(nil)
    }
    
    func Subview() {
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
        sequence?.transitionCoverDelegate = self
    }
    
    func Listen() {
        preview.playBackAction = { [weak self] btn in
            guard let weakSelf = self else { return }
            weakSelf.timelineService?.playClick(btn)
        }
        
        timelineService?.playStateChanged = { [weak self] isPlay in
            guard let weakSelf = self else { return }
            weakSelf.preview.setPlayState(isPlay: isPlay)
        }
        timelineService?.timeValueChanged = { [weak self] currentTime, duration in
            guard let weakSelf = self else { return }
            weakSelf.preview.currentTime.text = currentTime
            weakSelf.preview.durationTime.text = duration
        }

        timelineService?.compileProgressChanged = { progress in
            print(progress)
        }
        
        sequence?.valueChangedAction = { [weak self] value in
            guard let weakSelf = self else { return }
            weakSelf.timelineService?.sliderValueChanged(value)
        }
        
        sequence?.addAlbmAction = { [weak self] in
            guard let weakSelf = self else { return }
            let time = weakSelf.timelineService?.timeline.duration ?? 0
            weakSelf.albumUtils?.openAlbum(viewController: weakSelf, { phassets in
                weakSelf.timelineService?.addClips(localIds: phassets.map({ phasset in
                    return phasset.localIdentifier
                }))
                weakSelf.sequence?.sequenceInitLoad(videoTrack: weakSelf.timelineService!.timeline.getVideoTrack(by: 0))
                weakSelf.sequence?.seekValue(time)
            })
        }
        
        timelineService?.didPlaybackTimelinePosition = {[weak self] position, progress in
            guard let weakSelf = self else { return }
            weakSelf.sequence?.seekValue(position)
        }
        
    }
}

extension EditViewController: TransitionCoverViewDelegate {
    func didSelectIndex(index: Int) {
        if let transitionView = AssetView.LoadView() {
            view.addSubview(transitionView)
            let height: CGFloat = 300
            transitionView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, height)
            UIView.animate(withDuration: 0.25) {
                transitionView.frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height)
            }
            transitionInteraction = TransitionInteraction(transitionView, transitionAction: timelineService!)
            transitionInteraction!.transitionIndex = index
        }
    }
    
    
}
