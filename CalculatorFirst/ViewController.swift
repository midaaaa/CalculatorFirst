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
        
        if label.text == "Undefined" {
            resetLabel()
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
        
        let hasOperation = calculationHistory.contains { item in
            if case .operation(_) = item { return true }
            return false
        }
        
        if !hasOperation { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            label.text = numberFormatter.string(from: NSNumber(value: result))
            let newCalculation = Calculation(expression: calculationHistory, result: result)
            //calculations.append(newCalculation)
            calculations.insert(newCalculation, at: 0)
            calculationHistoryStorage.setHistory(calculation: calculations)
        } catch {
            label.text = "Undefined"
            label.shake()
        }
        
        calculationHistory.removeAll()
    }
    
    @IBOutlet weak var label: UILabel!
    
    var calculationHistory: [CalculationHistoryItem] = []
    var calculations: [Calculation] = []
    
    let calculationHistoryStorage = CalculationHistoryStorage()
    
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
        calculations = calculationHistoryStorage.loadHistory()
        
        view.subviews.forEach { subview in
            if let button = subview as? UIButton {
                button.layer.cornerRadius = button.frame.size.width / 2
                button.clipsToBounds = true
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchDown)
            }
        }
    }
  
    @objc func buttonTapped(_ sender: UIButton) {
        sender.animateTap()
    }
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(withIdentifier: "CalculationsListViewController")
        if let vc = calculationsListVC as? CalculationsListViewController {
            vc.calculations = calculations
        }
        
        show(calculationsListVC, sender: self)
        navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else {return 0}
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard case .operation(let operation) = calculationHistory[index],
                  case .number(let number) = calculationHistory[index + 1]
            else {break}
            
            currentResult = try  operation.calculate(currentResult, number)
        }
        return currentResult
    }
    
    func resetLabel() {
        label.text = "0"
    }
}

extension UILabel {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 10, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 10, y: center.y))
        
        layer.add(animation, forKey: "position")
    }
}


extension UIButton {
    
    func animateTap() {
        let lightenAnimation = CAKeyframeAnimation(keyPath: "opacity")
        lightenAnimation.duration = 0.1
        lightenAnimation.values = [1, 0.5]
        lightenAnimation.keyTimes = [0, 1]
        lightenAnimation.autoreverses = true
                            
        layer.add(lightenAnimation, forKey: "lightenAnimation")
    }
}
