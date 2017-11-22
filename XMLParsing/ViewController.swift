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
        
//        let dict = parseToDict(retrieveData(for: "book")!)
        
//        let dict = parseToDict(retrieveData(for: "breakfast")!)
        
        let catalog: CDCatalog! = parseCDCatalog()
        
        print("finished")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func retrieveData(for resource: String) -> Data? {
        guard let fileURL = Bundle.main.url(forResource: resource, withExtension: "xml") else { return nil }
        
        return try? Data(contentsOf: fileURL)
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
        guard let data = retrieveData(for: "note") else { return nil }
        
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
        guard let data = retrieveData(for: "note_error") else { return }
        
        let decoder = XMLDecoder()
        
        do {
            _ = try decoder.decode(Note.self, from: data)
        } catch {
            print(error)
        }
    }
    
    func parseBook() -> Book? {
        guard let data = retrieveData(for: "book") else { return nil }
        
        let decoder = XMLDecoder()
        
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let book: Book?
        
        do {
            book = try decoder.decode(Book.self, from: data)
        } catch {
            print(error)
            
            book = nil
        }
        
        return book
    }
    
    func parseLibrary() -> Catalog? {
        guard let data = retrieveData(for: "books") else { return nil }
        
        let decoder = XMLDecoder()
        
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let catalog: Catalog?
        
        do {
            catalog = try decoder.decode(Catalog.self, from: data)
        } catch {
            print(error)
            
            catalog = nil
        }
        
        return catalog
    }
    
    func parseMenu() -> Menu? {
        guard let data = retrieveData(for: "breakfast") else { return nil }
        
        let decoder = XMLDecoder()
        
        let menu: Menu?
        
        do {
            menu = try decoder.decode(Menu.self, from: data)
        } catch {
            print(error)
            
            menu = nil
        }
        
        return menu
    }
    
    func parsePlantCatalog() -> PlantCatalog? {
        guard let data = retrieveData(for: "plant_catalog") else { return nil }
        
        let decoder = XMLDecoder()
        
        let plantCatalog: PlantCatalog?
        
        do {
            plantCatalog = try decoder.decode(PlantCatalog.self, from: data)
        } catch {
            print(error)
            
            plantCatalog = nil
        }
        
        return plantCatalog
    }
    
    func parseCDCatalog() -> CDCatalog? {
        guard let data = retrieveData(for: "cd_catalog") else { return nil }
        
        let decoder = XMLDecoder()
        
        let catalog: CDCatalog?
        
        do {
            catalog = try decoder.decode(CDCatalog.self, from: data)
        } catch {
            print(error)
            
            catalog = nil
        }
        
        return catalog
    }
}

