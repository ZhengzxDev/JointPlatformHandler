//
//  extension+Date.swift
//  JointPlatformHandler
//
//  Created by luckyXionzz on 2022/1/13.
//

import UIKit

extension Date{
    static func getLocalDateWithString(dateStr:String,format:String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let formatter = DateFormatter.init()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        let date = formatter.date(from: dateStr)
        return date!
    }
    
    static func getLocalDateWithSystemDate(date:Date) -> Date {
        let zone = NSTimeZone.system
        let interval = zone.secondsFromGMT(for: date)
        let localDate = date.addingTimeInterval(TimeInterval(interval))
        return localDate
    }
    
    static func getLocalDateStrWithDate(date:Date,format:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter.init()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        let dateStr = formatter.string(from: date)
        return dateStr
    }
    ///毫秒级时间戳
    var milliStamp:String{
        get{
            let timeInterval:TimeInterval = self.timeIntervalSince1970
            let millisecond = CLongLong(round(timeInterval*1000))
            return "\(millisecond)"
        }
    }
    
    public static func getDateFromStamp(timeStamp:String) -> Date?{
        guard let time = Double(timeStamp) else { return nil }
        var interval:TimeInterval!
        if timeStamp.count == 10{
            interval  = TimeInterval(time)
        }
        else{
            interval  = TimeInterval(time/1000)
        }
        let date = Date(timeIntervalSince1970: interval)
        return date
    }
    
}
