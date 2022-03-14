//
//  RealmStorageTest.swift
//  WeatherLogsTests
//
//  Created by Paresh Thakor on 14/03/22.
//

import XCTest
import RealmSwift
@testable import WeatherLogs

class RealmStorageTest: XCTestCase {

    private var sut: RealmStorage!
    
    private func makeSUT() throws -> RealmStorage {
        var config = Realm.Configuration.defaultConfiguration
        config.inMemoryIdentifier = self.name
        
        return RealmStorage(config)
    }
    
    override func setUp() {
        super.setUp()
        
        sut = try? self.makeSUT()
        
        XCTAssertNotNil(sut, "SUT should not be nil")
    }

    override func tearDown() {
        super.tearDown()
        
        sut = nil
    }

    func testInitialCitiesList() throws {
        XCTAssertEqual(sut.getCityList()?.count, 0, "Cities list should be 0")
    }
    
    func testSavedCitiesList() throws {
        let cities = MockDataFetcher<CityWeatherData>()
        cities.fetch { [weak self] list in
            guard let self = self else {
                return
            }
            self.sut.saveCityList(list)
            
            let newList = self.sut.getCityList()
            XCTAssertEqual(newList?.count, list?.count, "All records need to be saved")
            
        } failureHandler: {
            XCTAssert(false, "Failure should not be encountered")
        }
    }
    
    func testUpdateDegradeAQI() throws {
        let cities = MockUpdateDegradeDataFetcher<CityWeatherData>()
        cities.fetch { [weak self] list in
            guard let self = self else {
                return
            }
            self.sut.saveCityList(list)
            
            let newList = self.sut.getCityList()
            XCTAssertEqual(newList?.count, 1, "All records need to be saved")
            
            guard let theCityData = newList?.first else {
                XCTAssert(false, "Need to have a city data")
                return
            }
            
            cities.validateUpdatedData(for: theCityData)
            
        } failureHandler: {
            XCTAssert(false, "Failure should not be encountered")
        }
    }
    
    func testUpdateImproveAQI() throws {
        let cities = MockUpdateImproveDataFetcher<CityWeatherData>()
        cities.fetch { [weak self] list in
            guard let self = self else {
                return
            }
            self.sut.saveCityList(list)
            
            let newList = self.sut.getCityList()
            XCTAssertEqual(newList?.count, 1, "All records need to be saved")
            
            guard let theCityData = newList?.first else {
                XCTAssert(false, "Need to have a city data")
                return
            }
            
            cities.validateUpdatedData(for: theCityData)
            
        } failureHandler: {
            XCTAssert(false, "Failure should not be encountered")
        }
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

private class MockDataFetcher<T: Codable>: DataFetcher<T> {
    private let items = [
        CityWeatherData(name: "Mumbai", airQuality: 10.12889),
        CityWeatherData(name: "Chennai", airQuality: 5.620089)
    ]
    
    override func fetch(_ successHandler: @escaping (([T]?) -> ()), failureHandler: @escaping (() -> ())) {
        
        if let new = items as? [T] {
            successHandler(new)
        } else {
            print("Error with some failure")
            failureHandler()
        }
    }
}


private class MockUpdateDegradeDataFetcher<T: Codable>: DataFetcher<T> {
    private let items = [
        CityWeatherData(name: "Mumbai", airQuality: 10.12889),
        CityWeatherData(name: "Mumbai", airQuality: 15.620089),
        CityWeatherData(name: "Mumbai", airQuality: 25.620089),
        CityWeatherData(name: "Mumbai", airQuality: 30)
    ]
    
    override func fetch(_ successHandler: @escaping (([T]?) -> ()), failureHandler: @escaping (() -> ())) {
        
        if let new = items as? [T] {
            successHandler(new)
        } else {
            print("Error with some failure")
            failureHandler()
        }
    }
    
    func validateUpdatedData(for updatedData: CityWeatherModel) {
        
        guard let lastData = items.last else {
            XCTAssert(false, "Need to have a city data")
            return
        }
        
        XCTAssertEqual(updatedData.name?.lowercased(), lastData.name?.lowercased(), "Name does not match with final update")
        XCTAssertEqual(updatedData.airQuality, lastData.airQuality, "Name does not match with final update")
        XCTAssertLessThan(updatedData.changePercentage, 0, "Change percent not validated")
    }
}


private class MockUpdateImproveDataFetcher<T: Codable>: DataFetcher<T> {
    private let items = [
        CityWeatherData(name: "Delhi", airQuality: 250.12889),
        CityWeatherData(name: "Delhi", airQuality: 280.620089),
        CityWeatherData(name: "Delhi", airQuality: 230.620089),
        CityWeatherData(name: "Delhi", airQuality: 180)
    ]
    
    override func fetch(_ successHandler: @escaping (([T]?) -> ()), failureHandler: @escaping (() -> ())) {
        
        if let new = items as? [T] {
            successHandler(new)
        } else {
            print("Error with some failure")
            failureHandler()
        }
    }
    
    func validateUpdatedData(for updatedData: CityWeatherModel) {
        
        guard let lastData = items.last else {
            XCTAssert(false, "Need to have a city data")
            return
        }
        
        XCTAssertEqual(updatedData.name?.lowercased(), lastData.name?.lowercased(), "Name does not match with final update")
        XCTAssertEqual(updatedData.airQuality, lastData.airQuality, "Name does not match with final update")
        XCTAssertGreaterThan(updatedData.changePercentage, 0, "Change percent not validated")
    }
}
