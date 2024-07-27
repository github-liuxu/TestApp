//
//  PackageList.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/7/17.
//

import JXSegmentedView
import NvStreamingSdkCore
import UIKit

class PackageList: UIView {
    @IBOutlet var collectionView: UICollectionView!
    var dataSource: [DataSourceItemProtocol]? {
        didSet {
            collectionView.reloadData()
        }
    }

    var didSelectedPackage: ((DataSourceItemProtocol) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 70, height: 70)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        collectionView.collectionViewLayout = layout
        var width = 0.0
        var num = 0
        while width < frame.size.width {
            width = width + layout.itemSize.width + layout.minimumInteritemSpacing
            num += 1
        }
        num -= 1
        let offsetX: CGFloat = (frame.size.width - CGFloat(num) * layout.itemSize.width - CGFloat(num - 1) * layout.minimumInteritemSpacing) / 2.0
        collectionView.contentInset = UIEdgeInsets(top: 0, left: offsetX + 4, bottom: 34, right: offsetX + 4)
        collectionView.dataSource = self
        collectionView.delegate = self
        let nib = UINib(nibName: "AssetCollectionViewCell", bundle: Bundle(for: AssetCollectionViewCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: "AssetCollectionViewCell")
    }

    static func newInstance() -> PackageList {
        let nib = UINib(nibName: "PackageList", bundle: Bundle(for: PackageList.self))
        return nib.instantiate(withOwner: self).first as! PackageList
    }
}

extension PackageList: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }

    @objc func listWillAppear() {}

    @objc func listDidAppear() {}

    @objc func listWillDisappear() {}

    @objc func listDidDisappear() {}
}

extension PackageList: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return dataSource?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        let item = dataSource?[indexPath.item]
        cell.imageView.image = UIImage(contentsOfFile: item!.imagePath)
        cell.name.text = item!.name
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource?[indexPath.item]
        didSelectedPackage?(item!)
    }
}
