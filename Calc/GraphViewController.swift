//
//  GraphViewController.swift
//  Calc
//
//  Created by Krishna on 03/09/16.
//  Copyright © 2016 Mehuls. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        print("error")
        graphView.computeFunction(function)
        print("here____________")
    }
    
    var function: [AnyObject] = [] {
        didSet {
            print("here")
        }
    }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: graphView, action: #selector(graphView.changeScale(_:))
                ))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(
                target: graphView, action: #selector(graphView.pan(_:))
                ))
            
            let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(
                target: graphView, action: #selector(graphView.handleDoubleTap(_:)
                ))
            doubleTap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(doubleTap)
        }
    }
    
}
