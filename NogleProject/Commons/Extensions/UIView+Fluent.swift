import UIKit
extension UIView {
    @discardableResult
    public func setBackgroundColor(_ color: UIColor?) -> Self {
        self.backgroundColor = color
        return self
    }
    @discardableResult
    public func setHiddenState(_ isHidden: Bool) -> Self {
        self.isHidden = isHidden
        return self
    }
    @discardableResult
    public func setBorderWidth(_ borderWidth: CGFloat) -> Self {
        self.layer.borderWidth = borderWidth
        return self
    }
    @discardableResult
    public func setBorderColor(_ borderColor: CGColor?) -> Self {
        self.layer.borderColor = borderColor
        return self
    }
    @discardableResult
    public func setCornerRadius(_ cornerRadius: CGFloat) -> Self {
        self.layer.cornerRadius = cornerRadius
        return self
    }
}
