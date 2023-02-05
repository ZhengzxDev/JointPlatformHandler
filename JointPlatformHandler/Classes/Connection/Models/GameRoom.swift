//
//  LANRoom.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/4.
//

import UIKit
import SwiftyJSON

///局域网房间
struct GameRoom{
    
    ///16位唯一房间编号
    var roomId:String!
    
    ///房主
    var hoster:GameRoomHoster!
    
    ///游戏信息
    var game:GameProfile!
    
    ///房间容量
    var capacity:Int{
        get{
            return game.maxPlayerCount
        }
    }
    
    ///玩家信息
    var players:[GameRoomPlayer] = []
    
    ///当前玩家数量
    var playerCount:Int = 0
    
}


extension GameRoom{
    
    ///用于广播房间信息的字符串
    var broadcastString:String{
        get{
            return ""
        }
    }
    
    ///分析JSON，返回模型
    static func analyse(_ Json:JSON) -> GameRoom?{
        var room = GameRoom()
        room.hoster = GameRoomHoster.analyse(Json["hoster"])
        room.game = GameProfile.analyse(Json["game"])
        room.playerCount = Json["playerCount"].intValue
        room.roomId = Json["roomId"].stringValue
        var playersArray:[GameRoomPlayer] = []
        let playersJsonArray = Json["players"].arrayValue
        
        for playerJson in playersJsonArray{
            guard let player = GameRoomPlayer.analyse(playerJson) else { continue }
            playersArray.append(player)
        }
        room.players = playersArray
        
        return room
    }
    
}

