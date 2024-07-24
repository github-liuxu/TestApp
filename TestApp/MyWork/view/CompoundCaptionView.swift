//
//  CompoundCaptionView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/3/20.
//

import UIKit

class CompoundCaptionView: UIView, BottomViewService {
    @IBOutlet weak var collectionView: UICollectionView!
    var comCaptionService: ComCaptionService!
    var assetGetter: AssetGetter!
    var didViewClose: (() -> Void)?
    override func awakeFromNib() {
        setup()
        super.awakeFromNib()
    }
    
    func setup() {
        let nib = UINib(nibName: "AssetCollectionViewCell", bundle: Bundle(for: AssetCollectionViewCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: "AssetCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        let captionDir = Bundle.main.bundlePath + "/compoundcaption"
        assetGetter = DataSource(captionDir, typeString: "compoundcaption")
        assetGetter.fetchData()
    }
    
    static func newInstance() -> BottomViewService {
        let nib = UINib.init(nibName: "CompoundCaptionView", bundle: Bundle(for: CompoundCaptionView.self))
        return nib.instantiate(withOwner: self).first as! BottomViewService
    }
    
    func show() {
        let height: CGFloat = 300
        let size = UIScreen.main.bounds.size
        self.frame = CGRectMake(0, size.height, size.width, height)
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRectMake(0, size.height - height, size.width, height)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: self.frame.size)
        } completion: { finish in
            self.removeFromSuperview()
        }
        didViewClose?()
    }
}
extension CompoundCaptionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetGetter.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        cell.imageView.image = UIImage(contentsOfFile: assetGetter.dataSource[indexPath.item].imagePath)
        cell.name.text = assetGetter.dataSource[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.borderWidth = 5
        cell.contentView.layer.borderColor = UIColor.blue.cgColor
        cell.contentView.layer.masksToBounds = true
        comCaptionService.applyComCaptionPackage(item: assetGetter.dataSource[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        cell.layer.cornerRadius = 2
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
    }
}
