//
//  main.swift
//  defaultbrowser
//
//  Created by Joachim Bargsten on 15.5.21.
//

import Foundation
import ApplicationServices

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension FileHandle : TextOutputStream {
  public func write(_ string: String) {
    guard let data = string.data(using: .utf8) else { return }
    self.write(data)
  }
}


//public struct StandardErrorOutputStream: TextOutputStream {
//    public mutating func write(_ string: String) { fputs(string, stderr) }
//}
//
//public var errStream = StandardErrorOutputStream()

var standardError = FileHandle.standardError



func getBundleName(b: Bundle) -> String? {
    let name = b.infoDictionary?["CFBundleDisplayName"] ?? b.infoDictionary?["CFBundleName"]
    return name as? String
}

func getAppURLs(s: String) -> Set<URL> {
    return Set(LSCopyApplicationURLsForURL(URL(string: s)! as CFURL, .all)?.takeRetainedValue() as? [URL] ?? [])
}

let appUrlsHttps = getAppURLs(s: "https:")
let appUrlsHttp = getAppURLs(s: "http:")

let defaultBundleURL = LSCopyDefaultApplicationURLForURL(URL(string: "https:")! as CFURL, .all, nil)?.takeRetainedValue() as URL?

let bundles = Array(appUrlsHttps.union(appUrlsHttp))
  
    .map( {
        
        let u = Bundle(url: $0)!
        //print(u.bundleIdentifier!)
        //print(u.bundleURL)
        let isDefault = defaultBundleURL == u.bundleURL
        
      return (bundle: u, isDefault: isDefault)
    })
  .filter( {(b: (bundle: Bundle, isDefault: Bool)) -> Bool in b.bundle.bundleIdentifier != nil })
  .sorted(by: { $0.bundle.bundleIdentifier! > $1.bundle.bundleIdentifier! })

func printBundle(b: (bundle: Bundle, isDefault: Bool)) -> Void {
  let name = getBundleName(b: b.bundle)
  let def = b.isDefault ? "*" : " "
  let id = b.bundle.bundleIdentifier!
  print("\(def) \(id) (\(name!))")
}

// https://github.com/apple/swift-argument-parser
for b in bundles {
  printBundle(b: b)
}

if let arg = CommandLine.arguments[safe: 1] {
  let selectedBundle = bundles.first(where: { $0.bundle.bundleIdentifier == arg })
  
  if let b = selectedBundle {
    let bundle = b.bundle
    print("setting default browser to \(bundle.bundleIdentifier!)", to:&standardError)
    LSSetDefaultHandlerForURLScheme("http" as CFString, bundle.bundleIdentifier! as CFString)
    LSSetDefaultHandlerForURLScheme("https" as CFString, bundle.bundleIdentifier! as CFString)
  }
}


//if let blah = bundles.first?.0.bundleIdentifier {

//}
//for appUrl in Set(appUrlsHttps + appUrlsHttp) {
//    let u = Bundle(url: appUrl)!.infoDictionary
//    let k = u?["CFBundleDisplayName"] ?? u?["CFBundleName"]
//    print(k!)
//
//}

//print("hello2")
//
// https://stackoverflow.com/questions/25195565/how-do-you-unwrap-swift-optionals
