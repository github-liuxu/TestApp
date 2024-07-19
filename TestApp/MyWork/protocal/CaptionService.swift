//
//  CaptionService.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/3/1.
//

import Foundation
import NvStreamingSdkCore

protocol CaptionService {
    func addCaption(text: String) -> NvsCaption
    func deleteCaption()
    func getAllCaption() -> [NvsCaption]
    func setCaptionText(text: String)
    func setCaptionTextColor(text: String)
    func applyCaptionPackage(packagePath: String, licPath: String, type: String)
    var didCaptionTextChanged: ((String?) -> Void)? { get set }
    var assetGetter: DataSource? { get set }
}

protocol Moveable: NSObjectProtocol {
    func translate(prePoint: CGPoint, curPoint: CGPoint)
    func scale(scale: Float)
    func rotate(rotate: Float)
    func tap(point: CGPoint)
}
