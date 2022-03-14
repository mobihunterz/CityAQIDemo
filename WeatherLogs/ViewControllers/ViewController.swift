//
//  ViewController.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 12/03/22.
//

import UIKit

/// Main City-AQI Listing screen controller
class ViewController: UIViewController {

    typealias DataType = CityWeatherModel
    typealias CellType = CityWeatherListCell
    
    @IBOutlet weak var lblNoDataMessage: UILabel! {
        didSet {
            lblNoDataMessage.textColor = .black
            lblNoDataMessage.alpha = 0.5
        }
    }
    
    @IBOutlet weak var noDataView: UIStackView! {
        didSet {
            noDataView.isHidden = false
            //noDataView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.isHidden = true
        }
    }
    
    @IBOutlet weak var listingCV: UICollectionView! {
        didSet {
            self.listingCV.isHidden = true
            self.listingCV.contentInset = UIEdgeInsets(top: 26.0, left: 0, bottom: 26.0, right: 0)
            
            let size = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0), heightDimension: NSCollectionLayoutDimension.estimated(100.0))
            
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 14.0, bottom: 0.0, trailing: 14.0)
            section.interGroupSpacing = 14
            
            let layout = UICollectionViewCompositionalLayout(section: section)
            listingCV.collectionViewLayout = layout
        }
    }
    
    var dataFetcher: DataFetcher? = DBDataFetcher<DataType>()
    /// Datasource for the Listing which shows data fetched from `DBDataFetcher`
    var datasource: CityAQIListingDatasource<DataType, CellType>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cities"
        self.lblNoDataMessage.text = "No AQI data available"
        
        //let dataFetcher = DBDataFetcher<DataType>()
        self.datasource = CityAQIListingDatasource<DataType, CellType>(
            dataFetcher: self.dataFetcher,
            for: self.listingCV,
            configurationHandler: configureCell(cell:item:indexPath:),
            selectionHandler: selectedCell(cell:item:indexPath:),
            fetchCompletionHandler: fetchCompletionHandler(list:))

        NotificationCenter.default.addObserver(self, selector: #selector(receivedData(_:)), name: NSNotification.Name(rawValue:LSTNotification.FETCHED_CITYAQI_DATA), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue:LSTNotification.FETCHED_CITYAQI_DATA),
            object: nil)
    }
    
    private func configureCell(cell: CellType, item: DataType, indexPath: IndexPath) -> Void {
        cell.setContent(item)
    }
    
    private func selectedCell(cell: CellType, item: DataType, indexPath: IndexPath) {
        self.navigateToDetails(for: item)
    }
    
    private func fetchCompletionHandler(list: [DataType]?) {
        if (list?.count ?? 0) > 0 {
            self.listingCV.isHidden = false
            self.noDataView.isHidden = true
            self.listingCV.reloadData()
        } else {
            self.listingCV.isHidden = true
            self.noDataView.isHidden = false
        }
    }
    
    /// Jump to AQI Graph screen
    private func navigateToDetails(for selectedCity: DataType) {
        guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CityWeatherDetailsViewController") as? CityWeatherDetailsViewController else {
            return
        }
        vc.selectedCity = selectedCity
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Handle new data from websocket updates
    @objc private func receivedData(_ notification: Notification) {
        print(notification)
        
        guard let notificationItem = notification.userInfo?[LSTNotification.AQI_DATA_PAYLOAD] as? [CityWeatherData] else {
            return
        }
        
        // Save these new data from websocket into DB
        let realmDb = RealmStorage()
        realmDb.saveCityList(notificationItem)
        self.datasource?.refresh()
    }
    
    private func toggleIndicatorView(_ isInProgress: Bool = false) {
        if isInProgress {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }

}
