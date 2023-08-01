import Foundation

// MARK: - MarketModelResponse
struct MarketModelResponse: Codable {
    let code: Int
    let msg: String
    let time: Int
    let data: [MarketDataModel]
    let success: Bool
}

// MARK: - MarketDataModel
struct MarketDataModel: Codable {
    let marketName: String
    let future: Bool
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case marketName
        case future
        case symbol
    }
}
