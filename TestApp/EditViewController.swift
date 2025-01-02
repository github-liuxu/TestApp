//
//  EditViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2023/8/4.
//

import AVFAudio
import Combine
import Dispatch
import NvStreamingSdkCore
import Toast
import UIKit

class EditViewController: UIViewController {
    var albumUtils: OpenAlbumEnable?
    var localIdentifies = [String]()
    var preview: PreView!
    var timelineService: TimelineService?
    @IBOutlet var sequenceView: UIView!
    var sequence: SequenceView?
    @IBOutlet var bottomCollectionView: UICollectionView!
    @IBOutlet var sequenceTop: NSLayoutConstraint!
    let operate = RectMoveableImp()
    var bottomDataSource = [BottomItem]()
    private var cancellables = Set<AnyCancellable>()
    deinit {
        timelineService?.clear()
        NvsStreamingContext.destroyInstance()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = getVertionString()
        Subview()
        timelineService = TimelineService(livewindow: preview.livewindow)
        guard let timelineService = timelineService else { return }
        operate.livewindow = preview.livewindow
        operate.timelineService = timelineService
        preview.rectView.moveable = operate
        Listen()
        timelineService.addClips(localIds: localIdentifies)
        sequence?.sequenceInitLoad(videoTrack: timelineService.timeline!.getVideoTrack(by: 0))
        let save = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAction))
        navigationItem.setRightBarButton(save, animated: true)
        // Do any additional setup after loading the view.
    }

    @objc func saveAction() {
        view.makeToastActivity(.center)
        let compilePath = NSHomeDirectory() + "/Documents/" + currentDateAndTime() + ".mp4"
        timelineService?.saveAction(compilePath, coverPath: nil)?
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("Completed")
                    UISaveVideoAtPathToSavedPhotosAlbum(compilePath, nil, nil, nil)
                case let .failure(error):
                    print("Received error: \(error)")
                }
                self?.view.hideToastActivity()
            }, receiveValue: { progress in
                print(progress)
            }).store(in: &cancellables)
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
        bottomDataSource.append(BottomItem(viewClass: PackagePanel.self, title: "Filter"))
        bottomDataSource.append(BottomItem(viewClass: CaptionView.self, title: "Caption"))
        bottomDataSource.append(BottomItem(viewClass: PackagePanel.self, title: "Sticker"))
        bottomDataSource.append(BottomItem(viewClass: PackagePanel.self, title: "CompoundCaption"))
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

        sequence?.valueChangedAction = { [weak self] value in
            guard let weakSelf = self else { return }
            weakSelf.timelineService?.sliderValueChanged(value)
        }

        sequence?.addAlbmAction = { [weak self] in
            guard let weakSelf = self else { return }
            let time = weakSelf.timelineService?.timeline?.duration ?? 0
            weakSelf.albumUtils?.openAlbum(viewController: weakSelf) { phassets in
                weakSelf.timelineService?.addClips(localIds: phassets.map { phasset in
                    phasset.localIdentifier
                })
                weakSelf.sequence?.sequenceInitLoad(videoTrack: weakSelf.timelineService!.timeline!.getVideoTrack(by: 0))
                weakSelf.sequence?.seekValue(time)
            }
        }

        sequence?.didSelectClipIndex = { [weak self] index in
            let videoClipService = self?.timelineService?.getClipService(index: index)
        }

        timelineService?.didPlaybackTimelinePosition = { [weak self] position, _ in
            guard let weakSelf = self else { return }
            weakSelf.sequence?.seekValue(position)
        }
    }
}

extension EditViewController: TransitionCoverViewDelegate {
    func didSelectIndex(index: UInt32) {
        let transitionView = PackagePanel.newInstance() as! PackagePanel
        view.addSubview(transitionView)
        transitionView.show()
        let transitionService = timelineService?.transitionService
        transitionView.packageService = transitionService
        transitionView.dataSource = transitionService
        transitionService?.selectedIndex = UInt32(index)
    }
}

extension EditViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        bottomDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomCollectionViewCell", for: indexPath) as! BottomCollectionViewCell
        cell.title.text = bottomDataSource[indexPath.item].title
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = bottomDataSource[indexPath.item]
        let subview = item.viewClass.newInstance()
        view.addSubview(subview)
        subview.show()
        subview.didViewClose = { [weak self] _ in
            self?.preview.rectView.moveable = self?.operate
        }
        if item.title == "Filter" {
            if let sub = subview as? PackagePanel {
                let filterService = timelineService?.filterService
                sub.packageService = filterService
                sub.dataSource = filterService
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
            if let sub = subview as? PackagePanel {
                let comCaptionService = timelineService?.comCaptionService
                preview.rectView.moveable = comCaptionService
                comCaptionService?.rectable = preview.rectView
                sub.packageService = comCaptionService
                sub.dataSource = comCaptionService
            }
        }
        if item.title == "Sticker" {
            if let sub = subview as? PackagePanel {
                preview.rectView.moveable = timelineService?.stickerService
                timelineService?.stickerService.rectable = preview.rectView
                let stickerService = timelineService?.stickerService
                sub.packageService = stickerService
                sub.dataSource = stickerService
            }
        }
    }
}
