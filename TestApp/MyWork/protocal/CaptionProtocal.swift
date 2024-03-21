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
}
