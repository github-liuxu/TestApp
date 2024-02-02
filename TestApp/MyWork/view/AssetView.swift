//
//  AssetView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/31.
//

import UIKit

class AssetView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    var dataSources: [DataSourceItem] = [DataSourceItem]()
    var didSelectBlock: ((_ index: Int, _ item: DataSourceItem) -> Void)? = nil
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
        }
    }
    
    func reload() {
        collectionView.reloadData()
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectBlock?(indexPath.item, dataSources[indexPath.item])
    }
}
