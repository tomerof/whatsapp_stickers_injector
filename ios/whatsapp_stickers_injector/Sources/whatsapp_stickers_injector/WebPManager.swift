//
// Copyright (c) WhatsApp Inc. and its affiliates.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.
//

import UIKit
import SDWebImageWebPCoder

class WebPManager {

    static let shared: WebPManager = WebPManager()

    func isAnimated(webPData data: Data) -> Bool {
        guard let duration = self.decode(webPData: data)?.duration else {
            return false
        }
        
        return duration > 0
    }
    
    func decode(webPData data: Data) -> UIImage? {
        return SDImageWebPCoder.shared.decodedImage(with: data, options: nil)
    }

    func encode(pngData data: Data) -> Data? {
        return SDImageWebPCoder.shared.encodedData(with: UIImage(data: data), format: .webP)
    }
}
