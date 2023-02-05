//
//  LocalCacheManager.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/16.
//

import Foundation
import SwiftyJSON

///统一负责本地文件的通用存储访问
class LocalCacheManager{
    
    
    static let shared:LocalCacheManager = {
        let manager = LocalCacheManager()
        return manager
    }()
    
    func readJsonFromFile(url:URL) -> JSON? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            debugLog("[LocalCacheManager] read Json failed , path is not exist : \(url.path)")
            return nil
        }
        do{
            let data = try Data(contentsOf: url)
            let Json = JSON(data)
            return Json
        }catch let error{
            debugLog("[LocalCacheManager] read Json failed : \(error.localizedDescription)")
            return nil
        }
    }
    
    func readDictionaryFromFile(url:URL) -> [String:Any]? {
        guard let Json = readJsonFromFile(url: url) else {
            debugLog("[LocalCacheManager] read dictionary failed")
            return nil
        }
        return Json.dictionaryObject
    }
    
    func saveJsonToFile(url:URL,content:JSON) -> Bool {
        /*guard FileManager.default.fileExists(atPath: url.path) else {
            debugLog("[LocalCacheManager] save Json failed, path is not exist : \(url.path)")
            return false
        }*/
        let writeString = JSON(content).description
        do{
            try writeString.write(to: url, atomically: true, encoding: .utf8)
            debugLog("[LocalCacheManager] write json to file success")
            return true
        }
        catch let error{
            debugLog("[LocalCacheManager] write json to file failed, due to \(error.localizedDescription)")
            return false
        }
    }
    
    func saveDictionaryToFile(url:URL,content:[String:Any]) -> Bool {
        return saveJsonToFile(url: url, content: JSON(content))
    }
    
    func deleteFile(url:URL) -> Bool {
        do{
            try FileManager.default.removeItem(at: url)
            debugLog("[LocalCacheManager] remove file success in path : \(url.path)")
        }
        catch let error{
            debugLog("[LocalCacheManager] remove file failed, due to \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    
    
    func deleteFolder(url:URL) -> Bool {
        guard let childPaths = FileManager.default.subpaths(atPath: url.path) else {
            debugLog("[LocalCacheManager] delete folder failed , folder has no sub paths")
            return false
        }
        
        for path in childPaths{
            let childFilePath = url.appendingPathComponent(path)
            let _ = deleteFile(url: childFilePath)
        }
        
        return deleteFile(url: url)
    }
    
    func getFileSize(url:URL) -> Double {
        var fileSize:Double = 0
        do{
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            fileSize = Double(attr[FileAttributeKey.size] as! UInt64)
        }
        catch let error{
            debugLog("[LocalCacheManager] get file size failed , due to \(error.localizedDescription)")
        }
        return fileSize
    }
    
    func getFolderSize(url:URL) -> Double {
        guard let childPaths = FileManager.default.subpaths(atPath: url.path) else {
            debugLog("[LocalCacheManager] get folder size failed ,folder has no sub paths")
            return 0
        }
        var folderSize:Double = 0
        for path in childPaths{
            let childFilePath = url.appendingPathComponent(path)
            folderSize += getFileSize(url: childFilePath)
        }
        return folderSize
    }
    
}
