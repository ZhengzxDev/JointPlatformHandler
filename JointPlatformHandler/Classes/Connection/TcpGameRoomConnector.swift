//
//  TcpGameRoomConnector.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/6.
//

import Foundation
import CocoaAsyncSocket
import SwiftyJSON

class TcpGameRoomConnector:NSObject,GameRoomConnector{
    
    var isConnected: Bool{
        get{
            return clientSocket.isConnected
        }
    }
    
    var tcpTimeout:TimeInterval = -1
    
    var tcpConnectionTimeout:TimeInterval = -1
    
    var tcpTag:Int = 121
    
    private var clientSocket:GCDAsyncSocket!
    
    private var hoster:GameRoomHoster!
    
    private var nextDataLength:Int = -1
    
    private var nextDataIdentifier:String = ""
    
    private var delayCheckTimer:Timer?
    
    private var delayCheckInterval:TimeInterval = 1
    
    private var accpetRawData:Bool = false
    
    private var lastSendTimeStampString:String = ""
    
    private var isLastDelayPacketEchoReceived:Bool = false
    
    /// successive delay packet lost count
    private var delayPacketLost:Int = 0
    
    private var tcpPort:UInt16{
        get{
            return LANGammTcpPort[0]
        }
    }
    
    func initialize() {
        clientSocket?.disconnect()
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: .main)
        nextDataLength = -1
        nextDataIdentifier = ""
        accpetRawData = false
        lastSendTimeStampString = ""
        isLastDelayPacketEchoReceived = false
        delayPacketLost = 0
        delayCheckTimer?.invalidate()
    }
    
    func syncToServer(type: GameSync.Symbol, dictionary: [String : Any]?) -> Bool {
        guard isConnected else { return false }
        let sendDataDictionary:[String:Any] = [
            "type":type.rawValue,
            "msg":dictionary ?? []
        ]
        tcpWrite(data: JSON(sendDataDictionary).description.data(using: .utf8), socket: clientSocket)
        return true
    }
    
    func disconnect(){
        guard isConnected else { return }
        delayCheckTimer?.invalidate()
        clientSocket.disconnect()
    }
    
    func connectTo(room: GameRoom) -> Bool {
        do{
            self.hoster = room.hoster
            try clientSocket.connect(toHost: hoster.ip_v4_address!, onPort: tcpPort,withTimeout:tcpTimeout)
        }
        catch let error{
            debugLog(error.localizedDescription)
            return false
        }
        return true
    }
    
    private func tcpWrite(data:Data?,socket:GCDAsyncSocket){
        //to avoid tcp packet stick together, send two part for each data,first is header describe the length of
        //data which is prepared to send,second is the data.
        guard data != nil else { return }
        let dataLength = data!.count
        let headerDic:[String:Any] = ["len":dataLength]
        let headerJsonString = JSON(headerDic).description
        guard var sendData = headerJsonString.data(using: .utf8) else {
            debugLog("[Tcp Client] tcp write with error : data is not sendable.")
            return
        }
        sendData.append(GCDAsyncSocket.crlfData())
        sendData.append(data!)
        socket.write(sendData, withTimeout: tcpTimeout, tag: tcpTag)
    }
    
    @objc func doDelayCheckProcedure(){
        let currentStamp = Date().milliStamp
        if !isLastDelayPacketEchoReceived && lastSendTimeStampString != "" {
            //if it's time to send next delay check packet but last packet echo is still not arrive
            delayPacketLost += 1
            //notify observer with 999ms
            NotificationCenter.customPost(name: .DelayPacketUpdate, object: nil, userInfo: [
                .Value:round(Date().timeIntervalSince1970*1000)+1500
            ])
            if delayPacketLost >= 3 {
                //means server is unavailable.
                debugLog("[Tcp Client] disconnect due to delay packet timeout")
                self.delayPacketLost = 0
                self.clientSocket.disconnect()
                self.delayCheckTimer?.invalidate()
                lastSendTimeStampString = ""
                isLastDelayPacketEchoReceived = false
                return
            }
        }
        else{
            //if receive the last delay check packet
            delayPacketLost = 0
            
        }
        let _ = self.syncToServer(type: .delayCheck, dictionary: [
            "stamp":currentStamp
        ])
        lastSendTimeStampString = currentStamp
        isLastDelayPacketEchoReceived = false
    }
    
}

extension TcpGameRoomConnector:GCDAsyncSocketDelegate{
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        //prepare to read next header
        clientSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: tcpTimeout, tag: tcpTag)
        //tell server local player info
        let wrappedDic:[String:Any] = [
            "type":GameSync.Symbol.verify.rawValue,
            "msg":[
                "gamer":GameUser.this.propertyDictionary
            ]
        ]
        let JsonString = JSON(wrappedDic).description
        tcpWrite(data: JsonString.data(using: .utf8), socket: clientSocket)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        debugLog("[Tcp Client] disconnect to host socket")
        if let error = err as NSError?{
            NotificationCenter.customPost(name: .HosterDisconnected, object: nil, userInfo: [
                .Hoster:hoster!,
                .Error:error
            ])
        }
        else{
            NotificationCenter.customPost(name: .HosterDisconnected, object: nil, userInfo: [
                .Hoster:hoster!,
            ])
        }
        self.delayCheckTimer?.invalidate()
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        
        if accpetRawData {
            
            debugLog("[Tcp Client] receive data bit in length (\(data.count) bytes)")
            
            NotificationCenter.customPost(name: .HosterEcho, object: nil, userInfo: [
                .Data:data,
                .Identifier:nextDataIdentifier,
                .DataType:JtSyncDataType.ImageData
            ])
            //prepare to read next header
            accpetRawData = false
            nextDataLength = -1
            nextDataIdentifier = ""
            sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: tcpTimeout, tag: tcpTag)
            return
        }
        
        
        
        let Json = JSON(data)
        
        //header receive
        
        if nextDataLength < 0 {
            guard let length = Json["len"].int else {
                debugLog("[Tcp Client] sock read dirty heder packet")
                return
            }
            //need accpet raw data?
            if Json["type"].intValue == 2{
                accpetRawData = true
            }
            else{
                accpetRawData = false
            }
            nextDataIdentifier = Json["id"].stringValue
            nextDataLength = length
            sock.readData(toLength: UInt(nextDataLength), withTimeout: tcpTimeout, tag: tcpTag)
            return
        }
        //body data receive
        
        guard UInt(data.count) == nextDataLength else{
            debugLog("[Tcp Client] sock read dirty body packet")
            //drop this dirty body , read next header
            nextDataLength = -1
            sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: tcpTimeout, tag: tcpTag)
            return
        }
        
        if Json["type"].stringValue == GameSync.Symbol.delayCheckEcho.rawValue{
            debugLog("[Tcp Client] received json from server , with type = \(Json["type"].stringValue)",belong: .Gossip)
        }
        else{
            debugLog("[Tcp Client] received json from server , with type = \(Json["type"].stringValue)")
        }
        //print(Json.description)
        
        if Json["type"].stringValue == GameSync.Symbol.verifyProved.rawValue{
            if let newRoomModel = GameRoom.analyse(Json["msg"]["room"]) {
                NotificationCenter.customPost(name: .HosterConnected, object: nil, userInfo: [
                    .Value:newRoomModel
                ])
                //start delay check procedure
                delayCheckTimer = Timer.scheduledTimer(timeInterval: delayCheckInterval, target: self, selector: #selector(doDelayCheckProcedure), userInfo: nil, repeats: true)
                delayCheckTimer?.fire()
            }
            else{
                let error = NSError(domain: "error on analyze room data", code: 1, userInfo: nil)
                NotificationCenter.customPost(name: .ConnectFailed, object: nil, userInfo: [
                    .Error:error
                ])
            }
        }
        else if Json["type"].stringValue == GameSync.Symbol.delayCheckEcho.rawValue{
            guard let sendOutStampString = Json["msg"]["stamp"].string else { return }
            if sendOutStampString == lastSendTimeStampString {
                isLastDelayPacketEchoReceived = true
                guard let sendOutStamp = TimeInterval(sendOutStampString) else { return }
                let currentStamp:Double = round(Date().timeIntervalSince1970*1000)
                NotificationCenter.customPost(name: .DelayPacketUpdate, object: nil, userInfo: [
                    .Value:(currentStamp-sendOutStamp)/2
                ])
            }
        }
        else{
            NotificationCenter.customPost(name: .HosterEcho, object: nil, userInfo: [
                .Data:data,
                .DataType:JtSyncDataType.JsonData
            ])
        }
        
        //prepare to read next header
        nextDataLength = -1
        sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: tcpTimeout, tag: tcpTag)

    }
}
