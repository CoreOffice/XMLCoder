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
        
        let person = Person(Name: "Shawn Moore", social: [])
        
        let encoder = XMLEncoder()
        
        var result: Data?
        
        do {
            result = try encoder.encode(person, withRootKey: "person")
            
            print("XML: \(String(data: result!, encoding: .utf8))")
        } catch {
            print(error)
        }
        
        guard let data = result else { return }
        
        var newPerson: Person?
        
        let decoder = XMLDecoder()
        
        do {
            newPerson = try decoder.decode(Person.self, from: data)
            
            print("Success")
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

struct Person: Codable {
    var Name: String
    var social: [SocialSecurity]?
}

struct SocialSecurity: Codable {
    var number: String
}



