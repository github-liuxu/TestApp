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

    var localIdentifies = [String]()
    var preview: PreView!
    var preViewInteraction: PreViewTimelineInteraction!
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

}
