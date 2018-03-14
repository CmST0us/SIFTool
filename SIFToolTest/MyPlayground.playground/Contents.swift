//: Playground - noun: a place where people can pla
import Foundation

//let buffer = UnsafeMutablePointer<Int>.allocate(capacity: 1024)

//var bb = malloc(1024)
//let v = bb?.assumingMemoryBound(to: Int.self)
//var s = sockaddr_in()
//let sss = withUnsafePointer(to: &s) { ptr in
//    ptr.withMemoryRebound(to: sockaddr.self, capacity: 1, { pptr in
//        bind(12, pptr, socklen_t(MemoryLayout<sockaddr>.size))
//    })
//}

import Gzip
import SSZipArchive

let data = try? NSData(contentsOfFile: "/Users/cmst0us/Downloads/Bd03.png.gz") as Data
do {
    let unzip = try data?.gunzipped()
    let image = NSImage(data: unzip!)
} catch let e as GzipError {
    let k = e.kind
}


SSZipArchive.unzipFile(atPath: "/Users/cmst0us/Downloads/card_round.zip", toDestination: "/Users/cmst0us/Downloads/")
