//
//  GameConnector.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/6.
//

import Foundation

///同步标志位，用来判断同步的消息的类型
struct GameSync{
    enum Symbol:String{
        case gameStart = "gameStart"
        case gameTerminate = "gameTerminate"
        case gamePrepare = "gamePrepare"
        case gameAssets = "gameAssets"
        case gameAssetsSyncPrepare = "gameAssetsSyncPrepare"
        case gameAssetsRequest = "gameAssetsRequest"
        case assetsVersion = "assetsVersion"
        case initLayout = "initLayout"
        case gamePrepareDone = "gamePrepareDone"
        case gamePrepareFailed = "gamePrepareFailed"
        case roomDestroy = "roomDestroy"
        case userEnter = "userEnter"
        case userLeave = "userLeave"
        case userReady = "userReady"
        case userNotReady = "userNotReady"
        case normal = "normal"
        case playerStateUpdate = "playerStateUpdate"
        case joyStickUIUpdate = "joyStickUIUpdate"
        ///完成TCP连接后的身份信息交换
        case verify = "verify"
        case delayCheck = "delayCheck"
        case delayCheckEcho = "delayCheckEcho"
        ///身份信息交换完成
        case verifyProved = "verifyProved"
        case unknown = "unknown"
    }
}

protocol GameRoomConnector:NSObjectProtocol{
    
    var isConnected:Bool{ get }
    
    func initialize()
    
    func syncToServer(type:GameSync.Symbol,dictionary:[String:Any]?) -> Bool
    
    func disconnect()
    
    func connectTo(room:GameRoom) -> Bool
    
}



