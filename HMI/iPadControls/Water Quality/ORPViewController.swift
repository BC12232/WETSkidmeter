//=================================== ABOUT ===================================

/*
 *  @FILE:          ORPViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module reads all water quality data, parses them
 *                  and generates corresponding chart data
 *  @VERSION:       2.0.0
 */

 /***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : No Project Specific Configuration Needed
 *
 ***************************************************************************/

import UIKit
import Charts


var ORPDataEntries:  [ChartDataEntry] = []

class ORPViewController: UIViewController,ChartViewDelegate{
    
    @IBOutlet weak var ORPChartView: LineChartView!
    weak var axisFormatDelegate:    IAxisValueFormatter?
    
    var dataSets:                   NSMutableArray   = []

    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        axisFormatDelegate = self
        ORPChartView.isUserInteractionEnabled = false
    }
    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        
        
        configureChartUI()
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    /***************************************************************************
     * Function :  configureChartUI
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    private func configureChartUI(){
        
        ORPChartView.delegate = self
        
        //No Data Label Configuration
        
        ORPChartView.noDataText                 = "NO RECORDS TO SHOW"
        ORPChartView.noDataTextColor            = DEFAULT_GRAY
        ORPChartView.noDataFont                 = UIFont(name: "verdana", size: 14.0)
        
        ORPChartView.dragEnabled                = true
        ORPChartView.pinchZoomEnabled           = true
        ORPChartView.chartDescription?.enabled  = false
        ORPChartView.chartDescription           = nil
        ORPChartView.legend.enabled             = false
        ORPChartView.setScaleEnabled(true)
        ORPChartView.setVisibleXRangeMaximum(WQ_GRAPH_MAX_DATA_POINTS)
        
        //Custom Y Axis
        
        let customLeftAxis = ORPChartView.leftAxis;
        customLeftAxis.labelTextColor               = DEFAULT_GRAY
        customLeftAxis.axisMaximum                  = WQ_ORP_MAX_VAL
        customLeftAxis.axisMinimum                  = WQ_ORP_MIN_VAL
        customLeftAxis.labelTextColor               = DEFAULT_GRAY
        customLeftAxis.granularityEnabled           = true
        
        //Custom X Axis
        
        let customXAxis                             = ORPChartView.xAxis;
        customXAxis.labelTextColor                  = DEFAULT_GRAY
        customXAxis.valueFormatter                  = axisFormatDelegate
        customXAxis.axisRange                       = WQ_GRAPH_X_AXIS_RANGE
        
        ORPChartView.rightAxis.enabled               = false
        
        
    }
    

    /***************************************************************************
     * Function :  getData
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    @objc func getData(){
        
        if x_values.count > 0 && orp_y_values.count > 0{
            setChart(dataPoints: x_values, values: orp_y_values)
        }
    }
    
    /***************************************************************************
     * Function :  setChart
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    func setChart(dataPoints: [String], values: [Float]){
        
        dataSets = []
        
        //First we need to convert the string time stamp to date
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:s"

        
        var chartDataEmtries = [ChartDataEntry]()
        
        // TODO: check why DATES and ORP_VALUES are not the same count //orp_y_values.count
        for index in 0..<dataPoints.count {
            let date = dateFormatter.date(from: dataPoints[index])
            let timeIntervalForDate: TimeInterval = date!.timeIntervalSince1970
            
            chartDataEmtries.append(ChartDataEntry(x: Double(timeIntervalForDate), y: Double(orp_y_values[index])))
        }
        
        

        if ORPDataEntries.count < Int(WQ_GRAPH_MAX_DATA_POINTS){
            ORPDataEntries.append(contentsOf: chartDataEmtries)
            
        } else {
            ORPDataEntries.remove(at: 0)
            ORPDataEntries.append(chartDataEmtries.last!)
        }
        
        var data = LineChartData()
        let ds1 = LineChartDataSet(values: ORPDataEntries, label: "")
        
        //Configure the data set points
        dataSets.add(ds1)
        
        ds1.setColor(UIColor.white)
        
        ds1.drawCirclesEnabled  = false
        ds1.lineWidth           = WQ_GRAPH_LINE_WIDTH
        ds1.fillColor           = WQ_GRAPH_LINE_COLOR
        ds1.fillAlpha           = WQ_GRAPH_FILL_ALPHA
        ds1.drawValuesEnabled   = false
        ds1.drawFilledEnabled   = true
        
        data = LineChartData(dataSets: dataSets as? [IChartDataSet])

        //Add the data set to the chart
        ORPChartView.data = data
        
    }


}


extension ORPViewController: IAxisValueFormatter {
    
    //NOTE: We Add this extension to format the chart X axis values as timestamps instead of floating points
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
        
    }
    
}

