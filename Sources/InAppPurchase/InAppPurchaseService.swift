import Foundation
import StoreKit

public class InAppPurchaseService: NSObject {
    public enum Result {
        case purchased
        case restored
        case failed(Int)

        public var userMessage: String {
            switch self {
            case .purchased:
                return "Thank you!"
            case .restored:
                return "Thank you! Restoring succeeded!"
            case let .failed(id):
                return """
                An error occurred.
                Please try again later.
                (Error ID: \(id))
                """
            }
        }
    }

    public enum Purchase: String, CaseIterable {
        case adFree = "jp.po_miyasaka.RouletteAnalytics.hiddingAd"

        public var id: String {
            rawValue
        }
    }

    static let `default` = InAppPurchaseService()
    private let request = SKProductsRequest(productIdentifiers: Set(Purchase.allCases.map(\.id)))
    private let refresh = SKReceiptRefreshRequest()
    private var products: [SKProduct] = []
    private var buyDelegate: Delegate?
    private var restoreDelegate: Delegate?
    private var productsContinuation: CheckedContinuation<[SKProduct], Never>?

    private func fetchProducts() async {
        if !products.isEmpty {
            return
        }

        products = await withCheckedContinuation { [weak self] continuation in
            self?.productsContinuation = continuation
            request.cancel()
            request.delegate = self
            request.start()
        }
    }

    public lazy var buy: (Purchase) async -> InAppPurchaseService.Result = { [weak self] purchase in
        await self?.fetchProducts()
        guard let product = self?.products.first(where: { $0.productIdentifier == purchase.id }) else {
            return .failed(1)
        }

        return await withCheckedContinuation { [weak self] continuation in

            guard let self else {
                continuation.resume(returning: Result.failed(2))
                return
            }

            if SKPaymentQueue.canMakePayments() {
                let delegate = Delegate(continuation: continuation)
                self.buyDelegate = delegate
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(delegate)
                SKPaymentQueue.default().add(payment)
            } else {
                continuation.resume(returning: InAppPurchaseService.Result.failed(3))
            }
        }
    }

    public lazy var restore: () async -> InAppPurchaseService.Result = {
        await withCheckedContinuation { [weak self] continuation in

            guard let self else {
                continuation.resume(returning: Result.failed(4))
                return
            }

            if SKPaymentQueue.canMakePayments() {
                let delegate = Delegate(continuation: continuation)
                self.restoreDelegate = delegate
                SKPaymentQueue.default().add(delegate)
                SKPaymentQueue.default().restoreCompletedTransactions()

            } else {
                continuation.resume(returning: InAppPurchaseService.Result.failed(5))
            }
        }
    }

    class Delegate: NSObject, SKPaymentTransactionObserver {
        private var continuation: CheckedContinuation<InAppPurchaseService.Result, Never>?
        convenience init(continuation: CheckedContinuation<InAppPurchaseService.Result, Never>) {
            self.init()
            self.continuation = continuation
        }

        public func paymentQueue(_: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            for transaction in transactions {
                switch transaction.transactionState {
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    continuation?.resume(returning: .failed(6))
                    continuation = nil
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    continuation?.resume(returning: .purchased)
                    continuation = nil
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    continuation?.resume(returning: .restored)
                    continuation = nil
                default:
                    break
                }
            }
        }
    }
}

extension InAppPurchaseService: SKProductsRequestDelegate {
    public func productsRequest(_: SKProductsRequest, didReceive response: SKProductsResponse) {
        productsContinuation?.resume(returning: response.products)
        productsContinuation = nil
    }
}
