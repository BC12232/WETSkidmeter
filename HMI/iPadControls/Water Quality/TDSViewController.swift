//=================================== ABOUT ===================================

/*
 *  @FILE:          TDSViewController.swift
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

import Foundation
import Charts


var TDSDataEntries:  [ChartDataEntry] = []

class TDSViewController: UIViewController,ChartViewDelegate{

    @IBOutlet weak var TDSChartView: LineChartView!
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
        TDSChartView.isUserInteractionEnabled = false
        
    }
    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        
        self.configureChartUI()
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
        
        TDSChartView.delegate = self
        
        //No Data Label Configuration
        
        TDSChartView.noDataText                = "NO RECORDS TO SHOW"
        TDSChartView.noDataTextColor           = DEFAULT_GRAY
        TDSChartView.noDataFont                = UIFont(name: "verdana", size: 14.0)
        
        TDSChartView.dragEnabled               = true
        TDSChartView.pinchZoomEnabled          = true
        TDSChartView.chartDescription?.enabled = false
        TDSChartView.chartDescription          = nil
        TDSChartView.legend.enabled            = false
        TDSChartView.data?.highlightEnabled    = true

        TDSChartView.setScaleEnabled(true)
        TDSChartView.setVisibleXRangeMaximum(WQ_GRAPH_MAX_DATA_POINTS)

        //Custom Y Axis
        
        let customLeftAxis                         = TDSChartView.leftAxis;
        customLeftAxis.labelTextColor              = DEFAULT_GRAY
        customLeftAxis.axisMaximum                 = WQ_TDS_MAX_VAL
        customLeftAxis.axisMinimum                 = WQ_TDS_MIN_VAL
        customLeftAxis.labelTextColor              = DEFAULT_GRAY
        customLeftAxis.granularityEnabled          = true
        
        //Custom X Axis
        
        let customXAxis                            = TDSChartView.xAxis;
        customXAxis.labelTextColor                 = DEFAULT_GRAY
        customXAxis.valueFormatter                 = axisFormatDelegate
        customXAxis.axisRange                      = WQ_GRAPH_X_AXIS_RANGE

        TDSChartView.rightAxis.enabled         = false
        
    }


    
    /***************************************************************************
     * Function :  getData
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    @objc func getData(){
        
        if x_values.count > 0 && tds_y_values.count > 0{
            setChart(dataPoints: x_values, values: tds_y_values)
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
        
        // TODO: check why DATES and TDS_VALUES are not the same count //tds_y_values.count
        for index in 0..<dataPoints.count {
            let date = dateFormatter.date(from: dataPoints[index])
            let timeIntervalForDate: TimeInterval = date!.timeIntervalSince1970
            
            chartDataEmtries.append(ChartDataEntry(x: Double(timeIntervalForDate), y: Double(tds_y_values[index])))
        }
        
        
        
        if TDSDataEntries.count < Int(WQ_GRAPH_MAX_DATA_POINTS){
            TDSDataEntries.append(contentsOf: chartDataEmtries)
            
        } else {
            TDSDataEntries.remove(at: 0)
            TDSDataEntries.append(chartDataEmtries.last!)
        }
        
        
        var data = LineChartData()
        let ds1 = LineChartDataSet(values: TDSDataEntries, label: "")
        
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
        TDSChartView.data = data
        
    }

}


extension TDSViewController: IAxisValueFormatter {
    
    //NOTE: We Add this extension to format the chart X axis values as timestamps instead of floating points
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
        
    }
    
}

