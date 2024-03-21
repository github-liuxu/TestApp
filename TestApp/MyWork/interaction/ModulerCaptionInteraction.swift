//
//  ModulerCaptionInteraction.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/3/20.
//

import UIKit

class ModulerCaptionInteraction: NSObject {
    var captionAction: CaptionProtocal
    init(captionAction: CaptionProtocal) {
//        self.compoundCaptionView = compoundCaptionView
        self.captionAction = captionAction
        super.init()
//        bind()
    }

}
