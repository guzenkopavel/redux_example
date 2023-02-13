//
// Created by Pavel Guzenko on 19.05.2022.
//

import Foundation
import UIKit
import Resolver

class PromotionPopUpBuilder {
    class func build(promotion: Promotion) -> UIViewController {
        let viewController = PromotionPopUpViewController()

        let router = PromotionPopUpRouter()
        router.viewController = viewController

        @Injected var api: ApiWrapper
        @Injected var worker: PromoCodeSelectedWorker

        let executor = PromotionPopUpExecutor(promotionsWorker: worker, apiWrapper: api)
        let store = PromotionPopUpModel.PromotionPopUpStore(reducer: PromotionPopUpReducer, executor: executor, defaultState: .initial(.init(promo: promotion)))
        let viewModel = PromotionPopUpViewModel(store: store)
        viewModel.router = router
        viewController.viewModel = viewModel

        return viewController
    }
}
