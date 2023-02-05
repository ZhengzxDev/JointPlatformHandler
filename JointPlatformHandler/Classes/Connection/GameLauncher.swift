//
//  GameLauncher.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/4/6.
//

import Foundation
import SwiftyJSON

protocol GameLauncherDelegate:NSObjectProtocol{
    /// 0 = no error
    /// 1 = internal error
    /// 2 = connector send failed
    /// 3 = read assets failed
    /// 4 = save assets failed
    /// 5 = terminate by server
    func gameLauncherOnError(_ errorCode:Int)
    
    func gameLauncherAssetsPrepared()
}

///调用AssetsManager进行游戏前的资源比对以及同步
class GameLauncher:NSObject{
    
    public weak var delegate:GameLauncherDelegate?
    
    private var connector:GameRoomConnector?
    
    private var assetsData:[String:Data] = [:]
    
    private var assetsCount:Int = 0
    
    private var assetsVersion:String = ""
    
    private var gameProfile:GameProfile?
    
    
    init(connector:GameRoomConnector){
        self.connector = connector
    }
    
    
    func startProcedure(for game:GameProfile,assetsVersion:String,forceRefresh:Bool){
        debugLog("[GameLauncher] start launch procedure ")
        NotificationCenter.customAddObserver(self, selector: #selector(onServerEcho(_:)), name: .HosterEcho, object: nil)
        assetsData = [:]
        assetsCount = 0
        self.gameProfile = game
        self.assetsVersion = assetsVersion
        if !forceRefresh {
            GameAssetsManager.shared.versionVerify(for: game, newVersion: assetsVersion) { [weak self] isAssetsVersionFit in
                guard let strongSelf = self else {
                    debugLog("[GameLauncher] internal error ")
                    self?.delegate?.gameLauncherOnError(1)
                    return
                }
                if !isAssetsVersionFit {
                    guard strongSelf.connector?.syncToServer(type: .gameAssetsRequest, dictionary: nil) ?? false else {
                        debugLog("[GameLauncher] send game assets request failed")
                        self?.delegate?.gameLauncherOnError(2)
                        return
                    }
                    
                    debugLog("[GameLauncher] request for game assets")
                }
                else {
                    debugLog("[GameLauncher] assets load from local")
                    strongSelf.delegate?.gameLauncherAssetsPrepared()
                }
            }
        }
        else{
            //force to refresh assets
            guard self.connector?.syncToServer(type: .gameAssetsRequest, dictionary: nil) ?? false else {
                debugLog("[GameLauncher] force refresh to send game assets request failed")
                self.delegate?.gameLauncherOnError(2)
                return
            }
        }
        
    
    }
    
    
    func terminateProcedure(){
        debugLog("[GameLauncher] terminated ")
        NotificationCenter.default.removeObserver(self)
    }
    
    
}


extension GameLauncher{
    
    @objc
    private func onServerEcho(_ notification:Notification){
        guard let data = notification.userInfo?[JtUserInfo.Key.Data] as? Data else { return }
        guard let dataType = notification.userInfo?[JtUserInfo.Key.DataType] as? JtSyncDataType else { return }
        debugLog("[GameLauncher] server echo received")
        switch dataType {
        case .JsonData:
            let Json = JSON(data)
            let typeStr = Json["type"].stringValue
            if typeStr == GameSync.Symbol.gameAssetsSyncPrepare.rawValue{
                guard let assetsCount = Json["msg"]["assetsCount"].int else { return }
                debugLog("[GameLauncher] assets count : \(assetsCount)")
                self.assetsCount = assetsCount
            }
            else if typeStr == GameSync.Symbol.gamePrepareFailed.rawValue{
                debugLog("[GameLauncher] terminate launch by server")
                delegate?.gameLauncherOnError(5)
            }
            else if typeStr == GameSync.Symbol.gameStart.rawValue{
                NotificationCenter.customPost(name: .GameStart, object: nil, userInfo:nil)
            }
            break
        case .ImageData:
            guard let identifier = notification.userInfo?[JtUserInfo.Key.Identifier] as? String else { return }
            guard assetsData.count < assetsCount else { return }
            assetsData[identifier] = data
            debugLog("[GameLauncher] assets received : \(identifier) ")
            if assetsData.count == assetsCount{
                //all received
                //save to disk
                guard GameAssetsManager.shared.saveAssets(for: gameProfile!, version: assetsVersion, assets: assetsData) else {
                    debugLog("[GameAssetsManager] save received assets failed")
                    self.delegate?.gameLauncherOnError(4)
                    return
                }
                delegate?.gameLauncherAssetsPrepared()
            }
        case .Unknown:
            break
        }
    }
}
