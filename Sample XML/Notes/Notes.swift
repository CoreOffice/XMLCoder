//
//  Notes.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct Note: Codable {
    var to: String
    var from: String
    var heading: String
    var body: String
}

// TEST FUNCTIONS
extension Note {
    static func retrieveNote() -> Note? {
        guard let data = Data(forResource: "note", withExtension: "xml") else { return nil }
        
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
    
    static func retrieveNoteError() {
        guard let data = Data(forResource: "note_error", withExtension: "xml") else { return }
        
        let decoder = XMLDecoder()
        
        do {
            _ = try decoder.decode(Note.self, from: data)
        } catch {
            print(error)
        }
    }
    
    func toXML() -> String? {
        let encoder = XMLEncoder()
        
        do {
            let data = try encoder.encode(self, withRootKey: "note")
            
            return String(data: data, encoding: .utf8)
        } catch {
            print(error)
            
            return nil
        }
    }
}
