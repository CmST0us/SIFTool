//
//  Logger.swift
//  LLInfo
//
//  Created by CmST0us on 2018/2/7.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation
class Logger {
    
    enum Level {
        case info
        case warn
        case error
    }
    
    private init() {
        
    }
    static let shared = Logger()
    
}

extension Logger {
    func console(_ msg: String, _ level: Level = Level.info,
                 _ file: String = #file, line: Int = #line,
                 _ col: Int = #column, _ function: String = #function) {
        var levelString = "INFO"
        switch level {
        case .info:
            levelString = "INFO"
        case .warn:
            levelString = "WARN"
            break
        case .error:
            levelString = "ERROR"
        }
        #if DEBUG
            let time = Date(timeIntervalSinceNow: 0)
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss.SSSS"
            let timeString = formatter.string(from: time)
            let ps = """
            {
            time: "\(timeString)",
            msg: "\(msg)",
            level: "\(levelString)",
            file: "\(file)",
            line: \(line),
            col: \(col),
            func: "\(function)"
            },
            """
            print(ps)
        #endif
    }
}

