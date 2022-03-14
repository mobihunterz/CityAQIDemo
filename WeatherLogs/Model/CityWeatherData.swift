//
//  CityWeatherModel.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 12/03/22.
//

import Foundation
import RealmSwift

// View Model used to display Cell Data
struct CityWeatherModel: Codable {
    let name: String?
    let airQuality: Double?
    let updatedTime: Date
    let changePercentage: Double
    
    init() {
        self.name = nil
        self.airQuality = nil
        self.updatedTime = Date()
        self.changePercentage = 0
    }
    
    init(_ data: DBCityData) {
        self.name = data.name?.capitalized
        self.airQuality = data.aqi
        self.updatedTime = data.updateTimestamp
        self.changePercentage = data.changePercentage
    }
    
    init(_ name: String?, _ airQuality: Double?, updatedTime: Date = Date(), _ change: Double = 0) {
        self.name = name
        self.airQuality = airQuality
        self.updatedTime = updatedTime
        self.changePercentage = change
    }
}

extension CityWeatherModel {
    
    var airQualityString: String {
        guard let aqi = self.airQuality else {
            return ""
        }
        
        return  String(format: "%.2f", aqi)
    }
    
    var updateTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "updated " + formatter.localizedString(for: self.updatedTime, relativeTo: Date())
    }
    
}

// Model used to parse JSON Data from Websocket
struct CityWeatherData: Codable {
    let name: String?
    let airQuality: Double?
    
    enum CodingKeys: String, CodingKey {
        case name = "city"
        case airQuality = "aqi"
    }
    
    init() {
        self.name = nil
        self.airQuality = nil
    }
    
    init(name: String? = nil, airQuality: Double? = nil) {
        self.name = name
        self.airQuality = airQuality
    }
    
    init(_ data: DBCityData) {
        self.name = data.name?.capitalized
        self.airQuality = data.aqi
    }
}
