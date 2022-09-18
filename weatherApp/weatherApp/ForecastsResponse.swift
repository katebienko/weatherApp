import Foundation

struct ForecastsResponse: Codable {
    let location: (Location)
    let current: (Current)
    let forecast: (Forecast)
}

struct Location: Codable {
    let name: String
}

struct Current: Codable {
    let temp_c: Double
    let wind_mph: Double
    let humidity: Int
    let vis_km: Double
    let condition: (Condition)
}

struct Condition: Codable {
    let text: String
}

struct Forecast: Codable {
    let forecastday: [(Forecastday)]
}

struct Forecastday: Codable {
    let date: String
    let day: (Day)
}

struct Day: Codable {
    let maxtemp_c: Double
    let mintemp_c: Double
    let avgtemp_c: Double
    let maxwind_kph: Double
    let totalprecip_mm: Double
    let daily_chance_of_rain: Double
}
