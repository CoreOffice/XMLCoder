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
        
        parseNoteError()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func parseToDict(_ data: Data) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        do {
            dict = try _XMLStackParser.parse(with: data)
        } catch {
            print(error)
        }
        
        return dict
    }

    func parseNote() -> Note? {
        guard let fileURL = Bundle.main.url(forResource: "note", withExtension: "xml"),
            let data = try? Data(contentsOf: fileURL) else { return nil }
        
        let decoder = XMLDecoder()
        
        let note: Note?
        
        do {
            note = try decoder.decode(Note.self, from: data)
        } catch {
            print(error)
            
            note = nil
        }
        
        return note
    }
    
    func parseNoteError() {
        guard let fileURL = Bundle.main.url(forResource: "note_error", withExtension: "xml"),
            let data = try? Data(contentsOf: fileURL) else { return }
        
        let decoder = XMLDecoder()
        
        let note: Note?
        
        do {
            note = try decoder.decode(Note.self, from: data)
        } catch {
            print(error)
            
            note = nil
        }
    }
}

