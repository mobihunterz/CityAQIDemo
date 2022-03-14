//
//  CityAQIListingDatasource.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 13/03/22.
//

import Foundation
import UIKit

/**
 Shared datasource for listing screens  which will be displayed into `UICollectionview`.
 
 This datasource is designed as a primary source for listing screens,
 - City AQI Levels
 
 This datasource depends on `DataFetcher` for data fetching and *generic* `UICollectionViewCell`. This **Cell** is used to display data of listing screen.
 
 This datasource can be used for multiple listing screens.
 
 This datasource utilises `DataFetcher`  which handles data fetching activities.
 */
class CityAQIListingDatasource<T: Codable, Cell: UICollectionViewCell> : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    typealias CellConfigurationHandler = ((Cell, T, IndexPath) -> Void)
    typealias CellSelectionHandler = ((Cell, T, IndexPath) -> Void)
    typealias CompletedDataFetch = (([T]?) -> Void)
    typealias FailedDataFetch = (() -> Void)
    
    /// DataFetcher is used to fetch data from a specific source
    let listingModel: DataFetcher<T>?
    
    /// Main data which is fetched by `listingModel`
    private var list: [T]?
    
    /// Main View where data loaded from `DataFetcher` is being displayed
    let listView: UICollectionView?
    
    // MARK: Handlers for main Controller
    /// Block to configure data for a `UICollectionViewCell`
    let configureCell: CellConfigurationHandler?
    
    /// Block to perform a cell selection for `UICollectionViewCell`
    let selectCell: CellSelectionHandler?
    
    /// Completion handler which gets called when data fetch is successful
    let fetchCompletionHandler: CompletedDataFetch?
    
    /// Failure handler which gets called when data fetch is failed
    let fetchFailureHandler: FailedDataFetch?
    
    init(dataFetcher: DataFetcher<T>?, for listView: UICollectionView,
         configurationHandler: @escaping CellConfigurationHandler,
         selectionHandler: CellSelectionHandler? = nil,
         fetchCompletionHandler: CompletedDataFetch? = nil,
         fetchFailureHandler: FailedDataFetch? = nil) {
        
        if let userCell = Cell.loadFromNib() {
            listView.register(userCell, forCellWithReuseIdentifier: Cell.reusableIndentifer())
        }
        
        self.configureCell = configurationHandler
        self.selectCell = selectionHandler
        
        self.fetchCompletionHandler = fetchCompletionHandler
        self.fetchFailureHandler = fetchFailureHandler
        
        self.listingModel = dataFetcher
        self.listView = listView
        
        super.init()
        
        self.listView?.dataSource = self
        self.listView?.delegate = self
        
        self.fetchData()
    }
    
    /// Fetches data using `DataFetcher` and reloads Listing view and makes a completion callback or failure if any error occurs
    private func fetchData() {
        self.listingModel?.fetch({ [weak self] list in
            guard let self = self else {
                return
            }
            
            self.list = list
            self.listView?.reloadData()
            self.fetchCompletionHandler?(list)
            
        }, failureHandler: { [weak self] in
            print("Something went wrong >>>>> Show error")
            self?.fetchFailureHandler?()
        })
    }
    
    /// Refresh the datasource by fetching updates from `DataFetcher`
    func refresh() {
        self.fetchData()
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.list?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let list = self.list else {
            return Cell()
        }
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reusableIndentifer(), for: indexPath) as? Cell {
            
            if let configure = self.configureCell, indexPath.row < list.count {
                configure(cell, list[indexPath.row], indexPath)
            }
            
            return cell
        }
        
        return Cell()
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let list = self.list else {
            return
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? Cell else {
            return
        }
        
        if let selectCell = selectCell {
            selectCell(cell, list[indexPath.row], indexPath)
        }
    }
}
