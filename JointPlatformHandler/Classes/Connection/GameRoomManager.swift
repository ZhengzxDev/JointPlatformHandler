//
//  GameRoomManager.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/6.
//

import Foundation
import SwiftyJSON


class GameRoomManager:NSObject{
    
    var finder:GameRoomFinder?
    
    var launcher:GameLauncher?
    
    var currentRoom:GameRoom?
    
    private var connectTargetRoom:GameRoom?
    
    private var connector:GameRoomConnector?
    
    private var stickConfig:[String:Any] = [:]
    
    private var isWaitToEnterRoom:Bool = false
    
    private var enterRoomTimer:Timer?
    
    private let enterRoomTimeout:TimeInterval = 5
    
    func initialize(connector:GameRoomConnector){
        
        NotificationCenter.customAddObserver(self, selector: #selector(onServerConnected(_:)), name: .HosterConnected, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onServerDisconnected(_:)), name: .HosterDisconnected, object: nil)
        NotificationCenter.customAddObserver(self, selector: #selector(onServerEcho(_:)), name: .HosterEcho, object: nil)
        
        self.connector = connector
        self.launcher = GameLauncher(connector: connector)
        self.launcher?.delegate = self
    }
    
    func enterRoom(_ room:GameRoom) -> Bool{
        connectTargetRoom = room
        isWaitToEnterRoom = true
        self.enterRoomTimer = Timer.scheduledTimer(timeInterval: enterRoomTimeout, target: self, selector: #selector(onEnterRoomTimout), userInfo: nil, repeats: false)
        return connector?.connectTo(room: room) ?? false
    }
    
    func exitCurrentRoom(){
        guard connector?.isConnected ?? false else { return }
        isWaitToEnterRoom = false
        self.enterRoomTimer?.invalidate()
        connector?.disconnect()
    }
    
    func setReady(_ value:Bool) -> Bool{
        guard connector?.isConnected ?? false else { return false }
        return connector?.syncToServer(type: value ? .userReady : .userNotReady, dictionary: nil) ?? false
    }
    
    
    @objc
    private func onEnterRoomTimout(){
        guard isWaitToEnterRoom else { return }
        NotificationCenter.customPost(name: .EnterRoomFailed, object: nil, userInfo: nil)
        isWaitToEnterRoom = false
    }
}

extension GameRoomManager{
    
    @objc
    private func onServerConnected(_ notification:Notification){
        guard let room = notification.userInfo?[JtUserInfo.Key.Value] as? GameRoom else { return }
        guard self.currentRoom == nil else { return }
        self.currentRoom = room
        isWaitToEnterRoom = false
        NotificationCenter.customPost(name: .DidEnterRoom, object: nil, userInfo: [
            .Value:room
        ])
    }
    
    @objc
    private func onServerDisconnected(_ notification:Notification){
        self.currentRoom = nil
        NotificationCenter.customPost(name: .DidLeaveRoom, object: nil, userInfo: nil)
    }
    
    @objc
    private func onServerEcho(_ notification:Notification){
        guard let data = notification.userInfo?[JtUserInfo.Key.Data] as? Data else { return }
        let Json = JSON(data)
        let typeStr = Json["type"].stringValue
        if typeStr == GameSync.Symbol.userEnter.rawValue{
            if let player = GameRoomPlayer.analyse(Json["msg"]["player"]){
                NotificationCenter.customPost(name: .PlayerEnter, object: nil, userInfo: [
                    .Value:player
                ])
            }
        }
        else if typeStr == GameSync.Symbol.userLeave.rawValue{
            if let player = GameRoomPlayer.analyse(Json["msg"]["player"]){
                NotificationCenter.customPost(name: .PlayerLeave, object: nil, userInfo: [
                    .Value:player
                ])
            }
            
        }
        else if typeStr == GameSync.Symbol.userReady.rawValue{
            if let playerId = Json["msg"]["playerId"].string{
                NotificationCenter.customPost(name: .PlayerReady, object: nil, userInfo: [
                    .Value:playerId
                ])
            }
            
        }
        else if typeStr == GameSync.Symbol.userNotReady.rawValue{
            if let playerId = Json["msg"]["playerId"].string{
                NotificationCenter.customPost(name: .PlayerNotReady, object: nil, userInfo: [
                    .Value:playerId
                ])
            }
        }
        else if typeStr == GameSync.Symbol.gamePrepare.rawValue{
            
            guard let version = Json["msg"]["assets"]["version"].string else {
                debugLog("[GameRoomManager] game prepare without version value")
                return
            }
            
            let forceRefresh = Json["msg"]["assets"]["forceRefresh"].boolValue
            
            guard let gameProfile = self.currentRoom?.game else {
                debugLog("[GameRoomManager] prepare failed because game profile is not define")
                return
            }
            
            guard Json["msg"]["stickConfig"] != JSON.null else {
                debugLog("[GameRoomManager] prepare failed because game stick config is not define")
                return
            }
            self.stickConfig = Json["msg"]["stickConfig"].dictionaryObject ?? [:]
            
            NotificationCenter.customPost(name: .GamePrepare, object: nil, userInfo: nil)
            
            //start launcher to prepare assets
            launcher?.startProcedure(for: gameProfile, assetsVersion: version, forceRefresh: forceRefresh)
            
        }

        
    }
}


extension GameRoomManager:GameLauncherDelegate{
    
    func gameLauncherOnError(_ errorCode: Int) {
        debugLog("[GameRoomManager] game launch failed with error code : \(errorCode)")
        if errorCode != 5 {
            //sync to server that failed to load
            if !(connector?.syncToServer(type: .gamePrepareFailed, dictionary: nil) ?? false){
                //sync to server failed
                debugLog("[GameRoomManager] game launch failed , sync to server failed")
            }
        }
        
        NotificationCenter.customPost(name: .GamePrepareFailed, object: nil, userInfo: [
            .Error:NSError(domain: "", code: errorCode, userInfo: nil)
        ])
    }
    
    func gameLauncherAssetsPrepared() {

        NotificationCenter.customPost(name: .GameAssetsPrepareDone, object: nil, userInfo: [
            .Value:stickConfig,
        ])
    }
    
}


