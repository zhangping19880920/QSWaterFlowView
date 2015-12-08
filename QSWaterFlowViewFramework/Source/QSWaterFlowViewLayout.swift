//
//  QSWaterFlowViewLayout.swift
//  QSWaterFlowViewFramework
//
//  Created by zhangping on 15/12/8.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

/*
    UICollectionViewLayout 方法调用顺序:
            1. prepareLayout
            2. collectionViewContentSize
            3. layoutAttributesForElementsInRect
            4. layoutAttributesForItemAtIndexPath
            5. collectionViewContentSize
*/

/// 瀑布流代理
@objc public protocol QSWaterFlowViewLayoutDelegate: NSObjectProtocol {
    /// 返回item需要显示的高
    optional func waterFlowViewLayout(waterFlowViewLayout: QSWaterFlowViewLayout, showHeightForWidth: CGFloat, atIndexPath: NSIndexPath) -> CGFloat
    
    /// 返回item对应的原始尺寸,waterFlowViewLayout内部来计算等比例缩放后的尺寸
    optional func waterFlowViewLayout(waterFlowViewLayout: QSWaterFlowViewLayout, originSizeForItemAtIndexPath: NSIndexPath) -> CGSize
}

/// 瀑布流
public class QSWaterFlowViewLayout: UICollectionViewLayout {
    // MARK: - 属性
    /// 默认间距
    private static let DefaultValue: CGFloat = 7
    
    /// 代理
    public weak var delegate: QSWaterFlowViewLayoutDelegate?
    
    /// 四周间距,默认10
    var sectionInset = UIEdgeInsets(top: DefaultValue, left: DefaultValue, bottom: DefaultValue, right: DefaultValue)
    
    /// 列间距,默认10
    var columnMargin: CGFloat = DefaultValue
    
    /// 行间距,默认10
    var rowMargin: CGFloat = DefaultValue
    
    /// 瀑布流列数,默认3列
    var columnsCount = 3
    
    /// 每列的宽度
    private var columnWidth: CGFloat = 0
    
    /// 每一列的最大高度
    private var maxYDict = [Int: CGFloat]()
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 默认构造函数
    public override init() {
        super.init()
    }

    /**
    构造函数
    - parameter columnsCount: 列数
    - parameter sectionInset: 四周边距
    - parameter columnMargin: 列间距
    - parameter rowMargin:    行间距
    */
    public init(columnsCount: Int, sectionInset: UIEdgeInsets, columnMargin: CGFloat, rowMargin: CGFloat) {
        self.columnsCount = columnsCount
        self.sectionInset = sectionInset
        self.columnMargin = columnMargin
        self.rowMargin = rowMargin
        super.init()
    }
    
    /// 存放所有的item的布局属性
    private var layoutAttrs = [UICollectionViewLayoutAttributes]()
    
    /// 将要开始布局,当调用collectionView的reloadData时调用
    public override func prepareLayout() {
        super.prepareLayout()

        guard let collectionView = self.collectionView else {
            print("\(__FUNCTION__): collecitonView 为空")
            return
        }
        
        // 计算宽度
        columnWidth = (collectionView.frame.size.width - sectionInset.left - sectionInset.right - (CGFloat(columnsCount) - 1) * columnMargin) / CGFloat(columnsCount)
        
        // 清空每一列的最大Y值
        for i in 0..<columnsCount {
            maxYDict[i] = 0
        }
        
        // 清空所有item的布局属性
        layoutAttrs.removeAll()
        
        // 获取要显示cell的数量
        let count = collectionView.numberOfItemsInSection(0)
        
        // 计算所有item的位置
        for i in 0..<count {
            // 计算对应item的 布局属性
            if let layoutAttr = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0)) {
                layoutAttrs.append(layoutAttr)
            }
        }
        
    }
    
    /**
    计算 collectionView的ContentSize
    - 在layoutAttributesForElementsInRect之后调用
    - returns: ContentSize
    */
    public override func collectionViewContentSize() -> CGSize {
        // 找到最长那一列
        var maxYColumn = 0
        
        for (column, maxY) in maxYDict {
            if maxY > maxYDict[maxYColumn] {
                maxYColumn = column
            }
        }
        
        // 获取最长那一列的Y值
        let size = CGSize(width: collectionView!.frame.size.width, height: maxYDict[maxYColumn]!)
        return size
    }
    
    /// 计算第indexPath个item的位置
    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        // 获取最短那一列
        var minYColumn = 0  // 先假设第0列最短
        for (column, maxY) in maxYDict {
            // 当前这列的最大Y值 小于 第 minYColumn 列的最大Y值
            if maxY < maxYDict[minYColumn] {
                // 找到更短的一列
                minYColumn = column
            }
        }
        
        // 计算高度, 高度让别人传入
        let height = heightAtIndexPath(indexPath)
        
        // 计算位置
        let x = sectionInset.left + (columnWidth + columnMargin) * CGFloat(minYColumn)
        let y = maxYDict[minYColumn]! + rowMargin
        
        let layoutAttr = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        layoutAttr.frame = CGRect(x: x, y: y, width: columnWidth, height: height)
        
        // 更新最短这列的Y值
        maxYDict[minYColumn] = y + height
        
        return layoutAttr
    }
    
    /**
    每当滚动到下一页时会调用
    - parameter rect: 显示的范围
    - returns: item的布局
    */
    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttrs
    }
    
    /// 获取item对应的高度
    private func heightAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        // 判断代理是否有实现 waterFlowViewLayout: showHeightForWidth: atIndexPath
        if let height = delegate?.waterFlowViewLayout?(self, showHeightForWidth: columnWidth, atIndexPath: indexPath) {
            
            return height
        } else if let originSize = delegate?.waterFlowViewLayout?(self, originSizeForItemAtIndexPath: indexPath) {
            let newHeight = columnWidth * originSize.height / originSize.width
            
            return newHeight
        } else {
            /*
                瀑布流布局需要一个实现QSWaterFlowViewLayoutDelegate协议的代理,来获取瀑布流每个item的高度
                    必须实现下面2个方法中的一个
                        1.optional func waterFlowViewLayout(waterFlowViewLayout: QSWaterFlowViewLayout, showHeightForWidth: CGFloat, atIndexPath: NSIndexPath) -> CGFloat
                        2.optional func waterFlowViewLayout(waterFlowViewLayout: QSWaterFlowViewLayout, originSizeForItemAtIndexPath: NSIndexPath) -> CGSize
            */
            assertionFailure("请实现 QSWaterFlowViewLayoutDelegate 代理,并实现 showHeightForWidth, originSizeForItemAtIndexPath 中至少一个方法,优先采用showHeightForWidth")
            return 0
        }
    }
}
