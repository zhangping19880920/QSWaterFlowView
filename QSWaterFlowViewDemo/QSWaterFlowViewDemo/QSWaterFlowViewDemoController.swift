//
//  ViewController.swift
//  QSWaterFlowViewDemo
//
//  Created by zhangping on 15/12/8.
//  Copyright © 2015年 zhangping. All rights reserved.
//

import UIKit

import QSWaterFlowViewFramework

class QSWaterFlowViewDemoController: UIViewController {
    
    // MARK: - 属性
    /// 瀑布流布局
    private var waterFlowLayout = QSWaterFlowViewLayout()
    
    private let CellReuseIdentifier = "CellReuseIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareCollectionView()
    }
    
    // MARK: - 准备CollecitonView
    private func prepareCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = UIColor.lightGrayColor()
        
        // 约束,填充父控件
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[cv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["cv" : collectionView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[cv]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["cv" : collectionView]))
        
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: CellReuseIdentifier)
        collectionView.dataSource = self
        waterFlowLayout.delegate = self
    }
    
    // MAKR: - 懒加载
    /// collectionView
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.waterFlowLayout)
}

// MARK: - 扩展 QSWaterFlowViewDemoController 实现 UICollectionViewDataSource
extension QSWaterFlowViewDemoController: UICollectionViewDataSource, UICollectionViewDelegate, QSWaterFlowViewLayoutDelegate {
    
    // 返回cell数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 300
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellReuseIdentifier, forIndexPath: indexPath)

        cell.backgroundColor = UIColor.randomColor()
        
        return cell
    }
    
    /// 返回cell的高度
//    func waterFlowViewLayout(waterFlowViewLayout: QSWaterFlowViewLayout, showHeightForWidth: CGFloat, atIndexPath: NSIndexPath) -> CGFloat {
//        return 100 + CGFloat(arc4random_uniform(30))
//    }
    
    /// 返回cell图片的原始大小,瀑布流会自动计算高度
    func waterFlowViewLayout(waterFlowViewLayout: QSWaterFlowViewLayout, originSizeForItemAtIndexPath: NSIndexPath) -> CGSize {
        let width = 100 + Int(arc4random_uniform(30))
        let height = 100 + Int(arc4random_uniform(100))
        return CGSize(width: width, height: height)
    }
}