//=================================== ABOUT ===================================

/*
 *  @FILE:          Helper.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This file contains helper functions that the software
 *                  system uses constantly in different modules
 *  @VERSION:       2.0.0
 */

//========================== CONFIGURATION PARAMETERS =========================

//NOTE: After implementing this screen, make sure following global configuration parameters are matching the project specifications

let CONTROLS_APP_FTP_SERVER_VERSION_NUMBER_URL = "https://act:act@www.controlshelp.com/act/jewl/versionNum.php"
var isChineseVersion = false
var currentVersion       = 1
var updatedVersionNumber = 1
import Foundation

public class Helper{

    let logger   = Logger()
    let httpComm = HTTPComm()
    
    /***************************************************************************
     * Function :  getLanguageSettigns
     * Input    :  Screen Name: String
     * Output   :  Translated texts in dictionary format
     * Comment  :  This function gets the language translation settings for specic screen
     ***************************************************************************/
    
    public func getLanguageSettigns(screenName:String)->Dictionary<String, String>{
        
        let availableLanguage = ["zh","ko","en","es","ar","ru","tr"]
        
        //Get translation json file from project resources
        
        let matchedLanguage = [Bundle.preferredLocalizations(from: availableLanguage, forPreferences: NSLocale.preferredLanguages)][0]
        var dataDictionary = [String : Any]()
        
        //Try to serialize Json data into NSDictioanry data structure
        if let filePath = Bundle.main.path(forResource: "languages", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
                dataDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]
                self.logger.logData(data: "HELPER: JSON SERIALIZED LANGUAGE DATA")
            } catch {
                self.logger.logData(data: "HELPER: COULD NOT SERIALIZE LANGUAGE JSON DATA")
            }
            
        }
    
        
        //Get the specific language data from the json file for specified screen
        
        let lang = matchedLanguage[0]
        
        if lang == "zh" {
            isChineseVersion = true
        } else {
            isChineseVersion = false
        }
        
        let languageData = dataDictionary[lang] as! [String : Any]
        let screenTranslatedData = languageData[screenName] as! [String: String]
        
        return screenTranslatedData
        
    }
    
    /***************************************************************************
     * Function :  getSerialNumber
     * Input    :  none
     * Output   :  Device Serial number
     * Comment  :  Gets the device serial number
     ***************************************************************************/
    
    public func getSerialNumber()->String{
    
        var serialNum = ""
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let manager:FileManager = FileManager.default
        let filepath = NSURL(string: documentsPath)!.appendingPathComponent("/WET/serialNum.txt")!.absoluteString
        
        if manager.fileExists(atPath: filepath){
            
            let data = try? NSString(contentsOfFile: filepath, encoding: String.Encoding.utf8.rawValue)
            let jsonData = data?.data(using: String.Encoding.utf8.rawValue)
            let serialNumText = try? JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            serialNum = serialNumText!.object(forKey: "serialNum") as! String
            
        }
        
        return serialNum
    
    }
    
    /***************************************************************************
     * Function :  checkForAppUpdates
     * Input    :  none
     * Output   :  Local App Version Number, FTP Server App Version Number
     * Comment  :  Returns both local and server app version numbers
     ***************************************************************************/
    
    public func checkForAppUpdates()->(Int,Int){
    
        let versionText          = Bundle.main.path(forResource: "versionNum", ofType: "txt")
        if versionText != nil{
            self.httpComm.httpGetResponseFromPath(url: CONTROLS_APP_FTP_SERVER_VERSION_NUMBER_URL){ (response) in
               
                if response != nil{
                    let content    = try? NSString(contentsOfFile: versionText!, encoding: String.Encoding.utf8.rawValue)
                    let jsonData   = content?.data(using: String.Encoding.utf8.rawValue)
                    
                    currentVersion = try!  (JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray)[0] as! Int
                    updatedVersionNumber = (response as! NSArray)[0] as! Int
                    
                }
            
            }
        }
        
        return (currentVersion,updatedVersionNumber)
    
    }
}
