//=================================== ABOUT ===================================

/*
 *  @FILE:          PHViewController.swift
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

var PHDataEntries:  [ChartDataEntry] = []

class PHViewController: UIViewController,ChartViewDelegate{
    
    
    @IBOutlet weak var PHChartView: LineChartView!
    
    weak var axisFormatDelegate:    IAxisValueFormatter?
    
    var dataSets:                   NSMutableArray    = []
    
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
        PHChartView.isUserInteractionEnabled = false
        
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
        
        PHChartView.delegate = self
        
        //No Data Label Configuration
        
        PHChartView.noDataText                 = "NO RECORDS TO SHOW"
        PHChartView.noDataTextColor            = DEFAULT_GRAY
        PHChartView.noDataFont                 = UIFont(name: "verdana", size: 14.0)
        
        PHChartView.dragEnabled                = true
        PHChartView.pinchZoomEnabled           = true
        PHChartView.chartDescription?.enabled  = false
        PHChartView.chartDescription           = nil
        PHChartView.legend.enabled             = false
        
        PHChartView.setScaleEnabled(true)
        PHChartView.setVisibleXRangeMaximum(WQ_GRAPH_MAX_DATA_POINTS)
        
        
        //Custom Y Axis
        
        let customLeftAxis                          = PHChartView.leftAxis;
        customLeftAxis.labelTextColor               = DEFAULT_GRAY
        customLeftAxis.axisMaximum                  = WQ_PH_MAX_VAL
        customLeftAxis.axisMinimum                  = WQ_PH_MIN_VAL
        customLeftAxis.labelTextColor               = DEFAULT_GRAY
        customLeftAxis.granularityEnabled           = true
        
        //Custom X Axis
        
        let customXAxis                             = PHChartView.xAxis;
        customXAxis.labelTextColor                  = DEFAULT_GRAY
        customXAxis.valueFormatter                  = axisFormatDelegate
        customXAxis.axisRange                       = WQ_GRAPH_X_AXIS_RANGE
        
        PHChartView.rightAxis.enabled = false
        
        
    }
    
    
    /***************************************************************************
     * Function :  getData
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    @objc func getData(){
        
        if x_values.count > 0 && ph_y_values.count > 0{
            setChart(dataPoints: x_values, values: ph_y_values)
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
      
        var chartDataEntries = [ChartDataEntry]()
        
        // TODO: check why DATES and PH_VALUES are not the same count //ph_y_values.count
        for index in 0..<dataPoints.count {
            let date = dateFormatter.date(from: dataPoints[index])
            let timeIntervalForDate: TimeInterval = date!.timeIntervalSince1970
            
            chartDataEntries.append(ChartDataEntry(x: Double(timeIntervalForDate), y: Double(ph_y_values[index])))
        }
        
        
        
        if PHDataEntries.count < Int(WQ_GRAPH_MAX_DATA_POINTS){
            PHDataEntries.append(contentsOf: chartDataEntries)
            
        } else {
            PHDataEntries.remove(at: 0)
            PHDataEntries.append(chartDataEntries.last!)
        }
        
    
        
        var data = LineChartData()
        let ds1 = LineChartDataSet(values: PHDataEntries, label: "")
        
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
        PHChartView.data = data
        
    }
    
    
}


extension PHViewController: IAxisValueFormatter {
    
    //NOTE: We Add this extension to format the chart X axis values as timestamps instead of floating points
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
        
    }
    
}

