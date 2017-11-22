//
//  ViewController.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let fileURL = Bundle.main.url(forResource: "RJI_RSS_Sample", withExtension: "xml"),
              let data = try? Data(contentsOf: fileURL) else { return }
        
//        let parser = _XMLStackParser()
//
//        let node: _XMLNode?
//
//        do {
//            node = try parser.parse(with: data)
//
//            print("Success")
//        } catch let error {
//            print(error)
//
//            node = nil
//        }
        
        
        print("Hello")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

