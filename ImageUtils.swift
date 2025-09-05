import UIKit
import CoreImage

/// Utility to detect if a screenshot thumbnail is too dark or too flat.
func isDarkOrFlat(_ image: UIImage) -> Bool {
    guard let cgImage = image.cgImage else { return true }
    let ciImage = CIImage(cgImage: cgImage)
    let extent = ciImage.extent
    let context = CIContext(options: [.useSoftwareRenderer: false])

    guard let filter = CIFilter(
        name: "CIAreaAverage",
        parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: extent)
        ]
    ),
    let output = filter.outputImage else {
        return true
    }

    var bitmap = [UInt8](repeating: 0, count: 4)
    context.render(
        output,
        toBitmap: &bitmap,
        rowBytes: 4,
        bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
        format: .RGBA8,
        colorSpace: CGColorSpaceCreateDeviceRGB()
    )

    let r = Float(bitmap[0]) / 255.0
    let g = Float(bitmap[1]) / 255.0
    let b = Float(bitmap[2]) / 255.0
    let brightness = (r + g + b) / 3.0

    if brightness < 0.05 { return true } // too dark
    if abs(r - g) < 0.02 && abs(r - b) < 0.02 { return true } // too flat
    return false
}

