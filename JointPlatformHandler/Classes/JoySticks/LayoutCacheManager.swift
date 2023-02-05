//
//  LayoutCacheManager.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/23.
//

import UIKit
import SwiftyJSON

struct JoyStickLayoutItem{
    var component:JoyStickComponent
    var size:CGSize = CGSize.zero
    var origin:CGPoint = CGPoint.zero
    
    var propertyDictionary:[String:Any]{
        get{
            var componentDic:[String:Any] = [
                "description":component.layoutDescription,
                "tag":component.comTag!,
                "type":component.typeString,
                "size":[
                    "width":size.width,
                    "height":size.height,
                ],
                "origin":[
                    "x":origin.x,
                    "y":origin.y
                ]
            ]
            for attachDataKey in component.attachedDatas.keys{
                componentDic[attachDataKey] = component.attachedDatas[attachDataKey]
            }
            return componentDic
        }
    }
}



class LayoutCacheManager:NSObject{
    
    private struct JoyStickLayoutContent{
        var items:[JoyStickLayoutItem] = []
        var version:String = ""
    }
    
    
    static let shared:LayoutCacheManager = {
        let manager = LayoutCacheManager()
        return manager
    }()
    
    private let stickConfigFilePrefix = "stickConfig"
    
    private override init(){
        
    }
    
    func hasLayout(for game:GameProfile,version:inout String) -> Bool{
        guard let savedJson = readLocalJson(for: game) else { return false }
        version = savedJson["layoutVersion"].stringValue
        return savedJson != JSON.null
    }
    
    func getLayout(for game:GameProfile) -> [JoyStickLayoutItem]{
        guard let savedJson = readLocalJson(for: game) else { return [] }
        return convert(Json: savedJson).items
    }
    
    func saveLayout(for game:GameProfile,items:[JoyStickLayoutItem],version:String){
        var saveDic:[String:Any] = [
            "components":[],
            "layoutVersion":version
        ]
        var componentsDicArray:[[String:Any]] = []
        for item in items {
            componentsDicArray.append(item.propertyDictionary)
        }
        saveDic["components"] = componentsDicArray
        let saveJson = JSON(saveDic)
        let _ = saveJsonToFile(for: game, Json: saveJson)
    }
    
    func convertAndSave(with configs:[String:Any],game:GameProfile) -> [JoyStickLayoutItem]{
        let layoutContent = convert(Json: JSON(configs))
        saveLayout(for: game, items: layoutContent.items, version: layoutContent.version)
        return layoutContent.items
    }
    
    func convertAndUpdate(with configs:[String:Any],game:GameProfile) -> [JoyStickLayoutItem]{
        guard let savedJson = readLocalJson(for: game) else {
            return convertAndSave(with: configs, game: game)
        }
        let savedItems = convert(Json: savedJson).items
        let newLayoutContent = convert(Json: JSON(configs))
        var newItems = newLayoutContent.items
        for (idx,newItem) in newItems.enumerated() {
            for i in 0 ..< savedItems.count{
                if savedItems[i].component.comTag == newItem.component.comTag{
                    newItems[idx].origin = savedItems[i].origin
                    newItems[idx].size = savedItems[i].size
                }
            }
        }
        saveLayout(for: game, items: newItems,version: newLayoutContent.version)
        return newItems
    }
    
    public func getLayoutVersion(for game:GameProfile) -> String? {
        guard let savedJson = readLocalJson(for: game) else {
            return nil
        }
        return savedJson["layoutVersion"].string
    }
    
    public func getLayoutFileSize(for game:GameProfile) -> Double{
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let gameAssetsUrl = documentUrl.appendingPathComponent(game.id, isDirectory: true)
        let stickFileUrl = gameAssetsUrl.appendingPathComponent(stickConfigFilePrefix).appendingPathExtension("json")
        return LocalCacheManager.shared.getFileSize(url: stickFileUrl)
    }
    
    public func deleteLayout(for game:GameProfile) -> Bool {
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let gameAssetsUrl = documentUrl.appendingPathComponent(game.id, isDirectory: true)
        let stickFileUrl = gameAssetsUrl.appendingPathComponent(stickConfigFilePrefix).appendingPathExtension("json")
        return LocalCacheManager.shared.deleteFile(url: stickFileUrl)
    }
    
    private func convert(Json:JSON) -> JoyStickLayoutContent {
        let configJsonArray = Json["components"].array ?? []
        var result:[JoyStickLayoutItem] = []
        for configJson in configJsonArray{
            var item:JoyStickLayoutItem!
            switch configJson["type"]{
            case "knob":
                item = JoyStickLayoutItem(component: JoyStickKnob())
                break
            case "button":
                item = JoyStickLayoutItem(component: JoyStickButton())
                break
            default:
                break
            }
            item.origin = CGPoint(x: configJson["origin"]["x"].doubleValue, y: configJson["origin"]["y"].doubleValue)
            item.size = CGSize(width: configJson["size"]["width"].doubleValue, height: configJson["size"]["height"].doubleValue)
            if item.size == CGSize.zero{
                item.size = item.component.defaultSize
            }
            item.component.layoutDescription = configJson["description"].stringValue
            item.component.comTag = configJson["tag"].intValue
            //item.component.attachedDatas["imageName"] = configJson["imageName"].stringValue
            if let propertyDic = configJson.dictionary{
                for key in propertyDic.keys{
                    if key != "type" && key != "origin" && key != "size" && key != "description" && key != "tag"{
                        item.component.attachedDatas[key]=configJson[key].stringValue
                    }
                }
            }
            result.append(item)
        }
        return JoyStickLayoutContent(items: result, version: Json["layoutVersion"].stringValue)
    }
    
    private func readLocalJson(for game:GameProfile) -> JSON?{
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let gameAssetsUrl = documentUrl.appendingPathComponent(game.id, isDirectory: true)
        let fileUrl = gameAssetsUrl.appendingPathComponent(stickConfigFilePrefix).appendingPathExtension("json")
        
        return LocalCacheManager.shared.readJsonFromFile(url: fileUrl)

    }
    
    private func saveJsonToFile(for game:GameProfile,Json:JSON) -> Bool{

        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let gameAssetsUrl = documentUrl.appendingPathComponent(game.id, isDirectory: true)
        
        //create folder if needed
        if !FileManager.default.fileExists(atPath: gameAssetsUrl.path){
            do{
                try FileManager.default.createDirectory(at: gameAssetsUrl, withIntermediateDirectories: false, attributes: [:])
            }
            catch let error{
                debugLog("[LayoutCacheManager] create game asset directory failed due to \(error.localizedDescription)")
                return false
            }
        }
        
        let fileUrl = gameAssetsUrl.appendingPathComponent(stickConfigFilePrefix).appendingPathExtension("json")
        return LocalCacheManager.shared.saveJsonToFile(url: fileUrl, content: Json)

    }
}
