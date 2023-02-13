//
// Created by Pavel Guzenko on 19.05.2022.
//

import Foundation

class PromotionPopUpExecutor: PromotionPopUpModel.PromotionPopUpStoreExecutor {
    private let promotionsWorker: PromoSelectedWorkerProtocol
    private let apiWrapper: ApiWrapper

    init(promotionsWorker: PromoSelectedWorkerProtocol, apiWrapper: ApiWrapper) {
        self.promotionsWorker = promotionsWorker
        self.apiWrapper = apiWrapper
    }

    private var promotion: Promotion? {
        switch (getState()) {
        case .initial(let data):
            return data.promo
        default:
            return nil
        }
    }

    override func executeAction(action: PromotionPopUpModel.Actions, getState: @escaping () -> PromotionPopUpModel.Stores?) {
        super.executeAction(action: action, getState: getState)
        switch (action) {
        case .storePromoCode:
            if let promotion = promotion {
                addPromoToStore(promotion: promotion)
                dispatch(.storePromotion(promotion))
            }
            break
        case .tryGetCode:
            if let promotion = promotion, let id = promotion.id {
                apiWrapper.promotionsRegister(promotionId: id) { [weak self] promoResponse in
                    guard let self = self else {
                        return
                    }
                    self.apiWrapper.getPromotion(promotionId: id) { (response: ApiResponse<Promotion>) in
                        if let promo = response.data {
                            self.addPromoToStore(promotion: promo)
                            self.dispatch(.storePromotion(promo))
                        } else {
                            if let error = promoResponse.error, error.contains(PromoCodeSelectedWorker.Constant.noPromoErrorPath) == true {
                                self.publish(.noPromoCodes)
                            } else {
                                self.publish(.registerPromoCodeError)
                            }
                        }
                    }
                }
            }
        }
    }

    private func addPromoToStore(promotion: Promotion) {
        // промокод может быть использован
        var available: Bool = false
        if promotion.promotion_code?.actions?.contains(where: { $0 == PromoCodeSelectedWorker.Constant.Action.use.rawValue }) == true {
            available = true
        }
        // промокод может закончится по времени
        if promotion.actions?.contains(where: { $0 == PromoCodeSelectedWorker.Constant.Action.register.rawValue }) == true {
            available = true
        }
        if available == true {
            promotionsWorker.addPromo(.init(promotion: promotion))
            NotificationCenter.default.post(name: Notification.Name(PromoCodeSelectedWorker.appendPromoItem), object: nil)
        } else {
            publish(.cantUseThisPromo)
        }
    }
}
