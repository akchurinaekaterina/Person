//
//  Person.swift
//  Person
//
//  Created by Ekaterina Akchurina on 30.09.2020.
//

import UIKit

class Person: NSObject, Codable {
    
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }

}
