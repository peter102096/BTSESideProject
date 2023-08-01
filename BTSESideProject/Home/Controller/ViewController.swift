import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum SegmentKey: String {
    case spot = "Spot"
    case futures = "Futures"
}

enum SortOrderType {
    case name
    case price
}

enum SortOrder {
    case descending
    case ascending
}

class ViewController: UIViewController {
    
    lazy var contentView: UIView = {
        let view = UIView()
            .setBackgroundColor(.white)
            .setCornerRadius(24)
        view.addSubview(sortView)
        sortView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        view.addSubview(typeSegmentControl)
        typeSegmentControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(sortView.snp.bottom).inset(-16)
        }
        view.addSubview(dataTableView)
        dataTableView.snp.makeConstraints {
            $0.top.equalTo(typeSegmentControl.snp.bottom).inset(-16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
        return view
    }()

    lazy var sortView: UIView = {
        let titleLabel = UILabel()
            .setText("依照 ")
            .setTextColor(.black)
            .setBackgroundColor(.clear)
            .setTextAlignment(.center)
        let view = UIView()
        view.addSubview(sortTypeSegmentControl)
        sortTypeSegmentControl.snp.makeConstraints {
            $0.top.equalToSuperview().inset(36)
            $0.width.equalTo(self.view.bounds.width * 0.3)
            $0.trailing.lessThanOrEqualToSuperview().inset(-16)
        }
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(sortTypeSegmentControl)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(sortTypeSegmentControl.snp.leading).inset(-6)
        }
        view.addSubview(sortSegmentControl)
        sortSegmentControl.snp.makeConstraints {
            $0.top.equalTo(sortTypeSegmentControl.snp.bottom).inset(-16)
            $0.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        return view
    }()

    lazy var sortTypeSegmentControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.insertSegment(withTitle: "名稱", at: 0, animated: true)
        control.insertSegment(withTitle: "價錢", at: 1, animated: true)
        control.selectedSegmentIndex = 0
        control.contentVerticalAlignment = .center
        return control
    }()

    lazy var sortSegmentControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.insertSegment(withTitle: "Ascending", at: 0, animated: true)
        control.insertSegment(withTitle: "Descending", at: 1, animated: true)
        control.selectedSegmentIndex = 0
        return control
    }()

    lazy var typeSegmentControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.insertSegment(withTitle: "Spot", at: 0, animated: true)
        control.insertSegment(withTitle: "Futures", at: 1, animated: true)
        control.selectedSegmentIndex = 0
        return control
    }()

    lazy var dataTableView: UITableView = {
        UITableView()
            .setRegister(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")
            .setSeparatorStyle(.none)
            .setDataSource(self)
            .setDelegate(self)
    }()
    lazy var viewModel: HomeViewModel = {
        HomeViewModel()
    }()
    
    var current: BehaviorRelay<SegmentKey> = .init(value: .spot)
    var sortType: BehaviorRelay<SortOrderType> = .init(value: .name)
    var sort: BehaviorRelay<SortOrder> = .init(value: .ascending)
    
    var symbolContent: [String: [String]] = [:]
    var content: [HomeItem] = []
    let disposeBag = DisposeBag()
    internal let lock = NSLock()
    internal var threadLock = pthread_rwlock_t()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataTableView.reloadData()
    }
    
    func setupUI() {
        view.setBackgroundColor(.black)
        view.addSubview(contentView)

        contentView.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(6)
        }

        sortTypeSegmentControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                if let self = self {
                    if index == 0 {
                        self.sortType.accept(.name)
                    }
                    if index == 1 {
                        self.sortType.accept(.price)
                    }
                    self.sortContent()
                }
            })
            .disposed(by: disposeBag)

        sortSegmentControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                if let self = self {
                    if index == 0 {
                        self.sort.accept(.ascending)
                    }
                    if index == 1 {
                        self.sort.accept(.descending)
                    }
                    self.sortContent()
                }
            })
            .disposed(by: disposeBag)

        typeSegmentControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                if index == 0 {
                    self?.current.accept(.spot)
                }
                if index == 1 {
                    self?.current.accept(.futures)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindingUI() {
        rx.viewDidAppear
            .mapToVoid()
            .bind(to: viewModel.input.reload)
            .disposed(by: disposeBag)

        viewModel.output.contentArray
            .drive(onNext: { [weak self] content in
                self?.symbolContent = content
                self?.dataTableView.reloadData()
            })
            .disposed(by: disposeBag)
        WebSocketModel.shared.receivedMessage
            .subscribe(onNext: { [weak self] response in
                if let self = self {
                    pthread_rwlock_wrlock(&threadLock)
                    switch self.sort.value {
                    case .ascending:
                        self.content = response.data.filter { self.symbolContent[self.current.value.rawValue]!.contains($0.value.name) && $0.value.type == 1 }.homeItems
                    case .descending:
                        self.content = response.data.filter { self.symbolContent[self.current.value.rawValue]!.contains($0.value.name) && $0.value.type == 1 }.homeItems
                    }
                    self.sortContent()
                    pthread_rwlock_unlock(&threadLock)
                }
            })
            .disposed(by: disposeBag)
    }
    func sortContent() {
        switch self.sort.value {
        case .ascending:
            content = content.sorted { [unowned self] (item1, item2) in
                switch self.sortType.value {
                case .name:
                    return item1.name < item2.name
                case .price:
                    return item1.price < item2.price
                }
            }
        case .descending:
            content = content.sorted { [unowned self] (item1, item2) in
                switch self.sortType.value {
                case .name:
                    return item1.name > item2.name
                case .price:
                    return item1.price > item2.price
                }
            }
        }
        self.dataTableView.reloadData()
    }
}
