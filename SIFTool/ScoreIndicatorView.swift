//
//  ScoreIndicatorView.swift
//  SIFTool
//
//  Created by CmST0us on 2018/3/6.
//  Copyright © 2018年 eki. All rights reserved.
//

import UIKit

@IBDesignable
class ScoreIndicatorView: UIView {
    
    @IBInspectable
    var indicatorBackgroundColor: UIColor = UIColor.gray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var indicatorProcessColor: UIColor = UIColor.blue {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var scoreLabelColor: UIColor = UIColor.white {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var indicatorCornerRadius: Double = 10.0 {
        didSet {
            updateView()
        }
    }
    @IBInspectable
    var maxScore: Double = 100 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var minScore: Double = 0 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var score: Double = 50 {
        didSet {
            updateView()
            
        }
    }
    
    
    @IBInspectable
    var scoreLabelTextSize: Double = 11 {
        didSet {
            scoreLabel.font = UIFont.systemFont(ofSize: CGFloat(scoreLabelTextSize))
        }
    }
    
    
    lazy var scoreLabel: UILabel = {
       return UILabel.init()
    }()
    
    lazy var backgroundShapeLayer: CAShapeLayer = {
        return CAShapeLayer()
    }()
    
    lazy var processShapeLayer: CAShapeLayer = {
        return CAShapeLayer()
    }()
    
    func setupScoreLabel() {
        scoreLabel.font = UIFont.systemFont(ofSize: CGFloat(scoreLabelTextSize), weight: UIFont.Weight.bold)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scoreLabel)
        let layoutGuide = self.layoutMarginsGuide
        NSLayoutConstraint.activate([
            layoutGuide.centerYAnchor.constraint(equalTo: scoreLabel.centerYAnchor),
            layoutGuide.centerXAnchor.constraint(equalTo: scoreLabel.centerXAnchor)
            ])
    }
    
    func drawBackgroundShape() {
        let pathBg = UIBezierPath.init(roundedRect: layer.bounds, cornerRadius: CGFloat(indicatorCornerRadius))
        backgroundShapeLayer.path = pathBg.cgPath
        backgroundShapeLayer.fillColor = indicatorBackgroundColor.cgColor
        backgroundShapeLayer.lineWidth = 0
        backgroundShapeLayer.strokeColor = nil
        backgroundShapeLayer.frame = layer.bounds
    }
    
    func drawProcessShape() {
        let width = Double(self.frame.width)
        var scoreWidth = (width * (score - minScore)) / (maxScore - minScore)
        if maxScore == minScore {
            scoreWidth = 0
        }
        let scoreHeight = Double(self.frame.height)
        let path = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: scoreWidth, height: scoreHeight), cornerRadius: CGFloat(indicatorCornerRadius))
        
        processShapeLayer.path = path.cgPath
        processShapeLayer.fillColor = indicatorProcessColor.cgColor
        processShapeLayer.strokeColor = nil
        processShapeLayer.lineWidth = 0
        processShapeLayer.frame = layer.bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.addSublayer(backgroundShapeLayer)
        layer.addSublayer(processShapeLayer)
        
        drawBackgroundShape()
        drawProcessShape()
        
        setupScoreLabel()
        scoreLabel.text = String(Int(score))
        scoreLabel.textColor = scoreLabelColor
    }
    
    func updateView() {
        drawBackgroundShape()
        drawProcessShape()
        self.scoreLabel.text = String(Int(score))
        
    }
}
