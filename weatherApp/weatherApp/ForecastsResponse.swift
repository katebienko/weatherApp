import Foundation

struct ForecastsResponse: Decodable {
    let location: (Location)
    let current: (Current)
    let forecast: (Forecast)
}

struct Location: Decodable {
    let name: String
}

struct Current: Decodable {
    let temp_c: Double
    let wind_mph: Double
    let humidity: Int
    let vis_km: Double
    let condition: (Condition)
}

struct Condition: Decodable {
    let text: String
}

struct Forecast: Decodable {
    let forecastday: [(Forecastday)]
}

struct Forecastday: Decodable {
    let date: String
    let day: (Day)
}

struct Day: Decodable {
    let maxtemp_c: Double
    let mintemp_c: Double
}
