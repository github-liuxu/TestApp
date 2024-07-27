//
//  BottomViewService.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/16.
//

import Foundation
import UIKit

protocol BottomViewService: UIView {
    static func newInstance() -> BottomViewService
    func show()
    var didViewClose: ((_ isCancel: Bool) -> Void)? { get set }
}

struct BottomItem {
    var viewClass: BottomViewService.Type
    var title: String
}
