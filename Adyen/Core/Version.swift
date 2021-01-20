//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The GYG prefix is added to deal with a name spacing issue. In the unforked version this variable is accessed via
/// `Adyen` as that is the name of the target. However for CocoaPods it has been renamed `AdyenLegacy`. As I do not want
/// to mess with target naming I'm simply prefixing this variable with `gyg` to remove the need to reference the module
/// name.
var gygSDKVersion: String {
    let bundle = Bundle(for: PaymentRequest.self)
    guard let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String else {
        fatalError("Failed to read version number from Info.plist.")
    }
    
    return version
}
