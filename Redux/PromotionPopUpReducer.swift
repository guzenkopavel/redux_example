//
// Created by Pavel Guzenko on 19.05.2022.
//

import Foundation

func PromotionPopUpReducer(action: PromotionPopUpModel.Messages, state: PromotionPopUpModel.Stores) -> PromotionPopUpModel.Stores {
    switch (action) {
    case .storePromotion(let data):
        return .initial(.init(promo: data))
    }
}
