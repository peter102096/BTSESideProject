import Foundation
import UIKit

extension UITableView {
    @discardableResult
    public func setSeparatorStyle(_ separatorStyle: UITableViewCell.SeparatorStyle) -> Self {
        self.separatorStyle = separatorStyle
        return self
    }
    @discardableResult
    public func setSeparatorInset(_ separatorInset: UIEdgeInsets) -> Self {
        self.separatorInset = separatorInset
        return self
    }
    @discardableResult
    public func setRegister(_ cellClass: AnyClass?, forCellReuseIdentifier identifier: String) -> Self {
        self.register(cellClass, forCellReuseIdentifier: identifier)
        return self
    }
    @discardableResult
    public func setRegister(_ nib: UINib?, forCellReuseIdentifier identifier: String) -> Self {
        self.register(nib, forCellReuseIdentifier: identifier)
        return self
    }
    @discardableResult
    public func setRegister(_ cellClass: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) -> Self {
        self.register(cellClass, forHeaderFooterViewReuseIdentifier: identifier)
        return self
    }
    @discardableResult
    public func setRegister(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) -> Self {
        self.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
        return self
    }
    @discardableResult
    public func setSectionHeaderHeight(_ height: CGFloat) -> Self {
        self.sectionHeaderHeight = height
        return self
    }
    @discardableResult
    public func setSectionHeaderTopPadding(_ padding: CGFloat) -> Self {
        self.sectionHeaderTopPadding = padding
        return self
    }
    @discardableResult
    public func setTableFooterView(_ view: UIView?) -> Self {
        self.tableFooterView = view
        return self
    }
    @discardableResult
    public func setDataSource(_ dataSource: UITableViewDataSource?) -> Self {
        self.dataSource = dataSource
        return self
    }
    @discardableResult
    public func setDelegate(_ delegate: UITableViewDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
}
