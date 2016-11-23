//
//  CalculatorModel.swift
//  Calc
//
//  Created by Krishna on 20/08/16.
//  Copyright © 2016 Mehuls. All rights reserved.
//

import Foundation

typealias PropertyList = AnyObject

class calculatorModel {
    
    let formatter = NSNumberFormatter()
    init() {
        formatter.maximumFractionDigits = 4
    }
    
    private struct pendingBinaryOperationInfo {
        var operation: (Double,Double)->Double
        var operand: Double
    }
    
    private struct DataForInternalProgram {
        var printable = [PropertyList]() //Stores values which gets updated constantly into a structured form
        var raw = [PropertyList]()       //Stores values as inputted for the current cont. operations
        var prevRaw = [PropertyList]()   //Stores values as inputted for the previous cont. operations
    }
    
    private var initialOperand = 0.0 //Is an accumulator for the operations left operand
    private var pendingBinaryOperation: pendingBinaryOperationInfo? //Stores Last binary operation and left operand, nil if none
    private var internalProgram = DataForInternalProgram()
    var removeLastOperand = false
    private var remove = false
    var M = 0.0
    
    var isPartialResult: Bool {
        if pendingBinaryOperation == nil {
            return false
        }
        return true
    }
    
    var program: PropertyList {
        return internalProgram.printable
    }
    
    var rawProgram: [AnyObject] {
        return internalProgram.raw
    }
    
    var result: Double {
        return initialOperand
    }
    
    private enum operationType {
        case variable
        case constant(Double)
        case unary(Double->Double)
        case binary((Double,Double)->Double)
        case equals
    }
    
    private var operations: Dictionary<String,operationType> =
        [
            "M"     : operationType.variable,
            "sin"   : operationType.unary { sin($0) },
            "log"   : operationType.unary { log($0) },
            "+/-"   : operationType.unary { -1*$0 },
            "√"     : operationType.unary { sqrt($0) },
            "pi"    : operationType.constant(3.14),
            "a^x"   : operationType.binary { pow($0,$1) },
            " XOR " : operationType.binary { Double(Int($0)^Int($1)) },
            "/"     : operationType.binary { if $1 == 0.0 { return 0} else { return $0/$1} },
            "x"     : operationType.binary { $0*$1 },
            "+"     : operationType.binary { $0+$1 },
            "-"     : operationType.binary { $0-$1 },
            "="     : operationType.equals
        ]
    
    func performOperation(operationString: String, operand currentOperand: Double) {
        let operation = operations[operationString]!
        
        updateDataForInternalPogram(operation: operationString, operand: currentOperand)
        
        switch operation {
        case .variable: initialOperand = M
        
        case .constant(let value): initialOperand = value
        
        case .unary(let unaryOperation): initialOperand = unaryOperation(currentOperand)
        
        case .binary(let binaryOperation):
            if pendingBinaryOperation == nil {
                pendingBinaryOperation = pendingBinaryOperationInfo(operation: binaryOperation, operand: currentOperand)
                initialOperand = currentOperand
            } else {
                pendingBinaryOperation!.operand = pendingBinaryOperation!.operation(currentOperand, pendingBinaryOperation!.operand)
                pendingBinaryOperation!.operation = binaryOperation
                initialOperand = pendingBinaryOperation!.operand
            }
        
        case .equals:
            if  pendingBinaryOperation != nil {
                initialOperand = pendingBinaryOperation!.operation(pendingBinaryOperation!.operand, currentOperand)
                pendingBinaryOperation = nil
            }
        }
    }
    
    private func updateDataForInternalPogram(operation operationString: String, operand currentOperand: Double) {
        let operation = operations[operationString]!

        switch operation {
        case .unary:
            internalProgram.printable.insert("(", atIndex: 0)
            internalProgram.printable.insert(operationString, atIndex: 0)
            if let _ = internalProgram.printable.last as? String {
                internalProgram.printable.append(currentOperand)
            }
            internalProgram.printable.append(")")
        
        case .constant, .variable:
            internalProgram.printable.append(operationString)
        
        case .binary, .equals:
            internalProgram.raw.append(currentOperand)
            fallthrough
        
        default:
            internalProgram.printable.append(currentOperand)
            internalProgram.printable.append(operationString)
        }
        internalProgram.raw.append(operationString)
        
    }
    
    func clear() {
        initialOperand = 0
        pendingBinaryOperation = nil
        clearProgram()
        removeLastOperand = false
        M = 0.0
    }
    
    func clearProgram() {
        internalProgram.prevRaw = internalProgram.raw
        internalProgram.raw.removeAll()
        internalProgram.printable.removeAll()
    }

    func getProgramHistory() -> String {
        var history = ""
        
        if (removeLastOperand == true && isPartialResult) || remove{
            internalProgram.printable.removeAtIndex(internalProgram.printable.count-2)
            removeLastOperand = false
            remove = false
        }
        
        //Check if the last element is a const, var, ) or equals sign. If yes, remove the last operand (which is the result)
        if let check = internalProgram.printable.last as? String {
                if check == "=" || check == ")" {
                    removeLastOperand = true
                    if check == "=" {
                        internalProgram.printable.popLast()
                    }
                } else {
                    if let operation = operations[check] {
                        switch operation {
                        case .variable,.constant(_):
                            remove = true
                        default:
                            break
                    }
                }
            }
        }
        
        for token in internalProgram.printable {
            if let operand = token as? Double {
                if operand - floor(operand) > 0.0 {
                    history += formatter.stringFromNumber(operand)!
                } else {
                    history += String(Int(operand))
                }
            }
            if let operation = token as? String {
                history += operation
            }
        }
        return history
    }
    
    func printRawProgram() {
        for token in internalProgram.raw {
            if let operand = token as? Double {
                if operand - floor(operand) > 0.0 {
                    print(formatter.stringFromNumber(operand)!, terminator:" ")
                } else {
                    print(String(Int(operand)), terminator:" ")
                }
            }
            if let operation = token as? String {
                print(operation, terminator:" ")
            }
        }
        print("")
    }
}

