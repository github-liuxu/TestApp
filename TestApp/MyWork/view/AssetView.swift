//
//  AssetView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/31.
//

import UIKit

class AssetView: UIView {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var collectionView: UICollectionView!
    var dataSources: [DataSourceItem] = [DataSourceItem]()
    var didSelectBlock: ((_ index: Int, _ item: DataSourceItem) -> Void)? = nil
    var didSliderValueChanged: ((_ value: Float) -> Void)? = nil
    var setCloseBlock: (() -> Void)? = nil
    override func awakeFromNib() {
        setup()
        super.awakeFromNib()
    }
    
    func setup() {
        let nib = UINib(nibName: "AssetCollectionViewCell", bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: "AssetCollectionViewCell")
    }
    
    @IBAction func closeClick(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: self.frame.size)
        } completion: { finish in
            self.removeFromSuperview()
            self.setCloseBlock?()
        }
    }
    
    func reload() {
        collectionView.reloadData()
//        let t1 = Date().timeIntervalSince1970
//        let scale = UIScreen.main.scale
//        let size = CGSize(width: self.superview!.bounds.width, height: self.superview!.bounds.height)
//        UIGraphicsBeginImageContextWithOptions(size, false, scale)
//        defer { UIGraphicsEndImageContext() }
//        let context = UIGraphicsGetCurrentContext()
//        self.superview!.layer.render(in: context!)
//        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
//        let t2 = Date().timeIntervalSince1970
//        print(t2-t1)
//        uiImage?.cgImage
//        let image = UIImageView(image: uiImage)
//        superview!.addSubview(image)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        didSliderValueChanged?(slider.value)
    }
    
    func didSelectItem(_ block: @escaping ((_ index: Int, _ item: DataSourceItem) -> Void)) {
        didSelectBlock = block
    }
    
    class func LoadView() -> AssetView? {
        let nib = UINib.init(nibName: "AssetView", bundle: Bundle.main)
        return nib.instantiate(withOwner: self).first as? AssetView
    }
}

extension AssetView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        cell.imageView.image = UIImage(contentsOfFile: dataSources[indexPath.item].imagePath)
        cell.name.text = dataSources[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.borderWidth = 5
        cell.contentView.layer.borderColor = UIColor.blue.cgColor
        cell.contentView.layer.masksToBounds = true
        didSelectBlock?(indexPath.item, dataSources[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        cell.layer.cornerRadius = 2
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
    }
}
