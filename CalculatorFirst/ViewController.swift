//
//  ViewController.swift
//  CalculatorFirst
//
//  Created by Дмитрий Филимонов on 29.01.2025.
//

import UIKit

enum CalculationError: Error {
    case divisionByZero
}

enum Operation: String {
    case add = "+"
    case subtract = "-"
    case multipy = "x"
    case divide = "/"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
        case .add:
            return number1 + number2
        case .subtract:
            return number1 - number2
        case .multipy:
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.divisionByZero
            }
            return number1 / number2
        }
    }
}

enum  CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {

    @IBAction func buttonPressed(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel!.text else {return}
        
        if buttonText == "," && label.text!.contains(",") {
            return
        }
        
        if label.text == "0" && buttonText != "," {
            label.text = buttonText
        } else {
            label.text!.append(buttonText)
        }
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard
            let buttonText = sender.titleLabel!.text,
            let buttonOperation = Operation(rawValue: buttonText)
            else {return}
        
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
            else {return}
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        resetLabel()
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        resetLabel()
    }
    
    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
            else {return}
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            label.text = numberFormatter.string(from: NSNumber(value: result))
        } catch {
            label.text = "Undefined"
        }
        
        calculationHistory.removeAll()
    }
    
    @IBOutlet weak var label: UILabel!
    
    var calculationHistory: [CalculationHistoryItem] = []
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resetLabel()
    }

    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else {return 0}
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard case .operation(let operation) = calculationHistory[index],
                  case .number(let number) = calculationHistory[index + 1]
            else {break}
            
            currentResult = try  operation.calculate(currentResult, number )
        }
        return currentResult
    }
    
    func resetLabel() {
        label.text = "0"
    }
    
}

 
