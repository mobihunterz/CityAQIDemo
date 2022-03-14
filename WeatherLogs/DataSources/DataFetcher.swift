//
//  LocalDatasource.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 12/03/22.
//

import Foundation

///  Base `DataFetcher` class which implements `fetch` method to fetch new data from a specific source
class DataFetcher<T: Codable>: NSObject {
    
    func fetch(_ successHandler: @escaping (([T]?) -> ()), failureHandler: @escaping (() -> ())) {
        print("Required implementation")
    }
}

/// implements `fetch` method to fetch new data from a local file for mock results
class FileDataFetcher<T: Codable>: DataFetcher<T> {
    
    override func fetch(_ successHandler: @escaping (([T]?) -> ()), failureHandler: @escaping (() -> ())) {
        
        let bundle = Bundle(for: FileDataFetcher.classForCoder())
        
        do {
            guard let url = bundle.url(forResource: "CityWeatherData", withExtension: "json") else {
                //return [CityWeatherData]()
                // Failure with error
                failureHandler()
                return
            }
            
            let decoder = JSONDecoder()
            let jsonData = try Data(contentsOf: url)
            let item = try decoder.decode([T].self, from: jsonData)
            
            successHandler(item)
        } catch let error {
            print(error)
            failureHandler()
            return
        }
    }
    
}

/// DataFetcher implementing `fetch` method to fetch new data from local Database
class DBDataFetcher<T: Codable>: DataFetcher<T> {
    
    override func fetch(_ successHandler: @escaping (([T]?) -> ()), failureHandler: @escaping (() -> ())) {
        let list = RealmStorage().getCityList()
        
        if let new = list as? [T] {
            successHandler(new)
        } else {
            print("Error with some failure")
            failureHandler()
        }
    }
}

/// DataFetcher which implements `fetch` method to fetch new data from Websocket updates
class RealtimeDataFetcher<T: Codable>: DataFetcher<T> {
    
    internal let websocket = GVOWebsocketHandler<T>()
    
    override func fetch(_ successHandler: @escaping (([T]?) -> ()), failureHandler: @escaping (() -> ())) {
        
        websocket.didConnectHandler = {
            print("***** Connection setup...")
        }
        
        websocket.didDisconnectHandler = {
            print("Disconnected websocket")
        }
        
        websocket.didResponseHandler = { response in
            successHandler(response)
        }
        
        websocket.establishConnection()
    }
    
}
