//
//  Network.swift
//  GlovoTest
//
//  Created by Manuel Vrhovac on 21/06/2018.
//  Copyright © 2018 Manuel Vrhovac. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias ResponseBlock =  (_ response: JSON, _ httpResponse: HTTPURLResponse?, _ error: Error?)->()

func mainThread(closure:@escaping ()->()){
    DispatchQueue.main.async {
        closure()
    }
}

class Network {
    
    enum Method: String {
        case get = "GET"
        case delete = "DELETE"
        case post = "POST"
    }
    
    static let shared = Network()
    var endpoint = "http://192.168.0.160:3000"
    
    
    /// Simplified HTTP request
    
    func request(path: String, json: JSON? = nil, method: Method = .get, result: @escaping ResponseBlock){
        self.request(
            url: URL(string: self.endpoint+path)!,
            header: [:],
            data: json?.rawString()?.data(using: String.Encoding.utf8),
            method: method,
            result: result
        )
    }
    
    
    /// Advanced HTTP Requests
    
    func request(url: URL, header: [String:String], data: Data?, method: Method, timeout: TimeInterval = 3.0, result: @escaping ResponseBlock) {
        var req = URLRequest(url: url)
        header.forEach{ req.addValue($0.value, forHTTPHeaderField: $0.key) }
        req.httpMethod = method.rawValue
        req.httpBody = data
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 2.0
        sessionConfig.timeoutIntervalForResource = 3.0
        let session = URLSession(configuration: sessionConfig)
        
        session.dataTask(with: req, completionHandler: { data, response, error in
            mainThread {
                let httpResponse = response as? HTTPURLResponse
                if error != nil {
                    print(error!.localizedDescription)
                    result(JSON.null, httpResponse, error)
                }
                else {
                    let receivedString = String(data: data!, encoding: String.Encoding.utf8)!
                    let json = JSON.init(parseJSON: receivedString)
                    return result(json, httpResponse, error)
                }
            }
        }).resume()
    }
    
    private init(){
        
    }
    
}
