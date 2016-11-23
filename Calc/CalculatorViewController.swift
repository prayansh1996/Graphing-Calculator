//
//  ViewController.swift
//  Calc
//
//  Created by Krishna on 20/08/16.
//  Copyright © 2016 Mehuls. All rights reserved.
//

import UIKit
import Darwin

class CalculatorViewController: UIViewController {    //HANDLE TYPING DIRECTLY AFTER RESULT

    private var model = calculatorModel()
    
    private var getNextNumber = false
    private var isFloating = false
    
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var displayValueText: UILabel!
    
    private var displayValue: Double {
        get {
            if displayValueText.text == "M" {
                return model.M
            } else {
                return Double(displayValueText.text!)!
            }
        }
        set {
            if isFloating == false {
                displayValueText.text = String(Int(newValue))
            } else {
                displayValueText.text = model.formatter.stringFromNumber(newValue)
            }
        }
    }
    
    
    
    @IBAction func numberPressed(sender: UIButton) {
        if displayValueText.text == "0" || getNextNumber == true {
            displayValueText.text = ""
            getNextNumber = false
        }
        displayValueText.text! += sender.currentTitle!
        if model.isPartialResult == false {
            model.clearProgram()
        }
    }
    
    @IBAction func clearPressed(sender: UIButton) {
        displayValueText.text = "0"
        isFloating = false
        model.clear()
        historyLabel.text = model.getProgramHistory()
    }
    
    @IBAction func dotPressed(sender: UIButton) {
        if isFloating == false {
            displayValueText.text! += "."
            isFloating = true
        }
    }
    
    @IBAction func operationPressed(sender: UIButton) {
    
        model.performOperation(sender.currentTitle!, operand: displayValue)
        if model.result - floor(model.result) > 0 {
            isFloating = true
        } else {
            isFloating = false
        }
        displayValue = model.result
        historyLabel.text = model.getProgramHistory()
        getNextNumber = true
    }
    
    @IBAction func variablePressed(sender: UIButton) {
        displayValueText.text! = "M"
    }
    
    @IBAction func variableSet(sender: UIButton) {
        model.M = displayValue
        model.removeLastOperand = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        default:
            let vc = segue.destinationViewController as! UINavigationController
            let graphVC = vc.viewControllers.first as! GraphViewController
            graphVC.function = model.rawProgram
        }
    }
}

