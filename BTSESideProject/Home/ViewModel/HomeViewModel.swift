import Foundation
import RxSwift
import RxCocoa

class HomeViewModel: NSObject, ViewModelType {
    private(set) var input: Input!
    private(set) var output: Output!

    private var homeItem: BehaviorSubject<[HomeItem]> = .init(value: [])
    private var contentArray: BehaviorRelay<[String: [String]]> = .init(value: [:])

    let reload = PublishSubject<Void>()
    let disposeBag = DisposeBag()

    deinit {
        debugPrint(self, "deinit")
    }

    override init() {
        super.init()
        getMarket()
        input = Input(reload: reload.asObserver())
        output = Output(homeItem: homeItem.asDriver(onErrorJustReturn: []),
                        contentArray: contentArray.asDriver(onErrorJustReturn: [:]))
    }
    func getMarket() {
        API.shared.getMarket { [weak self] _, result in
            var content: [String: [String]] = [:]
            if let result = result as? MarketModelResponse, result.success {
                content.updateValue(result.data.filter { !$0.future }.map { $0.symbol }, forKey: SegmentKey.spot.rawValue)
                content.updateValue(result.data.filter { $0.future }.map { $0.symbol }, forKey: SegmentKey.futures.rawValue)
            }
            self?.contentArray.accept(content)
        }
    }
}
extension HomeViewModel {
    struct Input {
        let reload: AnyObserver<Void>
    }

    struct Output {
        let homeItem: Driver<[HomeItem]>
        let contentArray: Driver<[String: [String]]>
    }
}
