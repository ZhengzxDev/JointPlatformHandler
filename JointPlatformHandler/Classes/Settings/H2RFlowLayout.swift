//
//  H2RFlowLayout.swift
//  schoolAirdrop2.0
//
//  Created by 郑正雄 on 2020/7/17.
//  Copyright © 2020 郑正雄. All rights reserved.
//

import UIKit

class H2RFlowLayout:UICollectionViewFlowLayout{
    // 保存所有item
    fileprivate var attributesArr: [UICollectionViewLayoutAttributes] = []
    
    override var collectionViewContentSize: CGSize {
        let itemWidth = min(itemSize.width,collectionView!.bounds.width)
        let itemCount = CGFloat(collectionView?.numberOfItems(inSection: 0) ?? 0)
        var newWidth = itemCount * itemWidth + (itemCount - 1) * minimumInteritemSpacing
        newWidth += sectionInset.left + sectionInset.right
        return CGSize(width: newWidth, height: collectionView!.bounds.height)
    }

    // MARK:- 重新布局
    override func prepare() {
        super.prepare()
        
        attributesArr = []
        
        let pageSize = self.collectionView!.bounds
        let itemHeight = min(itemSize.height,collectionView!.bounds.height)
        let itemWidth = min(itemSize.width,collectionView!.bounds.width)
        itemSize = CGSize(width: itemWidth, height: itemHeight)
        scrollDirection = .horizontal
        
        let itemsCount = collectionView?.numberOfItems(inSection: 0) ?? 0
        for index in 0 ..< itemsCount{
            let indexPath = IndexPath(row: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            let frame = CGRect(x: sectionInset.left + (itemWidth + minimumInteritemSpacing)*CGFloat(index), y: (pageSize.height - itemHeight)/2 + sectionInset.top - sectionInset.bottom, width: itemWidth, height:itemHeight )
            attributes.frame = frame
            attributesArr.append(attributes)
        }
        
        /*// 设置itemSize
        let containerFrame = CGRect(x: pageInset.left, y: pageInset.top, width: pageWidth - pageInset.left - pageInset.right, height: pageHeight - pageInset.top - pageInset.bottom)
        let itemW = (containerFrame.width - CGFloat(numberInRow - 1) * minimumLineSpacing)/CGFloat(numberInRow)
        let itemH = (containerFrame.height - CGFloat(rowsInPage - 1) * minimumInteritemSpacing)/CGFloat(rowsInPage)
        itemSize = CGSize(width: itemW , height: itemH)

        
        // 设置collectionView属性
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = true
        //let insertMargin = (collectionView!.bounds.height - 3 * itemWH) * 0.5
        collectionView?.contentInset = UIEdgeInsets(top: pageInset.top, left: 0, bottom: pageInset.bottom, right: 0)
        
        
        let itemsCountInPage = rowsInPage * numberInRow
        let itemsCount = collectionView?.numberOfItems(inSection: 0) ?? 0
        for index in 0..<itemsCount{
            let indexPath = IndexPath(row: index, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            //在第几页
            let page = floor(CGFloat(index/itemsCountInPage))
            //在本页的下标
            let pageIndex = index%itemsCountInPage
            //在本页的行
            let pageLineIndex = floor(CGFloat(pageIndex/numberInRow))
            //在本页的本行的下标
            let pageInLineIndex = CGFloat(pageIndex) - pageLineIndex * CGFloat(numberInRow)
            
            let x = page * pageWidth + containerFrame.origin.x + pageInLineIndex * minimumLineSpacing + pageInLineIndex * itemSize.width
            let y = containerFrame.origin.y + pageLineIndex * (minimumInteritemSpacing + itemSize.height)
            //print("x= \(x) | y= \(y) | w= \(itemSize.width) | h= \(itemSize.height) ")
            
            attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
            attributesArr.append(attributes)
        }*/
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
