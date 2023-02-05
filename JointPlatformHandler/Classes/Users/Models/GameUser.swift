//
//  GameUser.swift
//  JointPlatform
//
//  Created by luckyXionzz on 2022/1/3.
//

import UIKit
import SwiftyJSON

///游戏用户
class GameUser:NSObject,NSCoding{

    
    public static var this:GameUser = {
        var localUser = GameUser()
        localUser.nickName = "Jake"
        localUser.avatarId = 0
        localUser.uid = String.rand(length: 16)
        // 反序列化
        let def = UserDefaults.standard
        if let data = def.object(forKey: "JointUserData") {
            if let localUserData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as? GameUser{
                //print(tData.nickName)
                //debugPrint(tData)
                localUser.uid = localUserData.uid
                localUser.nickName = localUserData.nickName
                localUser.avatarId = localUserData.avatarId
                debugLog("[GameUser] get userInfo by local")
            }

        }

        
        return localUser
    }()
    
    ///16位随机编号
    var uid:String!
    
    ///昵称
    var nickName:String!
    
    ///头像
    var avatarId:Int!
    
    var propertyDictionary:[String:Any]{
        get{
            return [
                "uid":uid!,
                "nickname":nickName!,
                "avatarId":avatarId!
            ]
        }
    }
    
    
    
    override init(){
        super.init()
        self.uid = ""
        self.nickName = ""
        self.avatarId = 0
    }
    
    func save(){
        // 序列化
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        // 存储到本地文件
        let def = UserDefaults.standard
        def.set(data, forKey: "JointUserData")
        def.synchronize()
        debugLog("[GameUser] data saved")
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(nickName,forKey: "userName")
        coder.encode(avatarId,forKey: "userAvatarId")
    }
    
    
    required init?(coder: NSCoder) {
        nickName = coder.decodeObject(forKey: "userName") as? String
        avatarId = coder.decodeObject(forKey: "userAvatarId") as? Int
        uid = String.rand(length: 16)
        
    }
    
    
    
    ///分析JSON，返回模型
    static func analyse(_ Json:JSON) -> GameUser?{
        let gamer = GameUser()
        gamer.nickName = Json["nickname"].stringValue
        gamer.avatarId = Json["avatarId"].intValue
        gamer.uid = Json["uid"].stringValue
        return gamer
    }
}
