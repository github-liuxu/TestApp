//
//  AssetView.swift
//  TestApp
//
//  Created by Mac-Mini on 2024/1/31.
//

import UIKit

class AssetView: UIView, BottomViewService {
    var didViewClose: ((Bool) -> Void)?
    @IBOutlet var slider: UISlider!
    @IBOutlet var collectionView: UICollectionView!
    var filterService: FilterService!
    var assetFetch: AssetGetter?
    override func awakeFromNib() {
        setup()
        super.awakeFromNib()
    }

    func setup() {
        let nib = UINib(nibName: "AssetCollectionViewCell", bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: "AssetCollectionViewCell")

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
        assetFetch = DataSource(Bundle.main.bundlePath + "/videofx", typeString: "videofx")
        assetFetch?.fetchData()
        assetFetch?.didFetchSuccess = { [weak self] _ in
            self?.collectionView.reloadData()
        }
    }

    @IBAction func closeClick(_: UIButton) {
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRect(origin: CGPoint(x: 0, y: screenHeight), size: self.frame.size)
        } completion: { _ in
            self.removeFromSuperview()
        }
        didViewClose?(false)
    }

    func reload() {
        collectionView.reloadData()
    }

    @IBAction func sliderValueChanged(_: UISlider) {
        filterService.setFilterStrength(value: slider.value)
    }

    static func newInstance() -> BottomViewService {
        let nib = UINib(nibName: "AssetView", bundle: Bundle.main)
        return nib.instantiate(withOwner: self).first as! BottomViewService
    }

    func show() {
        let height: CGFloat = 300
        let size = UIScreen.main.bounds.size
        frame = CGRectMake(0, size.height, size.width, height)
        UIView.animate(withDuration: 0.25) {
            self.frame = CGRectMake(0, size.height - height, size.width, height)
        }
    }
}

extension AssetView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return assetFetch?.dataSource.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        guard let assetFetch = assetFetch else { return cell }
        let item = assetFetch.dataSource[indexPath.item]
        cell.imageView.image = UIImage(contentsOfFile: item.imagePath)
        cell.name.text = item.name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.borderWidth = 5
        cell.contentView.layer.borderColor = UIColor.blue.cgColor
        cell.contentView.layer.masksToBounds = true
        guard let assetFetch = assetFetch else { return }
        let item = assetFetch.dataSource[indexPath.item]
        filterService.applyFilter(item: item)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        cell.layer.cornerRadius = 2
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
    }
}
