import UIKit
import CoreImage

extension ScreenshotEntity {
    /// Disabled: always return false so no screenshots are excluded
    var isLikelyTextScreenshot: Bool {
        return false
    }
}

