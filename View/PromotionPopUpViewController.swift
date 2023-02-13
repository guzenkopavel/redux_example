//
// Created by Pavel Guzenko on 19.05.2022.
//

import Foundation
import UIKit
import RxSwift

class PromotionPopUpViewController: PopupViewController {
    var viewModel: PromotionPopUpViewModelProtocol? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }

            disposables.append(viewModel.state.subscribe(on: MainScheduler.instance).subscribe { [weak self] state in
                if let state = state.element {
                    self?.updateState(state)
                }
            })

            disposables.append(viewModel.labels.subscribe(on: MainScheduler.instance).subscribe { [weak self] labels in
                if let label = labels.element.unsafelyUnwrapped {
                    self?.makeLabel(label)
                }
            })
        }
    }

    private var disposables: [Disposable] = []

    deinit {
        disposables.forEach { disposable in
            disposable.dispose()
        }
    }


    private func updateState(_ state: PromotionPopUpModel.Views) {
        switch (state) {
        case .initial:
            break
        case .showData(let data):
            titleLabel.text = data.title
            dataSource.sections = data.sections
            tableView.reloadData()
        }
    }

    private func makeLabel(_ label: PromotionPopUpModel.ViewLabels) {
        switch (label) {
        case .error(let error):
            let vc = UIAlertController(title: Strings.Alert.Common.error, message: error, preferredStyle: .alert)
            vc.addAction(.init(title: Strings.Alert.Common.ok, style: .cancel))
            present(vc)
        }
    }

    private let dataSource: ItemsDataSource<PromotionPopUpModel.ViewModels> = ItemsDataSource<PromotionPopUpModel.ViewModels>()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Image.clearClose, for: .normal)
        button.addTarget(self, action: #selector(tapOnClose), for: .touchUpInside)
        return button
    }()

    private lazy var navigationView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var containerView: UIView = {
        let scrollView = UIView()
        scrollView.backgroundColor = .white
        return scrollView
    }()

    private lazy var hiddenView: UIView = {
        let scrollView = UIView()
        scrollView.isUserInteractionEnabled = true
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    override var dismissView: UIView? {
        get {
            hiddenView
        }
        set {
            if let newValue = newValue {
                hiddenView = newValue
            }
        }
    }

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(cell: PromotionPopUpAboutCell.self)
        table.register(cell: PromotionPopUpInfoCell.self)
        table.register(cell: PromotionTableViewCell.self)
        return table
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = Theme.transparentGray
    }

    private func setupUI() {
        view.backgroundColor = .clear

        view.addSubview(containerView)
        view.addSubview(hiddenView)

        containerView.snp.makeConstraints { make in
            make.bottom.equalTo(view)
            make.left.equalTo(view.safeAreaLayoutGuide)
            make.right.equalTo(view.safeAreaLayoutGuide)
        }

        hiddenView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.bottom.equalTo(containerView.snp.top)
            make.left.equalTo(view.safeAreaLayoutGuide)
            make.right.equalTo(view.safeAreaLayoutGuide)
        }

        containerView.backgroundColor = .white

        containerView.addSubview(navigationView)
        containerView.addSubview(tableView)

        navigationView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }

        tableContentHeight = 40

        navigationView.addSubview(titleLabel)
        navigationView.addSubview(closeButton)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(18)
            make.right.equalTo(closeButton.snp.left).offset(-16)
        }

        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalToSuperview()
            make.width.equalTo(24)
            make.height.equalTo(24)
        }

        // чтобы адекватно показывать попап в высоту, нам нужно следить за размером таблицы, чтобы подстроиться под размер контента в ней
        tableView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old, .prior], context: nil)
    }

    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {

            if tableContentHeight != tableView.contentSize.height && tableView.contentSize.height >= 40 {
                tableContentHeight = tableView.contentSize.height

                let maxHeight = UIScreen.main.bounds.size.height / 4.0 * 3.0

                if tableContentHeight > maxHeight {
                    tableContentHeight = maxHeight
                }

                if tableView.frame.size.height != tableContentHeight {
                    tableView.snp.remakeConstraints { make in
                        make.top.equalTo(navigationView.snp.bottom)
                        make.bottom.equalTo(view.safeAreaLayoutGuide)
                        make.left.equalToSuperview()
                        make.right.equalToSuperview()
                        make.height.equalTo(tableContentHeight)
                    }
                }
            }
        }
    }

    private var tableContentHeight: CGFloat = 0

    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    @objc private func tapOnClose() {
        viewModel?.closePopUp()
    }
}

extension PromotionPopUpViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.numberOfRowsIn(section: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = dataSource.item(at: indexPath) else {
            return UITableViewCell()
        }
        switch (item) {
        case .aboutPromotion(let title):
            let cell = tableView.dequeueReusable(cell: PromotionPopUpAboutCell.self, for: indexPath)
            cell.text = title
            cell.selectionStyle = .none
            return cell
        case .info(let info):
            let cell = tableView.dequeueReusable(cell: PromotionPopUpInfoCell.self, for: indexPath)
            cell.text = info
            cell.selectionStyle = .none
            return cell
        case .articlePromotion(let data):
            let cell = tableView.dequeueReusable(cell: PromotionTableViewCell.self, for: indexPath)
            cell.viewModel = data
            cell.selectionStyle = .none
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.item(at: indexPath) else {
            return
        }
        switch (item) {
        case .articlePromotion(let data):
            tapPromoItem(data)
        default:
            break
        }
    }
}

extension PromotionPopUpViewController {
    private func tapPromoItem(_ model: PromotionTableViewCell.ViewModel) {
        // если не авторизован, и это не общая акция, нужно авторизоваться
        if model.type == .mustLogin {
            #if GOLD
            let authorization = Router.authorizationViewController(mode: .customer(.formSheet)) { [weak self] in
                guard let self = self else {
                    return
                }
                self.dismiss(animated: true, completion: nil)
                // в колбеке добавляем акцию
                self.addPromoItem(model)
            }
            authorization.modalPresentationStyle = .formSheet
            self.present(authorization, animated: true, completion: nil)
            #else
            addPromoItem(model)
            #endif
        } else {
            addPromoItem(model)
        }
    }

    func addPromoItem(_ model: PromotionTableViewCell.ViewModel) {
        viewModel?.addPromoItem(model)
    }
}
