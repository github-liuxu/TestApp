//
//  CaptionProtocal.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/3/1.
//

import Foundation
import NvStreamingSdkCore

protocol CaptionProtocal {
    func addCaption(text: String) -> NvsCaption
    func deleteCaption(caption: NvsCaption)
    func getAllCaption() -> [NvsCaption]
    func setCaptionText(caption: NvsCaption, text: String)
    func setCaptionTextColor(caption: NvsCaption, text: String)
    func applyCaptionRenderer(caption: NvsCaption, rendererid: String)
    func applyCaptionContext(caption: NvsCaption, contextid: String)
    func applyCaptionAnimation(caption: NvsCaption, animationid: String)
    func selectCaption(point: CGPoint) -> NvsCaption
}
