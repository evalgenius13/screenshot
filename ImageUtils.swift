import UIKit
import ImageIO

extension UIImage {
    /// Downscale image data before decoding, for smooth scrolling & previews.
    static func downscaled(from data: Data, maxDimension: CGFloat) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ]

        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return UIImage(data: data) // fallback to full decode
        }

        return UIImage(cgImage: cgImage)
    }

    static func downscaled(from url: URL, maxDimension: CGFloat) -> UIImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [NSString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailFromImageAlways: true
        ]
        if let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    /// Save this image as JPEG in the app's Documents folder.
    /// Returns the file path string if successful.
    func saveToDocumentsAsJPEG(uuid: UUID, quality: CGFloat = 0.95) -> String? {
        guard let jpegData = self.jpegData(compressionQuality: quality),
              let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url = docs.appendingPathComponent("\(uuid.uuidString).jpg")
        do {
            try jpegData.write(to: url)
            return url.path
        } catch {
            print("❌ Failed to save JPEG:", error)
            return nil
        }
    }
}
