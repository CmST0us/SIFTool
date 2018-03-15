//
//  ViewController.swift
//  SIFTool-macOS
//
//  Created by CmST0us on 2018/2/14.
//  Copyright © 2018年 eki. All rights reserved.
//

import Cocoa

class CVViewController: NSViewController {
    
    @IBOutlet weak var findLineParam: NSTextField!
    @IBOutlet weak var imageNameTextField: NSTextField!
    @IBOutlet weak var threshParams: NSTextField!
    @IBOutlet weak var morphyParams: NSTextField!
    @IBOutlet weak var covertParams: NSTextField!
    @IBOutlet weak var gaussParams: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = NSImage(named: NSImage.Name("\(imageNameTextField.stringValue)"))
        
    }

    func dumpParam() {
        Logger.shared.console("threshParam: \(threshParams.stringValue)")
        Logger.shared.console("mor: \(morphyParams.stringValue)")
        Logger.shared.console("covertParam: \(covertParams.stringValue)")
        Logger.shared.console("gauss: \(gaussParams.stringValue)")
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
    
    @IBAction func doGauss(_ sender: Any) {
        let m = imageView.image?.mat
        let paramsString = gaussParams.stringValue
        let params = paramsString.split(separator: "|")
        let sizeString = String(params[0])
        let sizeArray = sizeString.split(separator: ",")
        let size = CGSize.init(width: Int(sizeArray[0])!, height: Int(sizeArray[1])!)
        let sigmaX = Double(params[1])!
        let sigmaY = Double(params[2])!
        let nm = OpenCVBridgeSwiftHelper.sharedInstance().gaussianBlur(withImage: m!, kernelSize: size, sigmaX: sigmaX, sigmaY: sigmaY, borderType: CVBridgeBorderType.default)
        
        imageView.image = NSImage.init(cvMat: nm)
        dumpParam()
    }
    @IBAction func resetImage(_ sender: Any) {
        imageView.image = NSImage(named: NSImage.Name("\(imageNameTextField.stringValue)"))
    }
    @IBAction func findLine(_ sender: Any) {
        
        func isHorizonLine(line: (CGPoint, CGPoint)) -> Bool {
            if abs(line.0.x - line.1.x) < 0.001 {
                return false
            }
            if abs((line.1.y - line.0.y) / (line.1.x - line.0.x)) < 0.1 {
                return true
            }
            return false
        }
        
        var mat = imageView.image!.mat
        let cloneMat = mat.clone()
        mat = (OpenCVBridgeSwiftHelper.sharedInstance().splitImage(mat) as! [CVMat])[0]
        let paramString = findLineParam.stringValue
        let tParamArray = paramString.split(separator: "|")
        var paramArray = tParamArray.map { item in
            String(item)
        }
        let rhoParam = Double(paramArray[0])!
        let thresholdParam = Double(paramArray[1])!
        let minLineParam = Double(paramArray[2])!
        let maxLineParam = Double(paramArray[3])!
        let cannyLow = Double(paramArray[4])!
        let cannyHigh = Double(paramArray[5])!
        
        mat = OpenCVBridgeSwiftHelper.sharedInstance().canny(withImage: mat, lowThreshold: cannyLow, highThreshold: cannyHigh)
        var lines = OpenCVBridgeSwiftHelper.sharedInstance().houghlinesP(withImage: mat, rho: rhoParam, theta: Double.pi / 180, threshold: thresholdParam, minLineLength: minLineParam, maxLineGap: maxLineParam) as! [[NSValue]]
        
        lines = lines.filter { (value) -> Bool in
            return isHorizonLine(line: (value[0].pointValue, value[1].pointValue))
        }
        
        lines.sort { (a, b) -> Bool in
            return a[0].pointValue.y < b[0].pointValue.y
        }
        
        var diffArray: [(y1: Double, y2: Double, diff: Double)] = []
        
        for (index, item) in lines.enumerated() {
            if index + 1 == lines.count {
                break
            }
            
            let y1 = item[0].pointValue.y
            let y2 = lines[index + 1][0].pointValue.y
            let diff = y2 - y1
            
            diffArray.append((y1: Double(y1), y2: Double(y2), diff: Double(diff)))
        }

        let maxDistanse = diffArray.max { (a, b) -> Bool in
            return a.diff < b.diff
        }
        
        // max Distance == 0 case
        
        let point11 = CGPoint(x: 0, y: maxDistanse!.y1)
        let point12 = CGPoint(x: Double(cloneMat.size().width), y: maxDistanse!.y1)
        
        let point21 = CGPoint(x: 0, y: maxDistanse!.y2)
        let point22 = CGPoint(x: Double(cloneMat.size().width), y: maxDistanse!.y2)
        
        let roiRect = CGRect(x: 0, y: maxDistanse!.y1, width: Double(cloneMat.size().width), height: maxDistanse!.diff)
        
//        OpenCVBridgeSwiftHelper.sharedInstance().drawLine(inImage: cloneMat, point1: point11, point2: point12, lineWidth: 3, r: 255, g: 0, b: 0)
//        OpenCVBridgeSwiftHelper.sharedInstance().drawLine(inImage: cloneMat, point1: point21, point2: point22, lineWidth: 3, r: 255, g: 0, b: 0)

        
        imageView.image = NSImage.init(cvMat: cloneMat.roi(at: roiRect)!)
    }
    
    @IBAction func drawContours(_ sender: Any) {
        var m = imageView.image?.mat
        let channel = OpenCVBridgeSwiftHelper.sharedInstance().splitImage(m!) as! [CVMat]
        m = channel[0]
        
        func findContours(mat: CVMat, step: Int) -> CVMat {
            let cloneMat = mat.clone()
            let output = OpenCVBridgeSwiftHelper.sharedInstance().findContours(withImage: mat, mode: CVBridgeRetrievalMode.external, method: CVBridgeApproximationMode.none, offsetPoint: CGPoint.zero) as! [[NSValue]]
            
            var minX = CGFloat.greatestFiniteMagnitude
            var maxX = CGFloat.leastNormalMagnitude
            var maxXPlusWeight = CGFloat.leastNormalMagnitude
            var minY = CGFloat.greatestFiniteMagnitude
            var maxY = CGFloat.leastNormalMagnitude
            var maxYPlusHeight = CGFloat.leastNormalMagnitude
            var maxWidth = CGFloat.leastNormalMagnitude
            var maxHeight = CGFloat.leastNormalMagnitude
            for contours in output {
                let rect = contours.contoursRect()
                let area = rect.size.width * rect.size.height
                if area < 80 * 80 {
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
                maxWidth = Swift.max(maxWidth, rect.size.width)
                maxHeight = Swift.max(maxHeight, rect.size.height)
                
                maxXPlusWeight = Swift.max(maxXPlusWeight, maxWidth + maxX)
                maxYPlusHeight = Swift.max(maxYPlusHeight, maxHeight + maxY)
                if step == 1{
                    OpenCVBridgeSwiftHelper.sharedInstance().drawRect(inImage: cloneMat, rect: rect, r: 255, g: 255, b: 255)
                }
            }
            if step == 0 {
                var w = maxXPlusWeight
                var h = maxYPlusHeight
                if w > cloneMat.size().width {
                    w = cloneMat.size().width - minX - 1
                } else {
                    w = maxXPlusWeight - minX
                }
                
                if h > cloneMat.size().height {
                    h = cloneMat.size().height - minY - 1
                } else {
                    h = maxYPlusHeight - minY
                }
                // user 8 pix offset to avoid button layout in 1080p screenshot
                let roiMat = cloneMat.roi(at: CGRect.init(x: minX, y: minY + 8, width: w, height: h - 8))
                let centerY = roiMat!.size().height / 2 - 1
                let centerBrokeArrowRect = CGRect.init(x: 0, y: centerY, width: roiMat!.size().width, height: 2)
                OpenCVBridgeSwiftHelper.sharedInstance().drawRect(inImage: roiMat!, rect: centerBrokeArrowRect, r: 0, g: 0, b: 0)
                return roiMat!
            }
            return cloneMat
        }
        let roi = findContours(mat: m!, step: 0)
        let drawMat = findContours(mat: roi, step: 1)
        imageView.image = NSImage(cvMat: drawMat)
        Logger.shared.console("Draw")
        
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

