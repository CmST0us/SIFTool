//
//  Logger.swift
//  LLInfo
//
//  Created by CmST0us on 2018/2/7.
//  Copyright © 2018年 eki. All rights reserved.
//

import Foundation

protocol LoggerProtocol {
    func log(msg: String);
}
class Logger {
    
    enum Level {
        case info
        case warn
        case error
    }
    
    private init() {
        
    }
    static let shared = Logger()
    var delegate: LoggerProtocol? = nil
    
    var matWindow: UIWindow!
    var imageView: UIImageView!
}

extension Logger {
    private func logString(_ msg: String, _ level: Level = Level.info,
                 _ file: String = #file, _ line: Int = #line,
                 _ col: Int = #column, _ function: String = #function) -> String {
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
        return ps
    }
        
    func console(_ msg: String, _ level: Level = Level.info,
                 _ file: String = #file, _ line: Int = #line,
                 _ col: Int = #column, _ function: String = #function) {
        #if DEBUG
            print(logString(msg, level, file, line, col, function))
        #endif
    }
    
    func output(_ msg: String, _ level: Level = Level.info,
                 _ file: String = #file, _ line: Int = #line,
                 _ col: Int = #column, _ function: String = #function) {
        #if DEBUG
            let logStr = logString(msg, level, file, line, col, function)
            if let d = delegate {
                d.log(msg: logStr)
            } else {
                print(logStr)
            }
        #endif
    }
    
    func showMat(_ mat: CVMat) {
        let image = UIImage.init(cvMat: mat)
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
    
    func enableMatWindow() {
        matWindow = UIWindow(frame: CGRect.init(x: 60, y: 0, width: 300, height: 200))
        imageView = UIImageView(frame: matWindow.bounds)
        matWindow.addSubview(imageView)
        
        matWindow.windowLevel = UIWindowLevelAlert
        matWindow.screen = UIScreen.main
        matWindow.makeKeyAndVisible()
    }
}

