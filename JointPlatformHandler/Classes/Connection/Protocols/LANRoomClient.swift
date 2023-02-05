//
//  LANRoomClient.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/4.
//

import UIKit




///TCP连接底层对象,完成包括自动延迟检测的任务
protocol LANRoomClient:NSObjectProtocol{
    
    var isConnected:Bool{ get }
    
    var hoster:GameRoomHoster?{ get }
    
    func initialize()
    
    func syncToServer(type:GameSync.Symbol,dictionary:[String:Any]?) -> Bool
    
    func disconnect() -> Bool
    
    func connectTo(room:GameRoom) -> Bool
    
}
