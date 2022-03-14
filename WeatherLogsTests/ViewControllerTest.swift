//
//  ViewControllerTest.swift
//  WeatherLogsTests
//
//  Created by Paresh Thakor on 14/03/22.
//

import XCTest
@testable import WeatherLogs

class ViewControllerTest: XCTestCase {

    private var sut: ViewController!
    
    private func makeSUT() throws -> ViewController {
        //let bundle = Bundle(for: self.classForCoder())
        
        guard let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            return try XCTUnwrap(sut, "Unable to cast Event Details controller")
        }
        sut = controller
        
        return try XCTUnwrap(sut, "Unable to cast Event Details controller")
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
    
    func testListingConfiguration() {
        sut.loadViewIfNeeded()
        
        //XCTAssertNotNil(sut.listingCV.delegate, "CollectionList delegate should not be nil")
        XCTAssertNotNil(sut.listingCV.dataSource, "CollectionList datasource should not be nil")
        
    }

    func testListingInitialState() throws {
        sut.dataFetcher = nil
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, "Cities", "Title is not matching")
        XCTAssertEqual(sut.listingCV.numberOfSections, 1, "Listing view should have only 1 section which is default")
        XCTAssertEqual(sut.listingCV.numberOfItems(inSection: 0), 0, "Listing view should not have any item")
        sut.verifyNoDataView()
    }
    
    func testListingWithData() throws {
        let fetcher = MockDataFetcher<CityWeatherModel>()
        sut.dataFetcher = fetcher
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, "Cities", "Title is not matching")
        XCTAssertEqual(sut.listingCV.numberOfSections, 1, "Listing view should have only 1 section which is default")
        //XCTAssertEqual(sut.listingCV.numberOfItems(inSection: 0), fetcher.totalItems(), "Listing view should not have any item")
        sut.verifyListingView()
        sut.verifyMockFetcherList(for: fetcher)
    }

}

private extension ViewController {
    
    func verifyNoDataView() {
        
        XCTAssertFalse(self.noDataView.isHidden, "No-Data view should not be hidden")
        XCTAssertTrue(self.listingCV.isHidden, "List view view should be hidden")

        XCTAssertEqual(self.lblNoDataMessage.text, "No AQI data available", "No data message not matching.")
    }
    
    func verifyListingView() {
        XCTAssertTrue(self.noDataView.isHidden, "No-Data view should be hidden")
        XCTAssertFalse(self.listingCV.isHidden, "List view view should not be hidden")
    }
    
    func verifyMockFetcherList(for fetcher: MockDataFetcher<CityWeatherModel>) {
        let items = self.listingCV.numberOfItems(inSection: 0)
        XCTAssertEqual(items, fetcher.totalItems(), "Listing view should not have any item")
        
        for index in 0...items {
            if let cell = self.listingCV.cellForItem(at: IndexPath(item: index, section: 0)) as? CityWeatherListCell {
                cell.verifyContentUI(at: index, for: fetcher)
            }
        }
    }
}

private extension CityWeatherListCell {
    
    func verifyContentUI(at index: Int, for fetcher: MockDataFetcher<CityWeatherModel>) {
        
        guard let item = fetcher.item(for: index) else {
            XCTAssert(false, "Should find an item")
            return
        }
        
        XCTAssertEqual(self.lblTitle.text?.lowercased(), item.name, "Cell title not matching")
        XCTAssertEqual(self.lblAirQuality.text, item.airQualityString, "Cell AQI not matching")
        XCTAssertEqual(self.lblUpdateTime.text?.lowercased(), item.updateTimeString, "Cell Update info not matching")
        
        let aqiLevel = AQILevel.check(for: item.airQuality ?? 0)
        let iconImage = item.changePercentage > 0 ? UIImage(systemName: "arrowtriangle.up.fill") : UIImage(systemName: "arrowtriangle.down.fill")
        let tintColor = item.changePercentage > 0 ? UIColor.systemGreen : UIColor.systemRed
        XCTAssertEqual(self.iconChangeIndicator.image, iconImage, "Cell change image not matching")
        XCTAssertEqual(self.iconChangeIndicator.tintColor, tintColor, "Cell change image tintColor not matching")
        XCTAssertEqual(self.lblAirQuality.textColor, aqiLevel.color, "Cell change image tintColor not matching")
    }
}

private class MockDataFetcher<T: Codable>: DataFetcher<T> {
    private let items = [
        CityWeatherModel("Mumbai", 10.12889, updatedTime: Date().addingTimeInterval(-10), -1.5),
        CityWeatherModel("Chennai", 5.620089, updatedTime: Date().addingTimeInterval(-2), 1.0),
        CityWeatherModel("Ahmedabad", 12.3467876, updatedTime: Date().addingTimeInterval(0), 0.5),
        CityWeatherModel("Anand", 11, updatedTime: Date().addingTimeInterval(-1), -10.5),
        CityWeatherModel("Pune", 11, updatedTime: Date().addingTimeInterval(-1*60*60), 10.5),
        CityWeatherModel("Kochi", 1.223445, updatedTime: Date().addingTimeInterval(-3*60*60), 10.5),
        CityWeatherModel("Lonavala", 0.334545, updatedTime: Date().addingTimeInterval(-5*24*60*60), -1.5)
    ]
    
    override func fetch(_ successHandler: @escaping (([T]?) -> ()), failureHandler: @escaping (() -> ())) {
        
        if let new = items as? [T] {
            successHandler(new)
        } else {
            print("Error with some failure")
            failureHandler()
        }
    }
    
    func totalItems() -> Int {
        return items.count
    }
    
    func item(for index: Int = 0) -> T? {
        if index < items.count,
            let item = items[index] as? T {
            
            return item
        }
        
        return nil
    }
    
//    func verifyList(for listingCV: ) {
//        XCTAssertEqual(sut.listingCV.numberOfItems(inSection: 0), fetcher.totalItems(), "Listing view should not have any item")
//    }
}
