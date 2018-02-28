//: Playground - noun: a place where people can play

import Cocoa

@objcMembers
class Person: NSObject {
    var name: String?
    var age: Int? = nil
    
    init(withDictionary: [String: Any]) {
        name = withDictionary["name"] as! String
        age = withDictionary["age"] as! Int
        super.init()
    }
    
    override init() {
        name = "Json"
        age = 12
        super.init()
    }
    
}


let p = Person(withDictionary: [
    "name": "Eric",
    "age": 5
    ])

p.value(forKey: "name")

