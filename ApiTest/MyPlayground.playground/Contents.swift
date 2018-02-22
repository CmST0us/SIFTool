//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"
let startIndex = str.index(str.startIndex, offsetBy: 1)
let endIndex = str.endIndex
str[startIndex ..< endIndex]

