//
//  AlignProperty.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/3/21.
//

import Foundation

@propertyWrapper
struct AlignWrapper {
    private var align: UInt!
    var wrappedValue: UInt = 0 {
        didSet {
            wrappedValue = (wrappedValue + align) & ~align
        }
    }

    init(align: UInt = 2) {
        self.align = align - 1
    }
}
