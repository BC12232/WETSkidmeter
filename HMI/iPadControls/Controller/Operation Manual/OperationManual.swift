//=================================== ABOUT ===================================

/*
 *  @FILE:          OperationManual.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This module is respnsble for loading operation manual
 *                  PDF files corresponding to specified languages
 *  @VERSION:       2.0.0
 */

/***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : In the showOperationManual() function, list all required languages
 *     for each state, provied the Resource File Name corresponding to the
 *     specified language.
 * 
 * NOTE: All PDF Files should be imported to the Project workspace's
 *       Resources directory
 *
 ***************************************************************************/

import Foundation
import ReaderFramework

public class OperationManual{
    
    let logger = Logger()
    
    /***************************************************************************
     * Function :  showOpereationManual
     * Input    :  none
     * Output   :  Reader View Controller Instance
     * Comment  :
     ***************************************************************************/
    
    public func showOperationManual() -> ReaderViewController {
        
        let systemLanguage = getDeviceLanguage()
        
        //Show Operation Manual According to the Device Language
        
        switch systemLanguage{
            
        case "en-us":
            return getOperationManualPDFFile(name: "OManual")
        default:
            return getOperationManualPDFFile(name: "OManual")
            
        }
        
    }
    
    /***************************************************************************
     * Function :  getDeviceLanguage
     * Input    :  none
     * Output   :  Language Name
     * Comment  :  This function is used just in case multi language operation
     *             manuals are provided
     ***************************************************************************/
    
    private func getDeviceLanguage() -> String{
        
        let language = Locale.preferredLanguages[0]
        logger.logData(data: "OPERATION MANUAL: SYSTEM LANGUAGE -> \(language)")
        
        return language
        
    }
    
    /***************************************************************************
     * Function :  getOperationManualPDFFile
     * Input    :  pdf file name
     * Output   :  Reader View Controller Instance
     * Comment  :
     ***************************************************************************/
    
    private func getOperationManualPDFFile(name:String) -> ReaderViewController{
        
        let operationManualFilePath = Bundle.main.path(forResource: name, ofType: "pdf")
        let readerDocument: ReaderDocument = ReaderDocument(filePath: operationManualFilePath, password: nil)
        
        //Set the page number to show to 1
        readerDocument.pageNumber = 1
        
        let readerViewController: ReaderViewController = ReaderViewController(readerDocument: readerDocument)
        
        return readerViewController
        
    }
    
}
