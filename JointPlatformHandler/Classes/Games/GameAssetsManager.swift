//
//  GameAssetsManager.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/6.
//

import Foundation
import SwiftyJSON

///游戏资源的管理
class GameAssetsManager:NSObject{
    
    struct CachedGameAssetsEntity{
        var profile:GameProfile
        var version:String
        var itemCount:Int
        var createDate:Date
        var iconData:Data?
    }
    
    static let shared:GameAssetsManager = {
        let manager = GameAssetsManager()
        return manager
    }()
    
    private var versionListFileName = "assetVersionList"

    
    private override init() {
        super.init()
    }
    
    //比对版本,清单记录了对应游戏的本地资源版本
    func versionVerify(for game:GameProfile,newVersion:String,handler:((Bool)->Void)?){
        guard let listJsonDic = readAssetsVersionList() else {
            handler?(false)
            return
        }
        
        guard let gameInfoDic = listJsonDic[game.id] as? [String:Any] else {
            handler?(false)
            return
        }
        
        guard let savedVersion = gameInfoDic["version"] as? String else {
            handler?(false)
            return
        }
        handler?(savedVersion == newVersion)
    }
    
    
    func saveAssets(for game:GameProfile,version:String,assets:[String:Data]) -> Bool{
        guard var listJsonDic = readAssetsVersionList() else {
            debugLog("[GameAssetsManager] list json dic is not found")
            return false
        }
        //convert save path
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let gameAssetsUrl = documentUrl.appendingPathComponent(game.id, isDirectory: true)
        var savePaths:[String:URL] = [:]
        var assetsKeyArray:[String] = []
        for asset in assets{
            let fileUrl = documentUrl.appendingPathComponent(game.id).appendingPathComponent(asset.key).appendingPathExtension("png")
            savePaths[asset.key] = fileUrl
            assetsKeyArray.append(asset.key)
        }
        
        //delete the origin assets file if exist
        if let originAssetsProfile = listJsonDic[game.id] as? [String:Any]{
            if let originAssetsKeyArray = originAssetsProfile["assetsKey"] as? [String]{
                for oldKey in originAssetsKeyArray{
                    let oldFileUrl = gameAssetsUrl.appendingPathComponent(oldKey)
                    guard FileManager.default.fileExists(atPath: oldFileUrl.path) else { continue }
                    do{
                        try FileManager.default.removeItem(at: oldFileUrl)
                    }
                    catch let error{
                        debugLog("[GameAssetsManager] remove old game asset (path=\(oldFileUrl.path)) failed due to \(error.localizedDescription)")
                    }
                }
            }
        }
        
        //record new information
        listJsonDic[game.id] = [
            "assetsKeys":assetsKeyArray,
            "version":version,
            "profile":game.propertyDictionary(),
            "createDate":Date.getLocalDateStrWithDate(date: Date.getLocalDateWithSystemDate(date: Date()))
        ]
        
        //create folder if needed
        if !FileManager.default.fileExists(atPath: gameAssetsUrl.path){
            do{
                try FileManager.default.createDirectory(at: gameAssetsUrl, withIntermediateDirectories: false, attributes: [:])
            }
            catch let error{
                debugLog("[GameAssetsManager] create game asset directory failed due to \(error.localizedDescription)")
                return false
            }
        }
        
        //save data
        for saveItem in savePaths{
            guard let data = assets[saveItem.key] else {
                debugLog("[GameAssetsManager] save aseets failed : save item with key(\(saveItem.key)) data is empty")
                return false
            }
            do{
                //try (data as NSData).write(to: saveItem.value, atomically: true)
                try data.write(to: saveItem.value, options: .atomic)
                debugLog("[GameAssetsManager] save aseets with key(\(saveItem.key)) success to path(\(saveItem.value))")
            }
            catch let error{
                debugLog("[GameAssetsManager] save asset with key(\(saveItem.key)) to path(\(saveItem.value.path)) failed due to \(error.localizedDescription)")
                //if error code == 4 means file not exist
                //debugLog("[GameAssetsManager] ")
            }
        }
        //then update list
        guard saveJsonToAssetsVerisonList(listJsonDic: listJsonDic) else {
            //rollback
            //delete all the assets saved
            for saveItem in savePaths{
                if FileManager.default.fileExists(atPath: saveItem.value.path){
                    do{
                        try FileManager.default.removeItem(at: saveItem.value)
                    }
                    catch let error{
                        debugLog("[GameAssetsManager] remove aseet with key(\(saveItem.key)) to path(\(saveItem.value.path)) failed due to \(error.localizedDescription)")
                    }
                }
            }
            debugLog("[GameAssetsManager] roll back finished.")
            return false
        }
        return true
    }
    
    
    func getIconData(for game:GameProfile) -> Data?{
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let iconUrl = documentUrl.appendingPathComponent(game.id, isDirectory: true).appendingPathComponent("gameIconKey").appendingPathExtension("png")
        if FileManager.default.fileExists(atPath: iconUrl.path){
            do{
                let data = try Data(contentsOf: iconUrl)
                return data
            }catch let error{
                debugLog("[GameAssetsManager] load icon with for game \(game.id!) failed : \(error.localizedDescription)")
                return nil
            }
        }
        else{
            return nil
        }
    }
    
    
    func getAssets(for game:GameProfile) -> [String:Data]{
        
        guard let listJson = readAssetsVersionList() else {
            return [:]
        }
        
        guard let gameInfoDic = listJson[game.id] as? [String:Any] else { return [:] }
    
        
        guard let assetsKeys = gameInfoDic["assetsKeys"] as? [String] else { return [:] }
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var result:[String:Data] = [:]
        for key in assetsKeys {
            let fileUrl = documentUrl.appendingPathComponent(game.id).appendingPathComponent(key).appendingPathExtension("png")
            do{
                let data = try Data(contentsOf: fileUrl)
                result[key] = data
            }catch let error{
                debugLog("[GameAssetsManager] load aseets with key(\(key)) failed : \(error.localizedDescription)")
                return [:]
            }
        }
        return result
    }
    
    public func getCachedGameList() -> [CachedGameAssetsEntity] {
        guard let listJson = readAssetsVersionList() else {
            return []
        }
        var result:[CachedGameAssetsEntity] = []
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        for savedItem in listJson{
            guard let savedDic = savedItem.value as? [String:Any] else { continue }
            let savedJson = JSON(savedDic)
            let createDate = Date.getLocalDateWithString(dateStr: savedJson["createDate"].string ?? Date.getLocalDateStrWithDate(date: Date()))
            
            let gameProfile = GameProfile.analyse(savedJson["profile"])!
            let iconUrl = documentUrl.appendingPathComponent(gameProfile.id, isDirectory: true).appendingPathComponent("gameIconKey").appendingPathExtension("png")
            var iconData:Data?
            if FileManager.default.fileExists(atPath: iconUrl.path){
                //read icon data
                do{
                    iconData = try Data(contentsOf: iconUrl)
                }
                catch let error{
                    debugLog("[GameAssetsManager] auto load icon with for game \(gameProfile.id!) failed : \(error.localizedDescription)")
                }
            }
            
            let entity = CachedGameAssetsEntity(profile: gameProfile, version: savedJson["version"].stringValue, itemCount: savedJson["assetsKeys"].arrayValue.count,createDate: createDate,iconData: iconData)
            result.append(entity)
        }
        return result
    }
    
    
    public func deleteAssets(for game:GameProfile) -> Bool {
        guard var listJson = readAssetsVersionList() else {
            return false
        }
        guard var gameProperties = listJson[game.id] as? [String:Any] else { return false }
        guard let assetsKeys = gameProperties["assetsKeys"] as? [String] else { return false }
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderUrl = documentUrl.appendingPathComponent(game.id,isDirectory: true)
        var flag = true
        for assetsKey in assetsKeys {
            flag = flag && LocalCacheManager.shared.deleteFile(url: folderUrl.appendingPathComponent(assetsKey).appendingPathExtension("png"))
        }
        gameProperties.removeValue(forKey: "version")
        gameProperties["assetsKeys"] = []
        listJson[game.id] = gameProperties
        guard saveJsonToAssetsVerisonList(listJsonDic: listJson) else {
            return false
        }
        debugLog("[GameAssetsManager] remove assets for game:\(game.id)")
        return flag
    }
    
    public func deleteAssetsListRecord(for game:GameProfile) -> Bool {
        guard var listJson = readAssetsVersionList() else {
            return false
        }
        listJson.removeValue(forKey: game.id)
        guard saveJsonToAssetsVerisonList(listJsonDic: listJson) else {
            return false
        }
        debugLog("[GameAssetsManager] remove assets record for game:\(game.id)")
        return true
    }
    
    public func getAssetsSize(for game:GameProfile) -> Double{
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folderUrl = documentUrl.appendingPathComponent(game.id,isDirectory: true)
        return LocalCacheManager.shared.getFolderSize(url: folderUrl)
    }
    
    
    private func readAssetsVersionList() -> [String:Any]? {
        
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentUrl.appendingPathComponent(versionListFileName).appendingPathExtension("json")
        //print(fileUrl.path)
        var dataDictionary = LocalCacheManager.shared.readDictionaryFromFile(url: fileUrl)
        if dataDictionary == nil{
            //create
            guard LocalCacheManager.shared.saveDictionaryToFile(url: fileUrl, content: [:]) else {
                debugLog("[GameAssetsManager] create file failed")
                return nil
            }
            dataDictionary = [:]
        }
        return dataDictionary

    }
    
    private func saveJsonToAssetsVerisonList(listJsonDic:[String:Any]) -> Bool{
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentUrl.appendingPathComponent(versionListFileName).appendingPathExtension("json")
        
        return LocalCacheManager.shared.saveDictionaryToFile(url: fileUrl, content: listJsonDic)

    }
    
    
}
