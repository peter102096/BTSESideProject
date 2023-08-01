import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum SegmentKey: String {
    case spot = "Spot"
    case futures = "Futures"
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
        let label = UILabel()
            .setText("依照名稱: ")
            .setTextColor(.black)
            .setBackgroundColor(.clear)
        view.addSubview(sortSegmentControl)
        sortSegmentControl.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalTo(sortSegmentControl)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(sortSegmentControl.snp.leading)
        }
        view.addSubview(typeSegmentControl)
        typeSegmentControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(sortSegmentControl.snp.bottom).inset(-16)
        }
        view.addSubview(dataTableView)
        dataTableView.snp.makeConstraints {
            $0.top.equalTo(typeSegmentControl.snp.bottom).inset(-16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }
        return view
    }()
    
    lazy var typeSegmentControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.insertSegment(withTitle: "Spot", at: 0, animated: true)
        control.insertSegment(withTitle: "Futures", at: 1, animated: true)
        control.selectedSegmentIndex = 0
        return control
    }()
    lazy var sortSegmentControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.insertSegment(withTitle: "Ascending", at: 0, animated: true)
        control.insertSegment(withTitle: "Descending", at: 1, animated: true)
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
    
    var current: SegmentKey = .spot
    var sort: SortOrder = .ascending
    
    var symbolContent: [String: [String]] = [:]
    var content: [HomeItem] = []
    let disposeBag = DisposeBag()
    
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
        sortSegmentControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                if let self = self {
                    if index == 0 {
                        self.sort = .ascending
                        self.content = self.content.sorted { (item1, item2) in
                            return item1.name < item2.name
                        }
                    }
                    if index == 1 {
                        self.sort = .descending
                        self.content = self.content.sorted { (item1, item2) in
                            return item1.name > item2.name
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        typeSegmentControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                if index == 0 {
                    self?.current = .spot
                }
                if index == 1 {
                    self?.current = .futures
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
                    switch self.sort {
                    case .ascending:
                        self.content = response.data.filter { self.symbolContent[self.current.rawValue]!.contains($0.value.name) && $0.value.type == 1 }.homeItems
                            .sorted { (item1, item2) in
                                return item1.name < item2.name
                            }
                    case .descending:
                        self.content = response.data.filter { self.symbolContent[self.current.rawValue]!.contains($0.value.name) && $0.value.type == 1 }.homeItems
                            .sorted { (item1, item2) in
                                return item1.name > item2.name
                            }
                    }
                    self.dataTableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
    }
}

