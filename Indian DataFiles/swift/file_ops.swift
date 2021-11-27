//
//  File.swift
//  IPU
//
//  Created by Raheel Sayeed on 8/4/16.
//  Copyright © 2016 Raheel Sayeed. All rights reserved.
//

import Foundation

public func gmrun (){
    
    let dict =  gm("pullur mahbubnagar")
    
    print(dict)
    
}


public func gm(var addr: String) -> [String : String]? {
    
//    addr = "Pullur Mahbubnagar"
    
    print(addr.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)
    
    let url = NSURL(string: "http://maps.googleapis.com/maps/api/geocode/json?address=\(addr.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)")
    let data = NSData(contentsOfURL: url!)
    let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
    
    if let status = json["status"] as? String {
        if status != "OK" {
            print("Error: \(status)")
            return nil
            
        }
    }
    
    if let result = json["results"] as? NSArray {
        
        var geodata = [String : String]()

        if let formattedAddr = result[0]["formatted_address"] as? String {
            geodata["gmap_address"] = formattedAddr
            print(formattedAddr)
        }
        if let geometry = result[0]["geometry"] as? NSDictionary {

            if let location = geometry["location"] as? NSDictionary {
                if let bounds = geometry["bounds"] as? NSDictionary {
                    let northeast = bounds["northeast"] as! NSDictionary
                    let southwest = bounds["southwest"] as! NSDictionary
                    let ne_lat    = northeast["lat"] as! Float
                    let ne_lng    = northeast["lng"] as! Float
                    let sw_lat    = southwest["lat"] as! Float
                    let sw_lng    = southwest["lng"] as! Float
                    geodata["gmap_ne_lat"] = String(ne_lat)
                    geodata["gmap_ne_lng"] = String(ne_lng)
                    geodata["gmap_sw_lat"] = String(sw_lat)
                    geodata["gmap_sw_lng"] = String(sw_lng)
                    
                    print("Bounds NE(\(ne_lat),\(ne_lng)), SW(\(sw_lat), \(sw_lng))")
                }
                let latitude = location["lat"] as! Float
                let longitude = location["lng"] as! Float
                geodata["gmap_lat"] = String(latitude)
                geodata["gmap_lng"] = String(longitude)
                
                print("\(latitude), \(longitude)")
                return geodata
            }
        }
    }
    
    return nil
}


for (key, value) in gm_batch4 {
       
      let code = key 
      let address = value["gmap_address"]! 
      let addr = address.componentsSeparatedByString(",")
      let addr2 = addr.joinWithSeparator(" ")
      let lat  = value["gmap_lat"]! 
      let lng  = value["gmap_lng"]! 
      let ne_lat = (value["gmap_ne_lat"] == nil) ? "" : value["gmap_ne_lat"]! 
      let ne_lng = (value["gmap_ne_lng"] == nil) ? "" : value["gmap_ne_lng"]! 
      let sw_lat = (value["gmap_sw_lat"] == nil) ? "" : value["gmap_sw_lat"]! 
      let sw_lng = (value["gmap_sw_lng"] == nil) ? "" : value["gmap_sw_lng"]! 
       
      let str = "\(code),\(addr2),\(lat),\(lng),\(ne_lat),\(ne_lng),\(sw_lat),\(sw_lng)\n" 
      b3 += str 
     print(str) 
} 


for i in 0..<batch4.count {
     print("\n\(i)")
     let code = batch4[i]
     let searchStr = uv[code]!
     let dataDict  = gm(searchStr) 
    if dataDict == nil { sleep(1); continue; }
     gm_batch4[code] = dataDict
     sleep(1)
     i += 1

