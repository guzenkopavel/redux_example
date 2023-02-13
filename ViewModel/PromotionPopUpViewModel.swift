//
// Created by Pavel Guzenko on 19.05.2022.
//

import Foundation
import RxSwift

protocol PromotionPopUpViewModelProtocol {
    var state: Observable<PromotionPopUpModel.Views> { get }
    var labels: Observable<PromotionPopUpModel.ViewLabels?> { get }

    /// закрыть попап
    func closePopUp()

    /// добавить промокод в хранилище
    func addPromoItem(_: PromotionTableViewCell.ViewModel)
}

class PromotionPopUpViewModel {
    private let _state = BehaviorSubject<PromotionPopUpModel.Views>(value: .initial)
    private let _labels = BehaviorSubject<PromotionPopUpModel.ViewLabels?>(value: nil)
    private let store: PromotionPopUpModel.PromotionPopUpStore
    var router: PromotionPopUpRouterProtocol?
    private let bag = DisposeBag()
    private let promotionsWorker: PromoSelectedWorkerProtocol = PromoCodeSelectedWorker.shared

    init(store: PromotionPopUpModel.PromotionPopUpStore) {
        self.store = store

        self.store.stateObservable.subscribe(on: MainScheduler.instance).subscribe { [weak self] stores in
                    if let state = stores.element {
                        self?.updateState(state)
                    }
                }
                .disposed(by: bag)

        self.store.labelObservable.subscribe(on: MainScheduler.instance).subscribe { [weak self] labels in
                    if let label = labels.element.unsafelyUnwrapped {
                        self?.makeLabel(label)
                    }
                }
                .disposed(by: bag)
    }

    private func makeLabel(_ label: PromotionPopUpModel.StoreLabels) {
        switch (label) {
        case .noPromoCodes:
            _labels.on(.next(.error(Strings.ArticleView.View.noPromo)))
            break
        case .registerPromoCodeError:
            _labels.on(.next(.error(Strings.ArticleView.View.promoErrorRetry)))
            break
        case .cantUseThisPromo:
            _labels.on(.next(.error(Strings.ArticleView.View.cantUsePromo)))
            break
        }
    }

    private func updateState(_ state: PromotionPopUpModel.Stores) {
        switch (state) {
        case .initial(let data):
            _state.on(.next(.showData(.init(title: data.promo.name ?? "", sections: buildSections(promo: data.promo)))))
            break
        }
    }

    private func buildSections(promo: Promotion) -> [PromotionPopUpModel.Section] {
        var sections: [PromotionPopUpModel.Section] = []
        var items: [PromotionPopUpModel.ViewModels] = []
        if let text = promo.description {
            items.append(.info(title: text))
        }
        let new = ProductPromotion(promotion: promo)

        items.append(.articlePromotion(.init(
                type: PromoCodeSelectedWorker.getType(
                        promotionsWorker: promotionsWorker,
                        user: User.shared,
                        promotion: new),
                promo: new)))

        sections.append(.init(items: items))
        return sections
    }

    func addPromoItem(_ model: PromotionTableViewCell.ViewModel) {
        // если у нас уже был код в модели, если пользователь не авторизован, кода не будет
        if model.promo.promotion.promotionCode != nil {
            store.dispatch(.storePromoCode)
        } else {
            store.dispatch(.tryGetCode)
        }
    }
}

extension PromotionPopUpViewModel: PromotionPopUpViewModelProtocol {
    var state: Observable<PromotionPopUpModel.Views> {
        _state.asObservable()
    }

    var labels: Observable<PromotionPopUpModel.ViewLabels?> {
        _labels.asObservable()
    }

    func closePopUp() {
        router?.closeScreen()
    }
}
