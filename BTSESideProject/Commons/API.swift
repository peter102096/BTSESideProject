import UIKit
import Alamofire

class API: NSObject {
    public static let shared = API()
    private var trustIP: String = "api.btse.com"
    private lazy var sharedSession: Session = {
        let manager = ServerTrustManager(evaluators: [trustIP: DisabledTrustEvaluator()])
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        return Session(configuration: configuration, serverTrustManager: manager)
    }()
    var statusCode: Int? = 404

    private override init() {
        super.init()
    }

    public func getMarket(completion: @escaping (Int?, Codable?) -> Void) {
        connectToServer(url: "https://api.btse.com/futures/api/inquire/initial/market", dataStruct: MarketModelResponse.self, completion: completion)
    }

    public func connectToServer<T: Codable>(url: String, method: HTTPMethod = .get, dataStruct struct: T.Type, params: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default, completion: @escaping (Int?, Codable?) -> Void) {
        statusCode = 404
        let headers: HTTPHeaders?

        headers = nil

        sharedSession.request(url, method: method, parameters: params, encoding: encoding, headers: headers).responseDecodable(of: T.self) { [unowned self] (data) in
            statusCode = data.response?.statusCode
            print("statusCode : \(statusCode ?? 9999)")
            switch data.result {
            case .success(_):
                completion(statusCode, data.value)
                break
            case .failure(_):
                debugPrint(self, "connectToServer failure")
                if data.error == nil {
                    let errorData = ResultModel(result: "Data decode failed")
                    completion(statusCode, errorData)
                } else {
                    let errorData = ResultModel(result: "\(data.error!.localizedDescription)")
                    completion(statusCode, errorData)
                }
                break
            }
        }
    }
}
