//
//  CityManager.swift
//  GlovoTest
//
//  Created by Manuel Vrhovac on 22/06/2018.
//  Copyright © 2018 Manuel Vrhovac. All rights reserved.
//

import Foundation


var cm: CityManager { return CityManager.shared }

class CityManager {
    
    static let shared = CityManager()
    var cities = [City]()
    
    var selectedCity: City?
    var downloading = [String]()

    
    
    lazy var countryDict: [String: [City]] = {
        var dict = [String:[City]]()
        
        for city in cities {
            let countryName = NSLocale.current.localizedString(forRegionCode: city.countryCode) ?? ""
            var array = dict[countryName] ?? [City]()
            array.append(city)
            dict[countryName] = array
        }
        return dict
    }()
    
    lazy var sortedCountryDict: [(key: String, value: [City])] = {
        var sorted = countryDict.sorted { $0.key < $1.key }
        for (var entry) in sorted {
            entry.value = entry.value.sorted{ $0.name < $1.name }
        }
        let myCountryCode = NSLocale.current.regionCode ?? ""
        let myCountry = NSLocale.current.localizedString(forRegionCode: myCountryCode) ?? ""
        if let myCountryCities = sorted.filter({$0.key == myCountry}).first {
            sorted.insert(myCountryCities, at: 0)
        }
        return sorted
    }()
    
    
    // MARK: - METHODS
    
    private init(){
        
    }
    
    func getCities(completion: @escaping ([City]?) -> Void ){
        Network.shared.request(path: "/api/cities/"){ json, _, _ in
            guard let array = json.array else {
                return completion(nil)
            }
            let cities = array.map { cityJson -> City in
                let name = cityJson["name"].stringValue
                let code = cityJson["code"].stringValue
                let countryCode = cityJson["country_code"].stringValue
                let workingArea = cityJson["working_area"].object as? [String] ?? []
                return City(name: name, code: code, countryCode: countryCode, workingArea: workingArea)
            }
            return completion(cities)
        }
    }
    
    func getDetails(for city: City, completion: @escaping (City.Details?) -> Void){
        if cm.downloading.contains(city.code){
            return
        }
        cm.downloading.append(city.code)
        Network.shared.request(path: "/api/cities/\(city.code!)"){ json, _, _ in
            cm.downloading = cm.downloading.filter{$0 != city.code}
            guard json.dictionary != nil else {
                return completion(nil)
            }
            let details = City.Details(
                currency: json["currency"].stringValue,
                enabled: json["enabled"].boolValue,
                timeZone: json["time_zone"].stringValue,
                busy: json["busy"].boolValue,
                languageCode: json["language_code"].stringValue
            )
            return completion(details)
        }
    }
}
