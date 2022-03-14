//
//  RealmStorage.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 13/03/22.
//

import Foundation
import RealmSwift

// Model used to update DB
class DBCityData: Object {
    //@objc dynamic var id = 0
    @objc dynamic var name: String?
    @objc dynamic var aqi: Double = 0
    @objc dynamic var updateTimestamp: Date = Date()
    @objc dynamic var changePercentage: Double = 0
    
    override static func primaryKey() -> String? {
        //return "id"
        return "name"
    }
    
    required convenience init(_ cityData: CityWeatherData) {
        self.init()
        
        //self.id = DBCityData.getId()
        self.name = cityData.name?.lowercased()
        self.aqi = cityData.airQuality ?? 0
    }
}

/// Realm DB class which handles all db related operations, i.e. fetching and updating DB records
class RealmStorage {
    
    private let store: Realm
    
    init() {
        let configuration = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock:
                { (migration, oldSchemaVersion) in
                    switch oldSchemaVersion {
                    case 1: break
                    default: break
                        // Nothing to do!
                        // Realm will automatically detect new properties and removed properties
                        // And will update the schema on disk automatically
                    }
                })
        
        store = try! Realm(configuration: configuration)
    }
    
    init(_ configuration: Realm.Configuration) {
        store = try! Realm(configuration: configuration)
    }
    
    /// City list for Cell display
    func getCityList() -> [CityWeatherModel]? {
        return self.getCityListObjects().map({ CityWeatherModel($0) })
    }
    
    /// Fetch particular city data filtered by `cityName` with latest AQI
    func getUpdatedCityData(for cityName: String) -> CityWeatherModel? {
        guard let city = self.store.object(ofType: DBCityData.self, forPrimaryKey: cityName.lowercased()) else {
            return nil
        }
        return CityWeatherModel(city)
    }
    
    /// City list db objects
    func getCityListObjects() -> Results<DBCityData> {
        return self.store.objects(DBCityData.self)
    }
    
    /// Updated DB by saving data passed as `list`
    func saveCityList(_ list: [CityWeatherData]?) {
        guard let list = list else {
            print("No item to save")
            return
        }
        
        list.forEach { item in
            
            let new = DBCityData(item)
            let existing = self.store.object(ofType: DBCityData.self, forPrimaryKey: new.name)
            
            new.changePercentage = (((existing?.aqi ?? 0) - new.aqi) * 100) / (existing?.aqi ?? 1.0)
            
            if existing?.aqi ?? 0 != new.aqi {
                
                try! store.write {
                    print("REALM Start Add ****")
                    store.add(new, update: .modified)
                    print("REALM Add ****")
                }
            } else {
                print("REALM Not an update...")
            }
        }
    }
}
