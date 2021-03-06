//
//  CWLoginManager.swift
//  CWWeChat
//
//  Created by wei chen on 2017/9/4.
//  Copyright © 2017年 cwwise. All rights reserved.
//

import Foundation

public typealias CWLoginHandler = (String?, CWChatError?) -> Void

public enum CWLoginStep: Int {
    case linking
    case linkOk
    case logining
    case loginfailed
}

public protocol CWLoginManagerDelegate: NSObjectProtocol {
    func onLogin(setp: CWLoginStep)
}

/// 登陆注册模块
public protocol CWLoginManager: NSObjectProtocol {
    
    var isLogined: Bool { get }
    
    func login(username: String, password: String, completion: CWLoginHandler?)
    
    func register(username: String, password: String, completion: CWLoginHandler?)

    func currentAccount() -> String
    
    func logout()
}
