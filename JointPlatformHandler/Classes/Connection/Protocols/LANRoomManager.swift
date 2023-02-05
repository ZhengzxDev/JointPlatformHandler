//
//  LANRoomManager.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/4.
//

import UIKit





protocol LANRoomManagerDelegate:NSObjectProtocol{
    
    func lanRoomManagerOnUserEnter(_ enterPlayer:GameRoomPlayer)
    
    func lanRoomManagerOnUserExit(_ exitPlayer:GameRoomPlayer)
    
    func lanRoomManagerOnUserReady(_ readyPlayerId:String)
    
    func lanRoomManagerOnUserNotReady(_ notReadyPlayerId:String)
    
    func lanRoomManagerOnGameStart()
    
    func lanRoomManagerOnGamePrepare(joyStickConfigs:[String:Any])
    
    func lanRoomManagerOnAssetsReceive(_ assets:[String:Any])
    
    ///房间非正常销毁调用
    func lanRoomManagerOnRoomDestroy(_ error:NSError)
    
    func lanRoomDidEnterRoom(_ room:GameRoom)
    
    func lanRoomEnterFailed(with error:NSError)
    ///主动断开连接调用
    func lanRoomDidExitRoom()
    
}

///房间信息订阅对象，负责进入，退出房间，以及房间信息同步
protocol LANRoomManager:NSObjectProtocol{
    
    var connector:LANRoomClient { get }
    
    var isInRoom:Bool { get }
    
    func setDelegate(_ target:LANRoomManagerDelegate)
    
    func initialize() -> Bool
    
    func leaveCurrentRoom() -> Bool
    
    func joinRoom(_ room:GameRoom) -> Bool
    
    func setReady() -> Bool
    
    func setNotReady() -> Bool
    
}
