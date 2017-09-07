//
//  CWMessageContentView.swift
//  CWWeChat
//
//  Created by wei chen on 2017/7/16.
//  Copyright © 2017年 cwcoder. All rights reserved.
//

import UIKit

class CWMessageContentView: UIView {
        
    var bubbleImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.clipsToBounds = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
