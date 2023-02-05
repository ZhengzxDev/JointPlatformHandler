//
//  JtNotification.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/9.
//

import UIKit

import UIKit

/**
 扩展系统的Notification.Name的枚举类型
 */
enum JtNotification:String{
    
    // MARK: - LANConnector
    
    ///主机连接
    case HosterConnected = "JtHosterConnected"
    
    ///主机断开连接
    case HosterDisconnected = "JtHosterDisconnected"
    
    ///收到来自主机的新信息
    case HosterEcho = "JtHosterEcho"
    
    ///连接主机失败
    case ConnectFailed = "JtConnectFailed"
    
    
    // MARK: - LANRoomManager
    
    ///用户进入房间
    case PlayerEnter = "JtUserEnter"
    
    ///用户离开房间
    case PlayerLeave = "JtUserLeave"
    
    ///用户准备
    case PlayerReady = "JtUserReady"
    
    ///用户取消准备
    case PlayerNotReady = "JtUserNotReady"
    
    ///游戏开始
    case GameStart = "JtGameStart"
    
    ///游戏开始前的数据准备阶段
    case GamePrepare = "JtGamePrepare"
    
    ///数据准备完成
    case GameAssetsPrepareDone = "JtGameAssetsPrepareDone"
    
    ///数据准备失败
    case GamePrepareFailed = "JtGamePrepareFailed"
    
    ///进入房间
    case DidEnterRoom = "JtDidEnterRoom"
    
    ///离开房间
    case DidLeaveRoom = "JtDidLeaveRoom"
    
    ///进入房间失败
    case EnterRoomFailed = "JtEnterRoomFailed"
    
    ///房间销毁
    case RoomDestory = "JtRoomDestory"
    
    ///延迟检测数据更新
    case DelayPacketUpdate = "JtDelayPacketUpdate"
    
    ///网络连接变化
    case NetworkStateChanged = "JtNetworkStateChanged"
    

    var stringValue: String {
        return "JtNotification" + rawValue
    }
    
    ///获取notification.name
    var notificationName: NSNotification.Name {
        return NSNotification.Name(stringValue)
    }
    
}

/**
 扩展的UserInfo,支持使用自己的Key拿参数
 */
struct JtUserInfo{
    
    ///自定义UserInfo的预设Key
    enum Key:String{
        
        ///主机模型
        case Hoster = "JtUserInfoKeyGammer"
        
        ///错误信息
        case Error = "JtUserInfoKeyError"
        
        ///数据
        case Data = "JtUserInfoKeyData"
        
        ///头部携带的描述信息
        case Identifier = "JtUserInfoKeyIdentifier"
        
        ///通用字段,含义通常可以根据Key推断
        case Value = "JtUserInfoKeyValue"
        
        ///Data字段的数据的类型说明
        case DataType = "JtUserInfoKeyDataType"
    }
    
}


enum JtSyncDataType{
    
    case JsonData
    case ImageData
    case Unknown
}
