//
//  Client.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/6.
//

import Foundation


class Client:NSObject{
    
    enum ConnectMode{
        case Lan
        case Bluetooth
    }
    
    static let instance:Client = {
        let client = Client()
        return client
    }()
    
    var connectMode:ConnectMode{
        get{
            return _connectMode
        }
    }
    
    public var roomManager:GameRoomManager?
    
    public var stickManager:GameStickManager?
    
    private var _connectMode:ConnectMode = .Lan
    
    private var _connector:GameRoomConnector?
    
    private override init(){
        super.init()
    }
    
    func initComponents(){
        if roomManager == nil{
            roomManager = GameRoomManager()
        }
        if stickManager == nil{
            stickManager = GameStickManager()
        }
        switch _connectMode {
        case .Lan:
            _connector = TcpGameRoomConnector()
            roomManager?.finder = UdpGameRoomFinder()
        case .Bluetooth:
            fatalError()
            break
        }
        _connector?.initialize()
        roomManager?.initialize(connector: _connector!)
        roomManager?.finder?.initialize()
        stickManager?.initialize(connector: _connector!)
    }
    
    public func setConnectMode(_ mode:ConnectMode){
        self._connectMode = mode
    }
    
    
}
