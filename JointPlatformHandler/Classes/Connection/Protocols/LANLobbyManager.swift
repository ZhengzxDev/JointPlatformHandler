//
//  LANLobbyManager.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/4.
//

import UIKit


protocol LANLobbyManagerDelegate:NSObjectProtocol{
    
    func lanLobbyManagerOnErrorOccurListening(_ error:NSError)
    
    func lanLobbyManagerOnListening()
    
    func lanLobbyManagerOnResting()
    
    func lanLobbyManagerOnRoomListUpdate(_ roomList:[GameRoom])
    
}

///UDP对象，负责大厅信息检索
protocol LANLobbyManager:NSObjectProtocol{
    
    var isListening:Bool{ get }
    
    func initialize() -> Bool
    
    func startListening() -> Bool
    
    func endListening() -> Bool
    
    func setDelegate(_ target:LANLobbyManagerDelegate)
    
}
