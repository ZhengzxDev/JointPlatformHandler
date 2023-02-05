//
//  LobbyListLayout.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/5.
//

import UIKit

class LobbyListLayout:UICollectionViewFlowLayout{
    
    fileprivate var attributesArr:[UICollectionViewLayoutAttributes] = []
    
    override var collectionViewContentSize: CGSize{
        
        let maxItemWidth = (collectionView!.bounds.width - sectionInset.left - sectionInset.right - minimumInteritemSpacing)/2
        let itemRealWidth = min(itemSize.width,maxItemWidth)
        let itemRealHeight = (itemSize.height/itemSize.width) * itemRealWidth
        var verticalCount:CGFloat = 0
        let totalCount:Int = collectionView!.numberOfItems(inSection: 0)
        if totalCount % 2 == 0{
            verticalCount = CGFloat(totalCount/2)
        }
        else{
            verticalCount = CGFloat((totalCount+1)/2)
        }
        let verticalHeight = verticalCount * itemRealHeight + (verticalCount - 1) * minimumLineSpacing + sectionInset.top + sectionInset.bottom
        return CGSize(width: collectionView!.bounds.width, height: verticalHeight)
        
    }
    
    
    override func prepare() {
        super.prepare()
        
        attributesArr = []
        
        let maxItemWidth = (collectionView!.bounds.width - sectionInset.left - sectionInset.right - minimumInteritemSpacing)/2
        let itemRealWidth = min(itemSize.width,maxItemWidth)
        let itemRealHeight = (itemSize.height/itemSize.width) * itemRealWidth
        
        if maxItemWidth > itemRealWidth{
            let block = collectionView!.bounds.width -  2 * itemRealWidth - minimumInteritemSpacing
            sectionInset.left = block/2
            sectionInset.right = block/2
        }
        
        var startY = sectionInset.top
        
        for index in 0 ..< collectionView!.numberOfItems(inSection: 0){
            let indexPath = IndexPath(row: index, section: 0)
            if index % 2 == 0 && index != 0 {
                startY += itemRealHeight + minimumLineSpacing
            }
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(x: index % 2 == 0 ? sectionInset.left : sectionInset.left + itemRealWidth + minimumInteritemSpacing, y: startY, width: itemRealWidth, height: itemRealHeight)
            
            attributes.frame = frame
            attributesArr.append(attributes)
        }
        
    }
    
    // 获取 Cell 视图的布局，要重写【在移动/删除的时候会调用该方法】
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesArr.filter({ $0.indexPath == indexPath && $0.representedElementCategory == .cell }).first
    }
    
    // 获取 SupplementaryView 视图的布局
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesArr.filter({ $0.indexPath == indexPath && $0.representedElementKind == elementKind }).first
    }
    
    // 此方法应该返回当前屏幕正在显示的视图的布局属性集合，要重写
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesArr.filter({ rect.intersects($0.frame) })
    }
    
}
