//
//  LocalJSONResponseManager.swift
//  FlickrEyeTests
//
//  Created by Marcello Mirsal on 27/01/2021.
//

import Foundation
// a manager that allows Network Services to wirte json reponse to a local file which can be used as FAKE network request responses
class LocalJSONResponseManager {
    
    static let shared: LocalJSONResponseManager = .init()
    private let filename: String = "localResponse.json"
    
    private init() {
    }
    
    func write(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else { fatalError() }
        let fileURL = localJSONFileURL()
        try! jsonData.write(to: fileURL)
    }
    
    func localJSONFileURL() -> URL {
        guard let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { fatalError() }
        return documentsDirectory.appendingPathComponent(filename)
    }
    
    func deleteResponseFile() {
        try? FileManager.default.removeItem(at: localJSONFileURL())
    }
}
