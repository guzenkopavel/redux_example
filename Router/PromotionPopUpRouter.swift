//
// Created by Pavel Guzenko on 19.05.2022.
//

import Foundation
import UIKit

protocol PromotionPopUpRouterProtocol {
    func closeScreen()
}

class PromotionPopUpRouter: PromotionPopUpRouterProtocol {
    weak var viewController: UIViewController?

    func closeScreen() {
        viewController?.dismiss()
    }
}
