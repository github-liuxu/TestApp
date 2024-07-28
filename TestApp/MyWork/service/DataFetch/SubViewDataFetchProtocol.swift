//
//  SubViewDataFetchProtocol.swift
//  TestApp
//
//  Created by 刘东旭 on 2024/7/28.
//

import Foundation

typealias SubViewDataFetchProtocol = PackageSubviewSource & DataSourceFetchService

protocol SubviewService: NSObjectProtocol {
    func willData()
    func didDataSuccess(packageSubviewSource: PackageSubviewSource)
    func didDataError(error: Error)
}
