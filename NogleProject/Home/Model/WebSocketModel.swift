import Foundation
import RxCocoa
import Starscream
import RxSwift

class WebSocketModel: NSObject {

    static let shared = WebSocketModel()
    private let socket: WebSocket
    private let disposeBag = DisposeBag()

    let subscibeTopic = "{\"op\": \"subscribe\", \"args\": [\"coinIndex\"]}"
    // Input
    let messageToSend: BehaviorSubject<String> = .init(value: "")
    // Output
    let receivedMessage = PublishSubject<PriceModelResponse>()

    private override init() {
        socket = WebSocket(request: URLRequest(url: URL(string: "wss://ws.btse.com/ws/futures")!))
        socket.connect()

        super.init()
        socket.delegate = self
        messageToSend
            .subscribe { [weak self] msg in
                self?.socket.write(string: msg, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}
