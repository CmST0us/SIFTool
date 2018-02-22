//
//  AppDelegate.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        ApiHelper.shared.baseUrlPath = "http://schoolido.lu/api"
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return .terminateNow
    }

}

