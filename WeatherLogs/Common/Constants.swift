//
//  Constants.swift
//  LiveSteamIOS
//
//  Created by Paresh Thakor on 24/06/21.
//

import Foundation
import UIKit

enum LSTConstants {
    
    static let Minute: TimeInterval = 1 * 60   // 1 - Minutes, 60 - Seconds
    static let Hour: TimeInterval = 1 * 60 * 60   // 1 - Hour, 60 - Minutes, 60 - Seconds
    static let Day: TimeInterval = 1 * 24 * 60 * 60   // 1 - Day, 24 - Hours, 60 - Minutes, 60 - Seconds
    
//    static let TokenInterval: TimeInterval = 10 * 60   // 2 Hours
//    static let RefreshWindow: TimeInterval = 5 * 60   // 30 - Minutes
    
    static let TokenInterval: TimeInterval = 2 * 60 * 60   // 2 Hours
    static let RefreshWindow: TimeInterval = 30 * 60   // 30 - Minutes
    
    static let ReconnectWebsocketInterval: TimeInterval = 110 * 60   // 110 Minutes
    
    static let TimeoutInverval: TimeInterval = 30   // 30 Seconds
}

enum LSTTheme {
    enum Animation {
        static let quick = 0.25
        static let navigation = 0.5
    }
    
    enum Color {
        static let BetterAQI: UIColor = .systemGreen
        static let GoodAQI: UIColor = .systemGreen.withAlphaComponent(0.7)
        static let MediumAQI: UIColor = .systemYellow
        static let PoorAQI: UIColor = .systemOrange
        static let BadAQI: UIColor = .systemRed.withAlphaComponent(0.4)
        static let SevereAQI: UIColor = .systemRed.withAlphaComponent(0.8)
        static let DangerousAQI: UIColor = .systemRed
    }
    
    enum UI {
        static let cornerRadius: CGFloat = 8.0
        static let buttonRadius: CGFloat = 8.0
        
        enum Cell {
            static let cornerRadius: CGFloat = 20.0
            static let shadowRadius: CGFloat = 12.0
            static let shadowOpacity: Float = 0.18
            
            static let shadowOffset: CGSize = CGSize(width: 0.0, height: 8.0)
        }
    }
    
    enum DateFormat {
        static let Chart_AQI_Update_Time: String = "mm:ss"
    }
}

// Notification constants for Data updates
enum LSTNotification{
    static let FETCHED_CITYAQI_DATA = "Fetched_City_AQI_Data"
    static let AQI_DATA_PAYLOAD = "AQI_Payload"
}


enum AQILevel {
    case Better
    case Good
    case Medium
    case Poor
    case Bad
    case Severe
    case Dangerous
    
    /// Checks and returns `AQILevel` category for given `airQuality` value
    static func check(for airQuality: Double) -> AQILevel {
        if airQuality >= 0 && airQuality <= 50 {
            return .Better
        } else if airQuality > 50 && airQuality <= 100 {
            return .Good
        } else if airQuality > 100 && airQuality <= 200 {
            return .Medium
        } else if airQuality > 200 && airQuality <= 300 {
            return .Poor
        } else if airQuality > 300 && airQuality <= 400 {
            return .Bad
        } else if airQuality > 400 && airQuality <= 500 {
            return .Severe
        } else {
            return .Dangerous
        }
    }
}


extension AQILevel {
    
    var color: UIColor {
        
        switch self {
        case .Better:
            return LSTTheme.Color.BetterAQI
        case .Good:
            return LSTTheme.Color.GoodAQI
        case .Medium:
            return LSTTheme.Color.MediumAQI
        case .Poor:
            return LSTTheme.Color.PoorAQI
        case .Bad:
            return LSTTheme.Color.BadAQI
        case .Severe:
            return LSTTheme.Color.SevereAQI
        case .Dangerous:
            return LSTTheme.Color.DangerousAQI
        }
    }
    
}
