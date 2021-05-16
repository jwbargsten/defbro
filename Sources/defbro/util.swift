//
//  File.swift
//  
//
//  Created by Joachim Bargsten on 16.5.21.
//

import Foundation



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

struct BrowserBundle : Codable {
  var id: String
  var name: String?
  var url: URL
  var isDefault = false
}

func getBundleName(b: Bundle) -> String? {
  let name = b.infoDictionary?["CFBundleDisplayName"] ?? b.infoDictionary?["CFBundleName"]
  return name as? String
}

func getAppURLs(url: String) -> Set<URL> {
  return Set(LSCopyApplicationURLsForURL(URL(string: url)! as CFURL, .all)?.takeRetainedValue() as? [URL] ?? [])
}

func getDefaultAppURL(url: String) -> URL? {
  return LSCopyDefaultApplicationURLForURL(URL(string: url)! as CFURL, .all, nil)?.takeRetainedValue() as URL?
}

func printBundle(b: BrowserBundle) -> Void {
  let def = b.isDefault ? "*" : " "
  let name = b.name ?? "unknown"
  print("\(def) \(b.id) (\(name ))")
}
