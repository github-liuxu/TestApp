//
//  FilterProtocal.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/2/4.
//

import Foundation

protocol FilterProtocal {
    func applyFilter(item: DataSourceItem)
    func setFilterStrength(value: Float)
    func getFilterStrength() -> Float
}
