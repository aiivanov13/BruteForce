import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for item in views {
            self.addSubview(item)
        }
    }
}
