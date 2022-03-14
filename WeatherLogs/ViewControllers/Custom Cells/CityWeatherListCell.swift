//
//  CityWeatherListCell.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 12/03/22.
//

import UIKit

/// Cell View to to display city - AQI listing
class CityWeatherListCell: UICollectionViewCell {

    private let upArrow = UIImage(systemName: "arrowtriangle.up.fill")
    private let downArrow = UIImage(systemName: "arrowtriangle.down.fill")
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAirQuality: UILabel!
    @IBOutlet weak var lblUpdateTime: UILabel!
    @IBOutlet weak var iconChangeIndicator: UIImageView!
    
    private var content: CityWeatherModel? {
        didSet {
            guard let content = self.content else {
                return
            }

            UIView.transition(with: self.lblAirQuality,
                              duration: LSTTheme.Animation.quick,
                              options: .curveEaseIn) {
                self.lblAirQuality.text = content.airQualityString
            }
            
            self.lblTitle?.text = content.name
            
            let isImproved = content.changePercentage > 0
            self.iconChangeIndicator.tintColor = isImproved ? .systemGreen : .systemRed
            
            let newIconImage = isImproved ? upArrow : downArrow
            
            if let theImage = self.iconChangeIndicator.image,
               theImage != newIconImage {
                
                self.iconChangeIndicator.image = newIconImage
            }
            
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            self.lblUpdateTime.text = content.updateTimeString
            
            self.changeLabel(for: content.airQuality)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    /// Render data and update Cell View
    func setContent(_ content: CityWeatherModel) {
        self.content = content
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
