//
//  EditViewController.swift
//  TestApp
//
//  Created by Mac-Mini on 2023/8/4.
//

import UIKit
import NvStreamingSdkCore
import Combine

class EditViewController: UIViewController, NvsStreamingContextDelegate {

    var albumUtils: OpenAlbumEnable?
    var localIdentifies = [String]()
    var preview: PreView!
    var preViewInteraction: PreViewTimelineInteraction!
    var filterInteraction: FilterInteraction?
    
    deinit {
        NvsStreamingContext.destroyInstance()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = getVertionString()
        guard let livewidow = PreView.loadView() else { return }
        var navBottom = 30.0
        if let frame = navigationController?.navigationBar.frame {
            navBottom = CGRectGetMaxY(frame)
        }
        livewidow.frame = CGRect(x: 0, y: navBottom, width: view.frame.width, height: 300)
        preview = livewidow
        view.addSubview(livewidow)
        
        let timelineAction = TimelineAction(livewindow: preview.livewindow)
        preViewInteraction = PreViewTimelineInteraction(timelineAction: timelineAction, preview: preview)
        timelineAction.addClips(localIds: localIdentifies)
        
        let save = UIBarButtonItem(title: "Save", style: .done, target: preViewInteraction, action: #selector(preViewInteraction.saveAction))
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
            filterInteraction = FilterInteraction(filterView, filterAction: self.preViewInteraction.timelineAction)
        }
    }
}
