//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// A component that handles voucher action's.
internal protocol AnyVoucherActionHandler: ActionComponent {
    func handle(_ action: VoucherAction)
}

/// A component that handles voucher action's.
public final class VoucherComponent: AnyVoucherActionHandler {

    /// Delegates `ViewController`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?

    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?

    /// :nodoc:
    public let requiresModalPresentation: Bool = true

    /// The Component UI style.
    public let style: AwaitComponentStyle

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    /// :nodoc:
    private var voucherViewControllerProvider: AnyVoucherViewControllerProvider?

    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter style: The Component UI style.
    public init(style: AwaitComponentStyle?) {
        self.style = style ?? AwaitComponentStyle()
    }

    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter style: The Component UI style.
    internal convenience init(voucherViewControllerProvider: AnyVoucherViewControllerProvider?,
                              style: AwaitComponentStyle?) {
        self.init(style: style)
        self.voucherViewControllerProvider = voucherViewControllerProvider
    }

    /// :nodoc:
    private let componentName = "voucher"

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: VoucherAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, environment: environment)

        var viewControllerProvider = voucherViewControllerProvider ?? VoucherViewControllerProvider()
        viewControllerProvider.localizationParameters = localizationParameters

        let viewController = viewControllerProvider.provide(with: action)

        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self, viewController: viewController)
            presentationDelegate.present(component: presentableComponent, disableCloseButton: false)
        } else {
            assertionFailure("presentationDelegate is nil, please provide a presentation delegate to present the VoucherComponent UI.")
        }
    }

}
