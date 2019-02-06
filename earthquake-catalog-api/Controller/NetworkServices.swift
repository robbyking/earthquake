//
//  NetworkServices.swift
//  earthquake-catalog-api
//
//  Created by Robby King on 2/2/19.
//  Copyright © 2019 Robby King. All rights reserved.
//

import Foundation

class NetworkServices {
    
    func makeNetworkRequest(apiURL: URL, completionHandler: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: apiURL) { (data, response, error) in
            if error != nil {
                print(error.debugDescription)
            }
            guard let data = data else {
                completionHandler(nil)
                return
            }            
            completionHandler(data)
        }.resume()
    }
}
