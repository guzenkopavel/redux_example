//
// Created by Pavel Guzenko on 19.05.2022.
//

import Foundation
import Resolver

enum PromotionPopUpModel {
    typealias PromotionPopUpStore = Store<PromotionPopUpModel.Stores, PromotionPopUpModel.Actions, PromotionPopUpModel.StoreLabels, PromotionPopUpModel.Messages, Workflow>
    typealias PromotionPopUpStoreExecutor = StoreExecutor<PromotionPopUpModel.Stores, PromotionPopUpModel.Actions, PromotionPopUpModel.StoreLabels, PromotionPopUpModel.Messages, Workflow>
    typealias Section = ItemsDataSource<ViewModels>.Section<ViewModels>

    enum StoreLabels {
        // ошибка что нету промокодов
        case noPromoCodes
        // ошибка что не получилось зарегистироваться в акции
        case registerPromoCodeError
        // ошибка что нельзя использовать этот промокод
        case cantUseThisPromo
    }

    enum ViewLabels {
        // показать ошибку
        case error(String)
    }

    enum Actions {
        // сохранить текущий промокод в хранилище
        case storePromoCode
        // попробывать зарегистрировать в акции
        case tryGetCode

    }

    enum Messages {
        // сохраняем промокод в хранилище
        case storePromotion(Promotion)

    }

    enum Stores {
        struct Initial {
            let promo: Promotion
        }

        case initial(Initial)
    }

    enum Views {
        case initial

        struct ShowData {
            let title: String
            let sections: [Section]
        }

        case showData(ShowData)
    }
}

extension PromotionPopUpModel {
    enum ViewModels: Item {
        case info(title: String)
        case aboutPromotion(title: String)
        case articlePromotion(PromotionTableViewCell.ViewModel)
    }
}

extension PromotionPopUpModel {
    enum Resources {
        enum Localization {
            static let title = "PromotionPopUp.title".localized()
        }
    }
}


extension Resolver {
    static func registerPromotionPopUp() {
        register {
            PromotionPopUpService()
        }
                .implements(PromotionPopUpProtocol.self)

    }
}