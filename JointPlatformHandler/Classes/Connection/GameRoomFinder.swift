//
//  GameRoomFinder.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/6.
//

import Foundation


protocol GameRoomFinder:NSObjectProtocol{
    
    func initialize()
    
    func startListening() -> Bool
    
    func stopListening()
    
    func setDelegate(_ target:GameRoomFinderDelegate)
    
}


protocol GameRoomFinderDelegate:NSObjectProtocol{
    
    func gameRoomFinder(_ finder:GameRoomFinder, didFindWith list:[GameRoom])
    
    func gameRoomFinderOnSearching()
    
    func gameRoomFinderOnErrorTerminate(_ error:Error)
    
}





