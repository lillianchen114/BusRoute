//
//  NetworkProtocols.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/13/21.
//

import Foundation

enum LoadingError: Error {
    case networkError
    case parseError
}

// Protocol declaration of a network request
protocol NetworkRequest: AnyObject {
    associatedtype ModelType
    func decode(_ data: Data) -> ModelType?
    func load(with completion: @escaping (ModelType?, LoadingError?) -> Void)
}

// Default implementation of the network request protocol method
extension NetworkRequest {
    // This method loads the data with given URL and after completion it decodes the raw data
    func load(_ url: URL, withCompletion completion: @escaping (ModelType?, LoadingError?) -> Void) {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: url, completionHandler: { [weak self] (data: Data?, response: URLResponse?, networkError: Error?) -> Void in
            guard let data = data,
                  let self = self else {
                completion(nil, .networkError)
                return
            }
            let decodedData = self.decode(data)
            if decodedData != nil {
                completion(decodedData, nil)
            } else {
                completion(nil, .parseError)
            }
        })
        task.resume()
    }
}

// API resource protocol declaration.
// An API resource defines where the resource is on the web by providing the the URL host address, method path and query items

protocol APIResource {
    associatedtype ModelType: Decodable
    var methodPath: String { get }
    var queryItems: Dictionary<String, String> { get }
    var hostAddress: String { get }
    func decode(_ data: Data) -> ModelType?
}

// Some default implementation of API resource protocol
extension APIResource {
    
    // A computed variable that build the API request URL from the APIResource protocol
    var url: URL {
        var components = URLComponents(string: hostAddress)!
        components.path = methodPath
        var urlQuery = [URLQueryItem]()
        for key in queryItems.keys {
            urlQuery.append(URLQueryItem(name: key, value: queryItems[key]!))
        }
        components.queryItems = urlQuery
        let url = components.url!
        return url
    }
    
    // Default impementation of protocol method that decode raw data from web to model object described in the APIResource protocol
    func decode(_ data: Data) -> ModelType? {
        let decoder = JSONDecoder()
        do {
           // process data
            let decodedData = try decoder.decode(ModelType.self, from: data)
            return decodedData
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }
        return nil
    }
}
