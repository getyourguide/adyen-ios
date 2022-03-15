//
//  ApplePayPayment.swift
//  AdyenComponents
//
//  Created by Vladimir Abramichev on 15/03/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Adyen
import Foundation
import PassKit

// MARK: - Apple Pay component configuration.

extension ApplePayComponent {

    public struct ApplePayPayment {
        public init(countryCode: String, currencyCode: String, summaryItems: [PKPaymentSummaryItem]) throws {
            guard CountryCodeValidator().isValid(countryCode) else {
                throw Error.invalidCountryCode
            }
            guard CurrencyCodeValidator().isValid(currencyCode) else {
                throw Error.invalidCurrencyCode
            }
            guard summaryItems.count > 0 else {
                throw Error.emptySummaryItems
            }
            guard let lastItem = summaryItems.last, lastItem.amount.doubleValue >= 0 else {
                throw Error.negativeGrandTotal
            }
            guard summaryItems.filter({ $0.amount.isEqual(to: NSDecimalNumber.notANumber) }).count == 0 else {
                throw Error.invalidSummaryItem
            }

            self.countryCode = countryCode
            self.currencyCode = currencyCode
            self.summaryItems = summaryItems
        }

        init(payment: Payment, localeIdentifier: String?) throws {
            let decimalValue = AmountFormatter.decimalAmount(payment.amount.value,
                                                             currencyCode: currencyCode,
                                                             localeIdentifier: localeIdentifier)

            try self.init(countryCode: payment.countryCode,
                          currencyCode: payment.amount.currencyCode,
                          summaryItems: [PKPaymentSummaryItem(label: localizedString(.amount, <#T##parameters: LocalizationParameters?##LocalizationParameters?#>, <#T##arguments: CVarArg...##CVarArg#>),
                                                              amount: decimalValue)])
        }

        /// The amount for this payment.
        public var amount: Payment {
            guard let decimalAmountValue = summaryItems.last?.amount.decimalValue else {
                assertionFailure(Error.emptySummaryItems.localizedDescription)
            }

            Payment(amount: Amount(value: AmountFormatter.minorUnitAmount(from: decimalAmountValue, currencyCode: <#T##String#>, localeIdentifier: <#T##String?#>),
                                   currencyCode: currencyCode,
                                   localeIdentifier: <#T##String?#> ),
                    countryCode: countryCode)

        }

        /// The code of the country in which the payment is made.
        public let countryCode: String

        /// The code of the currency in which the amount's value is specified.
        public let currencyCode: String

        /// The public key used for encrypting card details.
        public let summaryItems: [PKPaymentSummaryItem]

    }

}
