import Foundation

// MARK: - PriceModelResponse
struct PriceModelResponse: Codable {
    let topic: String
    let id: String?
    let data: [String: PriceDataModel]
}

// MARK: - PriceDataModel
struct PriceDataModel: Codable {
    let id, name: String
    let type: Int
    let price: Double

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case price
    }
}
