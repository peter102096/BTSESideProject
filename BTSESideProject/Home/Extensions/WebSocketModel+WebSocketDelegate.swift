import Starscream

extension WebSocketModel: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        switch event {
        case .connected(let dictionary):
            debugPrint(self, "connected: \(dictionary)")
            messageToSend.onNext(subscibeTopic)
        case .disconnected(let string, let uInt16):
            debugPrint(self, "disconnected: \(string), state: \(uInt16)")
        case .text(let string):
            do {
                guard let data = string.data(using: .utf8) else { return }
                let result = try JSONDecoder().decode(PriceModelResponse.self, from: data)
                receivedMessage.onNext(result)
            } catch {
                debugPrint(self, "error: \(error.localizedDescription)")
            }
        case .error(let error):
            debugPrint(self, "error: \(error?.localizedDescription ?? "expection")")
        case .cancelled:
            debugPrint(self, "cancelled")
        default:
            debugPrint(self, "\(event)")
        }
    }
}
