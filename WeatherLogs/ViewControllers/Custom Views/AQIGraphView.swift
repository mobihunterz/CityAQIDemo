//
//  AQIGraphView.swift
//  WeatherLogs
//
//  Created by Paresh Thakor on 14/03/22.
//

import UIKit
import Charts

/// Chart view to show line graph for specific values provided into `updateGraph`
class AQIGraphView: UIView {
    
    // MARK: - UIView Setup
    
    var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()

        // use bounds not frame or it'll be offset
        view.frame = bounds

        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        return AQIGraphView.loadFromNib()?.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        xibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        xibSetup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        //setup your view with the settings
        xibSetup()
    }
    
    @IBOutlet weak var chartView: LineChartView! {
        didSet {
            chartView.animate(xAxisDuration: 2.0)
            chartView.animate(yAxisDuration: 2.0)
            
            let yAxis = chartView.leftAxis
            yAxis.labelCount = 3
            yAxis.decimals = 0
            yAxis.drawLabelsEnabled = false
            
            let xAxis = chartView.xAxis
            xAxis.labelPosition = .bottom
            //xAxis.axisMaxLabels = 3
            xAxis.labelCount = 5
            xAxis.drawLabelsEnabled = true
            xAxis.drawLimitLinesBehindDataEnabled = true
            xAxis.avoidFirstLastClippingEnabled = true
            xAxis.drawGridLinesEnabled = false
            xAxis.granularity = 5
            chartView.rightAxis.drawLabelsEnabled = false
            chartView.leftAxis.drawLabelsEnabled = false
            chartView.leftAxis.drawGridLinesEnabled = false
            chartView.legend.enabled = false

            // Set the x values date formatter
            let xValuesNumberFormatter = ChartXAxisFormatter()
            
            let df = DateFormatter()
            df.dateStyle = .none
            df.dateFormat = LSTTheme.DateFormat.Chart_AQI_Update_Time
            xValuesNumberFormatter.dateFormatter = df
            
            xAxis.valueFormatter = xValuesNumberFormatter
            
            chartView.chartDescription?.text = "AQI Level"
        }
    }
    
    /// Loads/refreshes the graph view with provided `line`
    func updateGraph(with list: [ChartDataEntry]) {
        
        var lineChartEntries = list
        
        if lineChartEntries.count > 10 {
            lineChartEntries.removeFirst(lineChartEntries.count - 10)
        }
        
        let valueColors = lineChartEntries.compactMap({ self.colorPicker(for: $0.y) })
        let line = LineChartDataSet(entries: lineChartEntries, label: nil)
        line.colors = valueColors
        line.valueColors = valueColors
        line.mode = .horizontalBezier
        line.drawCirclesEnabled = false
        
        chartView.data = LineChartData(dataSets: [line])
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func colorPicker(for airQuality : Double?) -> UIColor {

        guard let airQuality = airQuality else {
            return .label
        }
        
        let aqiLevel = AQILevel.check(for: airQuality)
        return aqiLevel.color
    }

}

/// Helper class to show formatted time on graph's x-axis
class ChartXAxisFormatter: NSObject {
    var dateFormatter: DateFormatter?
}


extension ChartXAxisFormatter: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            if let dateFormatter = dateFormatter {

                let date = Date(timeIntervalSince1970: value)
                return dateFormatter.string(from: date)
            }

            return ""
        }

}
