//
//  UdpGameRoomFinder.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/6.
//

import Foundation
import SwiftyJSON
import CocoaAsyncSocket

class UdpGameRoomFinder:NSObject,GameRoomFinder{
    
    private weak var delegate:GameRoomFinderDelegate?
    
    private var udpClient:GCDAsyncUdpSocket!
    
    private var _isListening:Bool = false
    
    private var udpTimer:Timer!
    
    private var listeningInterval:TimeInterval = 5
    
    private var listeningTime:TimeInterval = 2
    
    private var udpPort:UInt16 = LANGamePort
    
    private var roomList:[String:GameRoom] = [:]
    
    func initialize() {
        udpClient = GCDAsyncUdpSocket(delegate: self, delegateQueue: .main)
        udpClient.setIPv4Enabled(true)
        udpClient.setIPv6Enabled(false)
    }
    
    func startListening() -> Bool {
        do{
            
            udpClient.send("get the privilige".data(using: .utf8)!, toHost: "255.255.255.255", port: UInt16(2333), withTimeout: 10, tag: 10)
            udpClient.close()
            try udpClient.bind(toPort: udpPort)
            if udpTimer != nil{
                udpTimer.invalidate()
            }
            
            udpTimer = Timer.scheduledTimer(timeInterval: listeningInterval, target: self, selector: #selector(doListeningProcedure), userInfo: nil, repeats: true)
            udpTimer.fire()
            //_isListening = true
            
            return true
        }
        catch let error{
            print(error.localizedDescription)
            return false
        }
    }
    
    func stopListening() {
        udpClient.close()
        udpTimer.invalidate()
        _isListening = false
    }
    
    func setDelegate(_ target: GameRoomFinderDelegate) {
        self.delegate = target
    }
    
    
    @objc private func doListeningProcedure(){
        roomList = [:]
        do{
            if !_isListening{
                try udpClient.beginReceiving()
                _isListening = true
            }
            self.delegate?.gameRoomFinderOnSearching()
        }
        catch let error{
            stopListening()
            delegate?.gameRoomFinderOnErrorTerminate(error)
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+listeningTime) {
            [weak self] in
            guard let strongSelf = self else { return }
            //self?.udpClient.close()
            var rooms:[GameRoom] = []
            for r in strongSelf.roomList.values{
                rooms.append(r)
            }
            self?.delegate?.gameRoomFinder(strongSelf, didFindWith: rooms)
        }
    }
    
}

extension UdpGameRoomFinder:GCDAsyncUdpSocketDelegate{
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        guard let roomModel = GameRoom.analyse(JSON(data)) else { return }
        roomList[roomModel.hoster.ip_v4_address!] = roomModel
    }
}
