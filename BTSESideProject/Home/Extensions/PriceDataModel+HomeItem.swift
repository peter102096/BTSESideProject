import Foundation

extension Dictionary where Key == String, Value == PriceDataModel {
    var homeItems: [HomeItem] {
        return self.map { (_, priceDataModel) in
            return HomeItem(name: priceDataModel.name, price: priceDataModel.price)
        }
    }
}
