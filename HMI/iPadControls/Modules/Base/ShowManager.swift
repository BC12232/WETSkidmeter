//
//  ShowManager.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/30/16.
//  Copyright © 2016 WET. All rights reserved.
//

import UIKit

public struct ShowPlayStat{
    
    var playMode = 0 //Options: 1 – manual , 0 – auto
    var playStatus = 0 //Options: 1 – is playing a show, 0- idle
    var currentShowNumber = 0 //Show number that is currently playing
    var deflate = "" //The moment the show started : Format :: HHMMSS
    var nextShowTime = 0 //Format :: HHMMSS
    var nextShowNumber = 0
    var showDuration = 0
    var nextShowName = ""
    var currentShowName = ""
    
}

public class ShowManager{
    
    private var shows: [Any]? = nil
    private var httpComm = HTTPComm()
    private var debug_mode = false
    private var showPlayStat = ShowPlayStat()
    
    //MARK: - Get Shows From The Server
    
    public func getShowsFile(){
        
        httpComm.httpGetResponseFromPath(url: READ_SHOWS_PATH){ (response) in
            
            self.shows = response as? [Any]
            
            guard self.shows != nil else{ return }
            
            UserDefaults.standard.set(self.shows, forKey: "shows")
            
            //We want to delete all the shows from local storage before saving new ones
            self.deleteAllShowsFromLocalStorage()
            
            //Save Each Show To Local Storage
            self.saveShowsInLocalStorage()
        }
        
    }
    
    //MARK: - Delete All the Shows
    
    public func deleteAllShowsFromLocalStorage(){
        
        Show.deleteAll()
        
    }
    
    //MARK: - Save Shows In Local Storage
    
    private func saveShowsInLocalStorage(){
        
        for show in self.shows!{
            
            let dictionary  = show as! NSDictionary
            let duration    = dictionary.object(forKey: "duration") as? Int
            let name        = dictionary.object(forKey: "name") as? String
            let number      = dictionary.object(forKey: "number") as? Int
            
            guard duration != nil && name != nil && number != nil else{
                return
            }
            
            let show        = Show.create() as! Show
            show.duration   = Int32(duration!)
            show.number     = Int16(number!)
            show.name       = name!
            
            _ = show.save()
            
            self.logData(str:"DURATION: \(duration!) NAME: \(name!) NUMBER: \(number!)")
            
        }
    }

    
    //MARK: - Get Current and Next Playing Show
    
    public func getCurrentAndNextShowInfo() -> ShowPlayStat {
        
        httpComm.httpGetResponseFromPath(url: READ_SHOW_PLAY_STAT){ (response) in
            
            if response != nil {
                guard let responseArray = response as? [Any] else { return }
                
                if !responseArray.isEmpty {
                    guard let responseDictionary = responseArray[0] as? [String : Any] else { return }
                    
                    if  let playMode         = responseDictionary["Play Mode"] as? Int,
                        let playStatus       = responseDictionary["play status"] as? Int,
                        let currentShow      = responseDictionary["Current Show"] as? Int,
                        let deflate          = responseDictionary["deflate"] as? String,
                        let nextShowTime     = responseDictionary["next Show Time"] as? Int,
                        let nextShowNumber   = responseDictionary["next Show Num"] as? Int {
                        
                        self.showPlayStat.currentShowNumber = currentShow
                        self.showPlayStat.deflate           = deflate
                        self.showPlayStat.nextShowTime      = nextShowTime
                        self.showPlayStat.nextShowNumber    = nextShowNumber
                        self.showPlayStat.playMode          = playMode
                        self.showPlayStat.playStatus        = playStatus
                        
                        if let shows = Show.query(["number":self.showPlayStat.currentShowNumber]) as? [Show] {
                            if !shows.isEmpty {
                                self.showPlayStat.showDuration = Int((shows[0].duration))
                                self.showPlayStat.currentShowName = (shows[0].name!)
                            }
                        }
                        
                        
                        if let nextShows = Show.query(["number":self.showPlayStat.nextShowNumber]) as? [Show] {
                            if !nextShows.isEmpty{
                                self.showPlayStat.nextShowName = (nextShows[0].name!)
                            }
                        }
                        
                        
                        
                    }
                }
            }
            
            
            }
        return self.showPlayStat
    }
    
    //Data Logger
    
    private func logData(str:String){
        
        if debug_mode == true{
            
            print(str)
            
        }
        
    }
    
}

