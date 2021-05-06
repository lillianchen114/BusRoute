//
//  APIRequest.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/13/21.
//

import Foundation

// API request class that takes any thing that conforms to APIResource protocol
class APIRequest<Resource: APIResource> {
    let resource: Resource
    
    init(resource: Resource) {
        self.resource = resource
    }
}

// API requests conforms to network request protocol and thus provides implementation of the protocol methods
extension APIRequest: NetworkRequest {
    
    // Decode the raw data from network to the given data type described in Resource
    func decode(_ data: Data) -> Resource.ModelType? {
        return resource.decode(data)
    }
    
    // This method load the api request which fetches data from the internet
    func load(with completion: @escaping (Resource.ModelType?, LoadingError?) -> Void) {
        load(resource.url, withCompletion: completion)
    }
}
