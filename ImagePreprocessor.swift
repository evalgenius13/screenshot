import UIKit
import CoreImage

struct ImagePreprocessor {
    static func clean(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        let context = CIContext(options: nil)

        // 1. Grayscale
        let grayscale = ciImage.applyingFilter("CIPhotoEffectMono")

        // 2. Boost contrast
        let contrasted = grayscale.applyingFilter("CIColorControls", parameters: [
            kCIInputContrastKey: 1.4,
            kCIInputBrightnessKey: 0.0,
            kCIInputSaturationKey: 0.0
        ])

        // 3. Sharpen slightly
        let sharpened = contrasted.applyingFilter("CISharpenLuminance", parameters: [
            kCIInputSharpnessKey: 0.5
        ])

        if let cgImage = context.createCGImage(sharpened, from: sharpened.extent) {
            return UIImage(cgImage: cgImage)
        }
        return image
    }
}

