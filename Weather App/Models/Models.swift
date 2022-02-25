//
//  Models.swift
//  Weather App
//
//  Created by Shohzod Rajabov on 23/02/22.
//

import UIKit

class WeatherFull {
    
    var lon: Double?
    var lat: Double?
    var timezone_offset: Double?
    var timezone: String?
    
    var current :Current?
    var minutely = [Minutely]()
    var hourly = [Hourly]()
    var daily = [Daily]()
    
    init(_ json: [String: AnyObject]) {
        self.lon = json["lon"] as? Double
        self.lat = json["lat"] as? Double
        self.timezone = json["timezone"] as? String
        self.timezone_offset = json["timezone_offset"] as? Double
        
        
        if let dict = json["current"] as? [String: AnyObject] {
            self.current = Current.init(dict)
        }
        if let array = json["minutely"] as? [[String : AnyObject]]{
            var result = [Minutely]()
            for js in array{
                let obj = Minutely.init(js)
                result.append(obj)
            }
            self.minutely = result
        }
        if let array = json["hourly"] as? [[String : AnyObject]]{
            var result = [Hourly]()
            for js in array{
                let obj = Hourly.init(js)
                result.append(obj)
            }
            self.hourly = result
        }
        if let array = json["daily"] as? [[String : AnyObject]]{
            var result = [Daily]()
            for js in array{
                let obj = Daily.init(js)
                result.append(obj)
            }
            self.daily = result
        }
    }
}

class Current {
    
    var dt: Double?
    var sunrise: Double?
    var sunset: Double?
    var temp: Double?
    var feels_like: Double?
    var pressure: Int?
    var humidity: Int?
    var dew_point: Double?
    var uvi: Double?
    var clouds: Int?
    var visibility: Double?
    var wind_speed: Double?
    var wind_deg: Double?
    
    var weather = [Weather]()

    init(_ json: [String: AnyObject]) {
        self.dt = json["dt"] as? Double
        self.sunrise = json["sunrise"] as? Double
        self.sunset = json["sunset"] as? Double
        self.temp = json["temp"] as? Double
        self.feels_like = json["feels_like"] as? Double
        self.pressure = json["pressure"] as? Int
        self.humidity = json["humidity"] as? Int
        self.dew_point = json["dew_point"] as? Double
        self.uvi = json["uvi"] as? Double
        self.clouds = json["clouds"] as? Int
        self.visibility = json["visibility"] as? Double
        self.wind_speed = json["wind_speed"] as? Double
        self.wind_deg = json["wind_deg"] as? Double
        
        if let array = json["weather"] as? [[String : AnyObject]]{
            var result = [Weather]()
            for js in array{
                let obj = Weather.init(js)
                result.append(obj)
            }
            self.weather = result
        }
    }
}

class Weather {
    var id: Int?
    var main: String?
    var description: String?
    var icon: String?
    
    init(_ json:[String : AnyObject]) {
        self.id = json["id"] as? Int
        self.main = json["main"] as? String
        self.description = json["description"] as? String
        self.icon = json["icon"] as? String
    }
}

class Minutely {
    var dt: Double?
    var precipitation: Double?
    
    init(_ json:[String : AnyObject]) {
        self.dt = json["dt"] as? Double
        self.precipitation = json["precipitation"] as? Double
    }
}

class Hourly {
    var dt: Double?
    var temp: Double?
    var feels_like: Double?
    var pressure: Double?
    var humidity: Double?
    var dew_point: Double?
    var uvi: Double?
    var clouds: Double?
    var visibility: Double?
    var wind_speed: Double?
    var wind_deg: Double?
    var pop: Double?
    var weather = [Weather]()

    init(_ json: [String: AnyObject]) {
        self.dt = json["dt"] as? Double
        self.temp = json["temp"] as? Double
        self.feels_like = json["feels_like"] as? Double
        self.pressure = json["pressure"] as? Double
        self.humidity = json["humidity"] as? Double
        self.dew_point = json["dew_point"] as? Double
        self.uvi = json["uvi"] as? Double
        self.clouds = json["clouds"] as? Double
        self.visibility = json["visibility"] as? Double
        self.wind_speed = json["wind_speed"] as? Double
        self.wind_deg = json["wind_deg"] as? Double
        self.pop = json["pop"] as? Double
        
        if let array = json["weather"] as? [[String : AnyObject]]{
            var result = [Weather]()
            for js in array{
                let obj = Weather.init(js)
                result.append(obj)
            }
            self.weather = result
        }
    }
    
    init(isCustom:Bool){
        self.dt = 100.0
        self.wind_speed = 100.0
    }
}

class Daily {
    
    var dt: Double?
    var sunrise: Double?
    var sunset: Double?
    var moonrise: Double?
    var moonset: Double?
    var moon_phase: Double?
    var pressure: Int?
    var humidity: Int?
    var dew_point: Double?
    var wind_speed: Double?
    var wind_deg: Double?
    var wind_gust: Double?
    var clouds: Int?
    var pop: Double?
    var uvi: Double?
    var temp: Temp?
    var feels_like: Feels_like?
    var weather = [Weather]()
    
    init(_ json: [String: AnyObject]) {
        
        self.dt = json["dt"] as? Double
        self.sunrise = json["sunrise"] as? Double
        self.sunset = json["sunset"] as? Double
        self.moonrise = json["moonrise"] as? Double
        self.moonset = json["moonset"] as? Double
        self.moon_phase = json["moon_phase"] as? Double
        self.pressure = json["pressure"] as? Int
        self.humidity = json["humidity"] as? Int
        self.dew_point = json["dew_point"] as? Double
        self.wind_speed = json["wind_speed"] as? Double
        self.wind_deg = json["wind_deg"] as? Double
        self.wind_gust = json["wind_gust"] as? Double
        self.clouds = json["clouds"] as? Int
        self.pop = json["pop"] as? Double
        self.uvi = json["uvi"] as? Double
        
        if let dict = json["temp"] as? [String : AnyObject]{
            self.temp = Temp.init(dict)
        }
        if let dict = json["feels_like"] as? [String : AnyObject]{
            self.feels_like = Feels_like.init(dict)
        }
        if let array = json["weather"] as? [[String : AnyObject]]{
            var result = [Weather]()
            for js in array{
                let obj = Weather.init(js)
                result.append(obj)
            }
            self.weather = result
        }
    }
}

class Temp {
    var day: Double?
    var min: Double?
    var max: Double?
    var night: Double?
    var eve: Double?
    var morn: Double?
    
    init(_ json:[String : AnyObject]) {
        self.day = json["day"] as? Double
        self.min = json["min"] as? Double
        self.max = json["max"] as? Double
        self.night = json["night"] as? Double
        self.eve = json["eve"] as? Double
        self.morn = json["morn"] as? Double
    }
}

class Feels_like {
    var day: Double?
    var night: Double?
    var eve: Double?
    var morn: Double?
    
    init(_ json:[String : AnyObject]) {
        self.day = json["day"] as? Double
        self.night = json["night"] as? Double
        self.eve = json["eve"] as? Double
        self.morn = json["morn"] as? Double
    }
}


class City {
    var id: Int?
    var name: String?
    var state: String?
    var country: String?
    var coord: Location?

    init(_ json: [String: AnyObject]) {

        self.id = json["id"] as? Int
        self.name = json["name"] as? String
        self.state = json["state"] as? String
        self.country = json["country"] as? String
        if let dict = json["coord"] as? [String: AnyObject] {
            self.coord = Location.init(dict)
        }
    }
}

class Location {
    var lon: Double?
    var lat: Double?
    init(_ json:[String : AnyObject]) {
        self.lon = json["lon"] as? Double
        self.lat = json["lat"] as? Double
    }
}

class Definition {
    var defText: String?
    var iconName: String?
    init(defText:String = "", iconName:String = "") {
        self.defText = defText
        self.iconName = iconName
    }
}

class CurrentCityName {
    var cityName: CityName?
    init(_ json: [String: AnyObject]) {
        if let dict = json["city"] as? [String: AnyObject] {
            self.cityName = CityName.init(dict)
        }
    }
}

class CityName {
    var name: String?
    init(_ json:[String : AnyObject]) {
        self.name = json["name"] as? String
        
    }
}
