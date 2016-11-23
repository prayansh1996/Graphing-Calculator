//
//  GraphView.swift
//  Calc
//
//  Created by Krishna on 03/09/16.
//  Copyright © 2016 Mehuls. All rights reserved.
//

import UIKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    let point = CGPoint(x: left.x+right.x, y: left.y+right.y)
    return point
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    let point = CGPoint(x: left.x-right.x, y: left.y-right.y)
    return point
}

@IBDesignable
class GraphView: UIView {
    var i = 0
    private var calcModel = calculatorModel()
    private var operandForCalcModel = 0.0
    private var axes = AxesDrawer(color: UIColor.whiteColor(), contentScaleFactor: 3 )
    private var functionPoints = [CGPoint]()
    
    @IBInspectable var color = UIColor.cyanColor() { didSet { setNeedsDisplay() } }
    @IBInspectable var scale = CGFloat(100) { didSet { setNeedsDisplay() } }
    @IBInspectable var graphCenter = CGPoint(x: 0,y: 0) { didSet { setNeedsDisplay() } }
    @IBInspectable var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    
    private var startingPoint: Int {
        return Int(bounds.minX - graphCenter.x)*100
    }
    private var endingPoint: Int {
        return Int(bounds.maxX - graphCenter.x)*100
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        graphCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        fillInitially()
    }
    
    func fillInitially() {
        functionPoints = []
        var (x,dx) = (CGFloat(startingPoint), CGFloat(1))
        while(x<CGFloat(endingPoint)) {
            let tempx = x/scale
            functionPoints.append(CGPoint(x: x, y: sin(tempx)))
            x += dx
        }
    }
    
    //Gesture Recogonizers
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed,.Ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed: fallthrough
        case .Ended:
            let point = recognizer.translationInView(self)
            graphCenter.x += point.x
            graphCenter.y += point.y
            recognizer.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .Ended:
            let point = graphCenter + graphCenter - recognizer.locationInView(self)
            graphCenter = point
            print(point)
            scale*=2
        default:
            break
        }
    }
    
    func fix(var function: [AnyObject]) -> [AnyObject]{
        var count = function.count
        var i=0
        print(function)
        while(i<count) {
            print("\(function) - \(count) - \(function.count)")
            if i+1 == function.count {
                break
            }
            if let token = function[i] as? String {
                if token == "M" {
                    function.removeAtIndex(i+1)
                    function.removeAtIndex(i-1)
                    count = count - 2
                }
            }
            i++
        }
        print(function)
        return function
    }
    
    //Function Implementation - Make gestures computation Independent
    func computeFunction(var function: [AnyObject]) {
        functionPoints = []
        print(function)
        for x in startingPoint...endingPoint {
            calcModel.clear()
            calcModel.M = Double(x)/Double(scale)
            for token in function {
                if let operand = token as? Double {
                    operandForCalcModel = operand
                }
                if let operation = token as? String {
                    if operation == "M" {
                        operandForCalcModel = calcModel.M
                    } else {
                        calcModel.performOperation(operation, operand: operandForCalcModel)
                    }
                }
            }
            functionPoints.append(CGPoint(x: Double(x), y: calcModel.result))
            //print(calcModel.result)
        }
    }
    
    func drawCurentFunction() -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(functionPoints[0])
        
        for i in 1..<functionPoints.count {
            let (x,y) = (graphCenter.x + functionPoints[i].x, graphCenter.y - functionPoints[i].y * scale)
            path.addLineToPoint(CGPoint(x: x, y: y))
        }
        
        return path
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        axes.drawAxesInRect(bounds, origin: graphCenter, pointsPerUnit: scale)
        let path = drawCurentFunction()
        color.set()
        path.lineWidth = lineWidth
        path.stroke()
    }

}

//let path = UIBezierPath(arcCenter: graphCenter, radius: scale, startAngle: 0, endAngle: 2*CGFloat(M_PI), clockwise: false)
