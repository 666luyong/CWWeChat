//
//  CWMessageViewLayout.swift
//  CWWeChat
//
//  Created by chenwei on 2017/7/14.
//  Copyright © 2017年 cwcoder. All rights reserved.
//

import UIKit
import YYText

protocol CWMessageViewLayoutDelegate: NSObjectProtocol {
    func collectionView(_ collectionView: UICollectionView, itemAt indexPath: IndexPath) -> CWMessageModel
}

/**
 使用collectionView 不太熟悉 待完善
 */
class CWMessageViewLayout: UICollectionViewFlowLayout {
    
    weak var delegate: CWMessageViewLayoutDelegate?
    
    var setting = CWMessageLayoutSettings.share
    
    var needLayout: Bool = true
    
    var contentHeight = CGFloat()
    var cache = [IndexPath: CWMessageLayoutAttributes]()
    var visibleLayoutAttributes = [CWMessageLayoutAttributes]()
    
    override public class var layoutAttributesClass: AnyClass {
        return CWMessageLayoutAttributes.self
    }
    
    override public var collectionViewContentSize: CGSize {
        return CGSize(width: collectionViewWidth, height: contentHeight)
    }
    
    fileprivate var collectionViewHeight: CGFloat {
        return collectionView!.frame.height
    }
    
    fileprivate var collectionViewWidth: CGFloat {
        return collectionView!.frame.width
    }
    
    
    private var contentOffset: CGPoint {
        return collectionView!.contentOffset
    }
    
}


extension CWMessageViewLayout {
    
    func prepareCache() {
        cache.removeAll(keepingCapacity: true)
    }
    
    override func prepare() {
        
        guard let collectionView = collectionView,
            let delegate = self.delegate,
           needLayout == true else {
                return
        }
        prepareCache()
        
        needLayout = false
        contentHeight = 0
        // 计算布局
        let section = 0
        for item in 0 ..< collectionView.numberOfItems(inSection: section) {

            let cellIndexPath = IndexPath(item: item, section: section)
            let attributes = CWMessageLayoutAttributes(forCellWith: cellIndexPath)
                        
            configure(attributes: attributes)
            
            // cell 高度
            let heightOfCell = attributes.messageContainerFrame.height + kMessageCellBottomMargin + kMessageCellTopMargin

            attributes.frame = CGRect(x: 0, y: contentHeight, width: kScreenWidth, height: heightOfCell)
            
            contentHeight = attributes.frame.maxY

            
            cache[cellIndexPath] = attributes
            
            
        }
        
    }
    
    private func configure(attributes: CWMessageLayoutAttributes) {

        guard let collectionView = collectionView,
            let message = delegate?.collectionView(collectionView, itemAt: attributes.indexPath) else {
            return
        }
        
        attributes.avaterFrame = avatarFrame(with: message)
        
        setupUsernameFrame(with: attributes, message: message)
        setupContainerFrame(with: attributes, message: message)
        setupStateFrame(with: attributes, message: message)
    }
    
    // 头像
    func avatarFrame(with message: CWMessageModel) -> CGRect {
        let size: CGSize = setting.kAvaterSize
        let origin: CGPoint
        if message.isSend {
            origin = CGPoint(x: collectionViewWidth - setting.kMessageToLeftPadding - size.width,
                             y: setting.kMessageToTopPadding)
        } else {
            origin = CGPoint(x: setting.kMessageToLeftPadding, y: setting.kMessageToTopPadding)
        }
        return CGRect(origin: origin, size: size)
    }
    
    // 昵称(如果有昵称，则昵称和头像y一样)
    func setupUsernameFrame(with attributes: CWMessageLayoutAttributes, message: CWMessageModel) {
        
        var size: CGSize = setting.kUsernameSize
        let origin: CGPoint
        if message.showUsername == false {
            size = CGSize.zero
        }
        
        if message.isSend {
            origin = CGPoint(x: attributes.avaterFrame.minX - setting.kUsernameLeftPadding - size.width,
                             y: attributes.avaterFrame.minY)
        } else {
            origin = CGPoint(x: attributes.avaterFrame.maxX + setting.kUsernameLeftPadding,
                             y: attributes.avaterFrame.minY)
        }
        attributes.usernameFrame = CGRect(origin: origin, size: size)
    }
    
    func setupContainerFrame(with attributes: CWMessageLayoutAttributes, message: CWMessageModel) {
        
        // 如果是文字
        var contentSize: CGSize = CGSize.zero
        // 根据消息不同类型 计算
        if message.messageType == .text {
            
            let content = (message.messageBody as! CWTextMessageBody).text
            let size = CGSize(width: kChatTextMaxWidth, height: CGFloat.greatestFiniteMagnitude)
            var edge: UIEdgeInsets
            if message.isSend {
                edge = ChatCellUI.right_edge_insets
            } else {
                edge = ChatCellUI.left_edge_insets
            }
            
            let modifier = CWTextLinePositionModifier(font: setting.contentTextFont)
            // YYTextContainer
            let textContainer = YYTextContainer(size: size)
            textContainer.linePositionModifier = modifier
            textContainer.maximumNumberOfRows = 0
            
            let textAttri = CWChatTextParser.parseText(content)!
            let textLayout = YYTextLayout(container: textContainer, text: textAttri)!
            
            contentSize = CGSize(width: textLayout.textBoundingSize.width+edge.left+edge.right,
                                 height: textLayout.textBoundingSize.height+edge.top+edge.bottom)
            message.textLayout = textLayout
        }
        
        let origin: CGPoint
        if message.isSend {
            origin = CGPoint(x: attributes.avaterFrame.minX - setting.kUsernameLeftPadding - contentSize.width,
                             y: attributes.usernameFrame.minY)
        } else {
            origin = CGPoint(x: attributes.avaterFrame.maxX + setting.kUsernameLeftPadding,
                             y: attributes.usernameFrame.minY)
        }
        attributes.messageContainerFrame = CGRect(origin: origin, size: contentSize)
    }
    
    func setupStateFrame(with attributes: CWMessageLayoutAttributes, message: CWMessageModel) {
        let containerFrame = attributes.messageContainerFrame
        let origin: CGPoint
        if message.isSend {
            origin = CGPoint(x: containerFrame.minX - 2 - setting.errorSize.width,
                            y: containerFrame.midY - 5)
        } else {
            origin = CGPoint(x: containerFrame.minX + 2 + setting.errorSize.width,
                            y: containerFrame.midY - 5)
        }
        attributes.errorFrame = CGRect(origin: origin, size: setting.errorSize)
        attributes.activityFrame = CGRect(origin: origin, size: setting.errorSize)
    }
        
    
    // 所有cell 布局
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath]
    }
    
    //3
    override public func layoutAttributesForElements(
        in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        visibleLayoutAttributes.removeAll(keepingCapacity: true)
        for (_, attributes) in cache where attributes.frame.intersects(rect) {
            visibleLayoutAttributes.append(attributes)
        }
        return visibleLayoutAttributes
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
    
        if context.invalidateDataSourceCounts {
            needLayout = true
        }
    }
}
