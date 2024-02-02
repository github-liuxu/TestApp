//
//  AssetView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/31.
//

import UIKit

class AssetView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
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
    
    class func LoadView() -> AssetView? {
        let nib = UINib.init(nibName: "AssetView", bundle: Bundle.main)
        return nib.instantiate(withOwner: self).first as? AssetView
    }
}

extension AssetView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        return cell
    }
    
    
}
