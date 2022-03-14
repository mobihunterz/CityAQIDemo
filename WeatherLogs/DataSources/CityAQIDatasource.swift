//
//  CityAQIChartDatasource.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 14/03/22.
//

import Foundation
import Charts

/// Datasource to fetch data using `fetch` method which loads latest city aqi data
class CityAQIDatasource : NSObject {
    
    let datasource = RealmStorage()
    private var list: [CityWeatherModel] = [CityWeatherModel]()
    
    /// Fetches latest AQI for for a specific `city` and returns list of `ChartDataEntry` which can be directly used to render a chart
    func fetch(for city: CityWeatherModel?) -> [ChartDataEntry] {
        guard let cityName = city?.name,
              let updatedCityData = RealmStorage().getUpdatedCityData(for: cityName) else {
            return [ChartDataEntry]()
        }
        
        self.list.append(updatedCityData)
        return self.list.compactMap({ ChartDataEntry(x: $0.updatedTime.timeIntervalSince1970, y: $0.airQuality ?? 0) })
    }
}
