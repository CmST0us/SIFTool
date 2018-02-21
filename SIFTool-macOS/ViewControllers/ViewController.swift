//
//  ViewController.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var imageNameTextField: NSTextField!
    @IBOutlet weak var threshParams: NSTextField!
    @IBOutlet weak var morphyParams: NSTextField!
    @IBOutlet weak var covertParams: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = NSImage(named: NSImage.Name("\(imageNameTextField.stringValue)"))
        
    }

    func dumpParam() {
        Logger.shared.console("threshParam: \(threshParams.stringValue)")
        Logger.shared.console("mor: \(morphyParams.stringValue)")
        Logger.shared.console("covertParam: \(covertParams.stringValue)")
    }
    
    @IBAction func doMorph(_ sender: Any) {
        let paramsString = morphyParams.stringValue
        let params = paramsString.split(separator: "|")
        
        let m = imageView.image?.mat
        let sizeString = params[3]
        let sizeArray = sizeString.split(separator: ",")
        let size = CGSize.init(width: Int(sizeArray[0])!, height: Int(sizeArray[1])!)
        
        let pointString = params[4]
        let pointArray = pointString.split(separator: ",")
        let point = CGPoint.init(x: Int(pointArray[0])!, y: Int(pointArray[1])!)
        
        let nm = OpenCVBridgeSwiftHelper.sharedInstance().morphologyEx(withImage: m!, operation: CVBridgeMorphType.init(rawValue: Int(params[0])!)!, iterations: Int32(params[1])!, elementSharp: CVBridgeMorphShape.init(rawValue: Int(params[2])!)!, elementSize: size, elementPoint: point)
        imageView.image = NSImage.init(cvMat: nm)
        dumpParam()
    }
    
    @IBAction func doThresh(_ sender: Any) {
        let m = imageView.image?.mat
        
        let paramsString = threshParams.stringValue
        let params = paramsString.split(separator: "|")
        let nm = OpenCVBridgeSwiftHelper.sharedInstance().threshold(withImage: m!, thresh: Double(params[0])!, maxValue: Double(params[1])!, type: CVBridgeThresholdType.init(rawValue: Int(params[2])!)!)
        imageView.image = NSImage.init(cvMat: nm)
        dumpParam()
    }
    @IBAction func doCovert(_ sender: Any) {
        let m = imageView.image?.mat
        
        let paramsString = covertParams.stringValue
        let params = paramsString.split(separator: "|")
        
        let nm = OpenCVBridgeSwiftHelper.sharedInstance().covertColor(withImage: m!, targetColor: CVBridgeColorCovertType.init(rawValue: Int(params[0])!)!)
        imageView.image = NSImage.init(cvMat: nm)
        dumpParam()
    }
    
    @IBAction func resetImage(_ sender: Any) {
        imageView.image = NSImage(named: NSImage.Name("\(imageNameTextField.stringValue)"))
    }
    @IBAction func drawContours(_ sender: Any) {
        var m = imageView.image?.mat
        let channel = OpenCVBridgeSwiftHelper.sharedInstance().splitImage(m!) as! [CVMat]
        
        m = channel[0]
        
        let cloneM = m?.clone()
        
        let output = OpenCVBridgeSwiftHelper.sharedInstance().findContours(withImage: m!, mode: CVBridgeRetrievalMode.external, method: CVBridgeApproximationMode.none, offsetPoint: CGPoint.zero) as! [[NSValue]]
        
        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = CGFloat.leastNormalMagnitude
        var maxXPlusWeight = CGFloat.leastNormalMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = CGFloat.leastNormalMagnitude
        var maxYPlusHeight = CGFloat.leastNormalMagnitude
        
        for contours in output {
            let rect = contours.contoursRect()
            let area = rect.size.width * rect.size.height
            if area < 50 * 50 {
                continue
            }
            let aspectRadio = Double(rect.size.width / rect.size.height)
            let aspectRadioThresh = 0.2
            if abs(aspectRadio - 1) > aspectRadioThresh {
                continue
            }
            
            minX = Swift.min(minX, rect.origin.x)
            maxX = Swift.max(maxX, rect.origin.x)
            minY = Swift.min(minY, rect.origin.y)
            maxY = Swift.max(maxY, rect.origin.y)
            maxXPlusWeight = Swift.max(maxXPlusWeight, maxX + rect.size.width)
            maxYPlusHeight = Swift.max(maxYPlusHeight, maxY + rect.size.height)
            OpenCVBridgeSwiftHelper.sharedInstance().drawRect(inImage: cloneM!, rect: rect, r: 255, g: 255, b: 255)
        }
        imageView.image = NSImage(cvMat: cloneM!)
        Logger.shared.console("Draw")
        
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

