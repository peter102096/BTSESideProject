import UIKit

class ContentCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func setUp(_ title: String, price: String) {
        nameLabel.textColor = .black
        priceLabel.textColor = .black
        nameLabel.text = title
        priceLabel.text = price
    }
}
