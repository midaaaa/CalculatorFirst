//
//  CalculationsListViewController.swift
//  CalculatorFirst
//
//  Created by Дмитрий Филимонов on 30.01.2025.
//

import UIKit

class CalculationsListViewController: UIViewController {
    
    var result: String?
    @IBOutlet weak var calculationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        calculationLabel.text = result
    }
    
    
}
