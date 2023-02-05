//
//  GlobalMethod.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/8.
//

import UIKit

enum DebugLogFilter:Int{
    case Base = 3
    case RunDetail = 2
    case AllMessage = 1
}

enum DebugLogType:Int{
    case Important = 3
    case Normal = 2
    case Gossip = 1
}

struct DebugConfig{
    static let enable:Bool = true
    static let filter:DebugLogFilter = .RunDetail
}

func debugLog(_ str:String,belong:DebugLogType = .Important){
    guard DebugConfig.enable else { return }
    guard belong.rawValue >= DebugConfig.filter.rawValue else { return }
    print(str)
}



