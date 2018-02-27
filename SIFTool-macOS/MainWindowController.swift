//
//  MainWindowController.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/2/27.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    var titleBarView: NSView  {
        return (window?.standardWindowButton(.closeButton)?.superview?.superview)!
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
        titleBarView.frame.size.height = 58
    }

}

extension MainWindowController: NSWindowDelegate {
    func windowDidResize(_ notification: Notification) {
        titleBarView.frame.size.height = 58
    }
}
