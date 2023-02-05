//
//  GameStickManager.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/6.
//

import Foundation


protocol GameStickManagerDelegate:NSObjectProtocol{
    
    func stickManager(_ manager:GameStickManager,didReceiveCommand data:Data)
    
}

///负责游戏时的IO
class GameStickManager:NSObject{
    
    public weak var delegate:GameStickManagerDelegate?
    
    private var connector:GameRoomConnector?
    
    private let syncTimesPerSecond:Int = 5
    
    private var regularSendQueue:[[String:Any]] = []
    
    private var regularSendTimer:Timer?
    
    private var _isRunning:Bool = false
    
    //lock the send queue while sync
    private var sendMutateLock:Bool = false
    private var yieldSendQueue:[[String:Any]] = []
    
    func initialize(connector:GameRoomConnector){
        self.connector = connector
    }
    
    
    func run(){
        NotificationCenter.customAddObserver(self, selector: #selector(onHosterEcho(_:)), name: .HosterEcho, object: nil)
        regularSendTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1/syncTimesPerSecond), target: self, selector: #selector(doRegularSyncProcedure), userInfo: nil, repeats: true)
        regularSendQueue.removeAll()
        _isRunning = true
    }
    
    func terminate(){
        NotificationCenter.default.removeObserver(self)
        regularSendTimer?.invalidate()
        _isRunning = false
        regularSendQueue.removeAll()
    }
    
    func regularSync(dictionary:[String:Any]) -> Bool {
        guard _isRunning else { return false }
        if !sendMutateLock{
            self.regularSendQueue.append(dictionary)
        }
        else{
            self.yieldSendQueue.append(dictionary)
        }
        return true
    }
    
    func instantSync(dictionary:[String:Any]) -> Bool{
        guard self.connector?.isConnected ?? false else { return false }
        return self.connector?.syncToServer(type: .playerStateUpdate, dictionary: dictionary) ?? false
    }
    
    func syncInitLayout() -> Bool{
        return self.connector?.syncToServer(type: .initLayout, dictionary: nil) ?? false
    }
    
    func syncPrepareDone() -> Bool{
        return self.connector?.syncToServer(type: .gamePrepareDone, dictionary: nil) ?? false
    }
    
    @objc func doRegularSyncProcedure(){
        guard self.connector?.isConnected ?? false else {
            terminate()
            debugLog("[GameStickManager] send Timer terminated due to connection is closed")
            return
        }
        guard !self.regularSendQueue.isEmpty else { return }
        sendMutateLock = true
        while(!self.regularSendQueue.isEmpty){
            let sendDictionary = self.regularSendQueue.removeFirst()
            let _ = self.connector?.syncToServer(type: .playerStateUpdate, dictionary: sendDictionary)
        }
        self.regularSendQueue = self.yieldSendQueue
        self.sendMutateLock = false
        self.yieldSendQueue = []
    }
}

extension GameStickManager{
    
    @objc private func onHosterEcho(_ notification:Notification){
        guard let data = notification.userInfo?[JtUserInfo.Key.Data] as? Data else { return }
        delegate?.stickManager(self, didReceiveCommand: data)
        
    }
}
