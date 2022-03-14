//
//  CityWeatherDetailsViewController.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 13/03/22.
//

import UIKit
import Charts

/// Graph screen controller loading AQI graph for a selected city
class CityWeatherDetailsViewController: UIViewController {

    @IBOutlet weak var chartView: AQIGraphView!
    
    @IBOutlet weak var lblAirQuality: UILabel!
    @IBOutlet weak var iconChangeIndicator: UIImageView!
    
    /// City for which AQI data needs to be fetched and showed on graph
    var selectedCity: CityWeatherModel?
    /// Datasource to fetch data loaded directly into Chart
    private var datasource: CityAQIDatasource?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let theCity = self.selectedCity {
            self.title = (theCity.name ?? "") + " AQI Updates"
            self.updateUI(for: theCity)
        }
        
        self.datasource = CityAQIDatasource()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedData(_:)), name: NSNotification.Name(rawValue:LSTNotification.FETCHED_CITYAQI_DATA), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue:LSTNotification.FETCHED_CITYAQI_DATA),
            object: nil)
    }

    // Handles websocket data updates
    @objc private func receivedData(_ notification: Notification) {
        print(notification)
        
        guard let notificationItem = notification.userInfo?[LSTNotification.AQI_DATA_PAYLOAD] as? [CityWeatherData] else {
            return
        }
        
        // Push specific data into DB
        let realmDb = RealmStorage()
        realmDb.saveCityList(notificationItem)
        self.refresh()
        
        guard let theCityName = self.selectedCity?.name,
              let cityAQI = realmDb.getUpdatedCityData(for: theCityName) else {
                  return
              }
        
        // Update local UI to show latest AQI value
        self.updateUI(for: cityAQI)
    }
    
    /// Refresh chart using datasource's `fetch` method
    private func refresh() {
        guard let datasource = datasource,
              let city = self.selectedCity else {
            return
        }
        
        let list = datasource.fetch(for: city)
        self.chartView.updateGraph(with: list)
    }
    
    private func updateUI(for cityAQI: CityWeatherModel) {
        self.lblAirQuality.text = cityAQI.airQualityString
        
        let isImproved = cityAQI.changePercentage > 0
        self.iconChangeIndicator.image = isImproved ? UIImage(systemName: "arrowtriangle.up.fill") : UIImage(systemName: "arrowtriangle.down.fill")
        self.iconChangeIndicator.tintColor = isImproved ? .systemGreen : .systemRed
        
        self.changeLabel(for: cityAQI.airQuality)
    }

    private func changeLabel(for airQuality: Double?) {
        guard let airQuality = airQuality else {
            self.lblAirQuality?.textColor = .label
            return
        }
        let aqiLevel = AQILevel.check(for: airQuality)
        self.lblAirQuality?.textColor = aqiLevel.color
    }
    
}
