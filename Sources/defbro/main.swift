//
//  Created by Joachim Bargsten on 15.5.21.
//

import Foundation
import ApplicationServices
import ArgumentParser


func main1(bundleId: String?, isJson: Bool = false) throws -> Void {
    var standardError = FileHandle.standardError
    
    let appUrlsHttps = getAppURLs(url: "https:")
    let appUrlsHttp = getAppURLs(url: "http:")
    
    let defaultBundleURL = getDefaultAppURL(url: "https:")
    
    let bundles = Array(appUrlsHttps.union(appUrlsHttp))
        .map( {Bundle(url: $0)!})
        .filter( {(b: Bundle) -> Bool in b.bundleIdentifier != nil })
        .map( { BrowserBundle(
            id: $0.bundleIdentifier!,
            name: getBundleName(b: $0),
            url: $0.bundleURL,
            isDefault: ($0.bundleURL == defaultBundleURL)
        )
        })
        .sorted(by: { $0.id > $1.id })
    
    
    if(isJson) {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let jsonResultData = try String(data: jsonEncoder.encode(bundles), encoding: String.Encoding.utf8)
        print(jsonResultData!)
    } else {
        for b in bundles {
            printBundle(b: b)
        }
    }
    
    if let id = bundleId {
        let selectedBundle = bundles.first(where: { $0.id == id })
        
        if let b = selectedBundle {
            if b.isDefault {
                print("browser \(b.id) is already default", to:&standardError)
            } else {
                print("setting default browser to \(b.id)", to:&standardError)
                LSSetDefaultHandlerForURLScheme("http" as CFString, b.id as CFString)
                //LSSetDefaultHandlerForURLScheme("https" as CFString, b.id as CFString)
            }
        }
    }
}

struct Command: ParsableCommand {
    @Flag(help: "Write browser info in JSON")
    var json = false
    
    @Argument(help: "The bundle ID of the browser, e.g. com.google.Chrome")
    var bundleId: String?
    
    mutating func run() throws {
        try main1(bundleId: bundleId, isJson: json)
    }
}

Command.main()
