//
//  EditViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2023/8/4.
//

import AVFAudio
import Dispatch
import NvStreamingSdkCore
import Toast_Swift
import UIKit

class EditViewController: UIViewController {
    var albumUtils: OpenAlbumEnable?
    var localIdentifies = [String]()
    var preview: PreView!
    var timelineService: TimelineService?
    @IBOutlet var sequenceView: UIView!
    var sequence: SequenceView?
    var transitionInteraction: TransitionInteraction?
    @IBOutlet var bottomCollectionView: UICollectionView!
    @IBOutlet var sequenceTop: NSLayoutConstraint!
    
    var bottomDataSource = [BottomItem]()
    
    deinit {
        NvsStreamingContext.destroyInstance()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = getVertionString()
        Subview()
        timelineService = TimelineService(livewindow: preview.livewindow)
        guard let timelineService = timelineService else { return }
        
        Listen()
        timelineService.addClips(localIds: localIdentifies)
        sequence?.sequenceInitLoad(videoTrack: timelineService.timeline.getVideoTrack(by: 0))
        let save = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAction))
        navigationItem.setRightBarButton(save, animated: true)
        // Do any additional setup after loading the view.
    }
    
    @objc func saveAction() {
        view.makeToastActivity(.center)
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
        bottomDataSource.append(BottomItem(viewClass: AssetView.self, title: "Filter"))
        bottomDataSource.append(BottomItem(viewClass: CaptionView.self, title: "Caption"))
        bottomDataSource.append(BottomItem(viewClass: StickerView.self, title: "Sticker"))
        bottomDataSource.append(BottomItem(viewClass: CompoundCaptionView.self, title: "CompoundCaption"))
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 88, height: 74)
        layout.minimumLineSpacing = 0
        bottomCollectionView.collectionViewLayout = layout
        bottomCollectionView.delegate = self
        bottomCollectionView.dataSource = self
        let nib = UINib(nibName: "BottomCollectionViewCell", bundle: Bundle(for: BottomCollectionViewCell.self))
        bottomCollectionView.register(nib, forCellWithReuseIdentifier: "BottomCollectionViewCell")
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
            weakSelf.albumUtils?.openAlbum(viewController: weakSelf) { phassets in
                weakSelf.timelineService?.addClips(localIds: phassets.map { phasset in
                    phasset.localIdentifier
                })
                weakSelf.sequence?.sequenceInitLoad(videoTrack: weakSelf.timelineService!.timeline.getVideoTrack(by: 0))
                weakSelf.sequence?.seekValue(time)
            }
        }
        
        timelineService?.didPlaybackTimelinePosition = { [weak self] position, _ in
            guard let weakSelf = self else { return }
            weakSelf.sequence?.seekValue(position)
        }
    }
}

extension EditViewController: TransitionCoverViewDelegate {
    func didSelectIndex(index: Int) {
        let transitionView = AssetView.newInstance() as! AssetView
        view.addSubview(transitionView)
        let height: CGFloat = 300
        transitionView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, height)
        UIView.animate(withDuration: 0.25) {
            transitionView.frame = CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height)
        }
//        transitionInteraction = TransitionInteraction(transitionView, transitionAction: timelineService!)
//        transitionInteraction!.transitionIndex = index
    }
}

extension EditViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        bottomDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomCollectionViewCell", for: indexPath) as! BottomCollectionViewCell
        cell.title.text = bottomDataSource[indexPath.item].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = bottomDataSource[indexPath.item]
        let subview = item.viewClass.newInstance()
        view.addSubview(subview)
        subview.show()
        if item.title == "Filter" {
            if let sub = subview as? AssetView {
                sub.filterService = timelineService?.filterService
            }
        }
        if item.title == "Caption" {
            if let sub = subview as? CaptionView {
                preview.rectView.moveable = timelineService?.captionService
                timelineService?.captionService.rectable = preview.rectView
                sub.captionService = timelineService?.captionService
                _ = timelineService?.captionService.addCaption(text: "请输入字幕")
            }
        }
        if item.title == "CompoundCaption" {
            if let sub = subview as? CompoundCaptionView {
                sub.comCaptionService = timelineService?.comCaptionService
            }
        }
        if item.title == "Sticker" {
            if let sub = subview as? StickerView {
                preview.rectView.moveable = timelineService?.stickerService
                timelineService?.stickerService.rectable = preview.rectView
                sub.stickerService = timelineService?.stickerService
            }
        }
    }
}
