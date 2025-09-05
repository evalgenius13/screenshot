import UIKit
import CoreImage

extension ScreenshotEntity {
    /// Heuristic: detect text-heavy screenshots (articles, chats, tweets).
    var isLikelyTextScreenshot: Bool {
        // 1. OCR text length check
        if (ocrText ?? "").count < 200 {
            return false
        }

        // 2. Thumbnail brightness check
        guard let data = thumbnail,
              let image = UIImage(data: data),
              let cgImage = image.cgImage else {
            return true // fallback: assume text if no image
        }

        let ciImage = CIImage(cgImage: cgImage)
        let extent = ciImage.extent
        let context = CIContext(options: [.useSoftwareRenderer: false])

        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: ciImage,
                                                 kCIInputExtentKey: CIVector(cgRect: extent)]),
              let outputImage = filter.outputImage else {
            return true
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())

        let r = Float(bitmap[0]) / 255.0
        let g = Float(bitmap[1]) / 255.0
        let b = Float(bitmap[2]) / 255.0
        let brightness = (r + g + b) / 3.0

        // Bright + long text = likely text screenshot
        return brightness > 0.85
    }
}

