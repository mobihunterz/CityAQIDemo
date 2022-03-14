//
//  AppDelegate.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 12/03/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Data Fetcher to fetch data from websocket
    let db = RealtimeDataFetcher<CityWeatherData>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        DispatchQueue.global(qos: .utility).async {
            
            self.db.fetch { response in
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:LSTNotification.FETCHED_CITYAQI_DATA), object: nil, userInfo: [LSTNotification.AQI_DATA_PAYLOAD: response])
                
                print(">>>>> Received Weather data >>>>>\n", response)
                
            } failureHandler: {
                print("Failure realtime data fetches")
            }
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

