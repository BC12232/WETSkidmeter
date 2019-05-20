//=================================== ABOUT ===================================

/*
 *  @FILE:          HTTPComm.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This module is responsible for all HTTP calls
 *  @VERSION:       2.0.0
 *
 */

import UIKit

class HTTPComm: NSObject{
    
    let debug_mode = false
    
    /***************************************************************************
     * Function :  httpGetResponseFromPath
     * Input    :  HTTP PATH URL: String
     * Output   :  Completion Block: Response: Can be Any Object or Empty if error
     * Comment  :  Make GET and SEND HTTP Requests and Serialize the data in JSON Format
     ***************************************************************************/
    
    func httpGetResponseFromPath(url:String,completion:@escaping (_ response:AnyObject?)->()){
    
        var responseObj:AnyObject?
        
        request(url).responseJSON{ (response) in
            
            guard response.response != nil else{
                return
            }
            
            self.logData(str: response.request!.description)    // Original URL request
            self.logData(str: response.response!.description)   // HTTP URL response
            self.logData(str: response.data!.description)       // Server Data
            self.logData(str: response.result.description)      // Result of the call
            
            if response.result.description == "SUCCESS"{
                
                if let JSON = response.result.value{
                    
                    responseObj = JSON as AnyObject?
                    completion(responseObj)
                    
                }
                
            }else{
                
                self.logData(str: "Failed To Perform HTTP Request")
                responseObj = nil
                completion(responseObj)
                
            }
            
        }
    }
    
    /***************************************************************************
     * Function :  serializeJSONResponse
     * Input    :  HTTP Request Response: Data
     * Output   :  Serialized JSOn Data in form of Any Object
     * Comment  :  Tries to serialize returned JSON response
     *
     *
     *
     ***************************************************************************/
    
    private func serializeJSONResponse(responseData:Data?)->AnyObject?{
        
        do{
            
            let parsedData = try JSONSerialization.jsonObject(with: responseData!, options: []) as! NSArray
            let responseObj = parsedData as AnyObject
            return responseObj
            
        }catch let error as NSError{
            
            self.logData(str: "FAILED TO SERIALIZE JSON DATA ERR: \(error)")
            return nil
            
        }
        
    }
    
    
    
    
    /***************************************************************************
     * Function :  logData
     * Input    :  data to log to console log
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func logData(str:String){
        
        if debug_mode == true{
            
            print("HTTP REQUEST: \(str)")
            
        }
        
    }
    
    
    
    public func httpGet(url: String, completion:@escaping (_ response: Any?, _ Bool: Bool?) -> ()) {
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            
            //get status code 200(good), 400+ (bad)
            if let response = response as? HTTPURLResponse {
            
                let statusCode = response.statusCode
                
                if statusCode == 200 && error == nil  {
                    // Convert this to json by using do try block
                    if let data = data {
                        do {
                            let parsedData = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                            completion(parsedData as Any, true)
                        } catch {
                            
                            
                        }
                    }
                }
                
            }
            }.resume()
    }
    
    
    
    public func httpPost(url: String, completion:@escaping (_ bool: Any?) -> ()){
        
        //parameters would be dictionary
        let parameters = ["data": "data", "data": "data", "data": "data"]
        
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //This line is important because it will say what kind of data we are sending which is JSON
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                
                if statusCode == 200 && error == nil  {
                    
                    
                    // Convert this to json by using do try block
                    if let data = data {
                        do {
                            let parsedData = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                            print(parsedData)
                            completion(true)
                        } catch {
                            completion(false)
                            print(error)
                            
                        }
                    }
                } else {
                    completion(false)
                }
            }
            }.resume()
    }
    
}
