//
//  ViewController.swift
//  CATests
//
//  Created by Miguel Angel Adan Roman on 1/2/19.
//  Copyright © 2019 Avantiic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var button: ButtonView!
    var connection: PseudoConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connection = PseudoConnection(connectionTime: 5) { (state) in
            switch state {
            case .disconnected:
                print("Disconnected")
                self.button?.state = .off
            case .connecting:
                print("Connecting")
                self.button?.state = .inProgress
            case .connected:
                print("Connected")
                self.button?.state = .on
            }
        }
        
        let gesture = UITapGestureRecognizer(target: connection, action: #selector(PseudoConnection.toggle))
        button?.addGestureRecognizer(gesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

