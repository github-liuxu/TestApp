//
//  CapturePropServiceImp.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/22.
//

import UIKit
import NvStreamingSdkCore

protocol CaptureARSceneService {
    func cancelProps()
    func readARSceneInfo()
    func applyARScenePackage(packagePath: String, licPath: String, type: String)
    var assetGetter: DataSource? { get set }
}

class CaptureARSceneServiceImp: NSObject, CaptureARSceneService {
    var assetGetter: DataSource?
    let streamingContext = NvsStreamingContext.sharedInstance()!
    var arsceneFx: NvsCaptureVideoFx?
    var oldPropsId = ""
    override init() {
        super.init()
        let propsDir = Bundle.main.bundlePath + "/arscene"
        assetGetter = DataSource(propsDir, typeString: "arscene")
    }
    
    func readARSceneInfo() {
        oldPropsId = arsceneFx?.getStringVal("Scene Id") ?? ""
    }
    
    func cancelProps() {
        arsceneFx?.setStringVal("Scene Id", val: oldPropsId)
    }
    
    func applyARScenePackage(packagePath: String, licPath: String, type: String) {
        let pid = NSMutableString()
        streamingContext.assetPackageManager.installAssetPackage(packagePath, license: licPath, type: NvsAssetPackageType_ARScene, sync: true, assetPackageId: pid)
        arsceneFx?.setStringVal("Scene Id", val: pid as String)
        
    }
}
