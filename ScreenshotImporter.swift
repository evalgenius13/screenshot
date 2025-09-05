import Foundation
import CoreData
import UIKit

class ScreenshotImporter {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Imports screenshot with thumbnail (Core Data) + full image (disk).
    func importScreenshot(data: Data, category: CategoryEntity? = nil) {
        let entity = ScreenshotEntity(context: context)
        entity.id = UUID().uuidString
        entity.date = Date()
        entity.folder = category

        // MARK: - Save full image to disk
        let fileName = "\(entity.id).jpg"
        let fileURL = ScreenshotImporter.fullImageDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            entity.fullImagePath = fileURL.path
        } catch {
            print("❌ Failed to save full screenshot: \(error)")
        }

        // MARK: - Save thumbnail
        if let uiImage = UIImage(data: data),
           let thumbData = uiImage.asThumbnailData(maxDimension: 200) {
            entity.thumbnail = thumbData
        } else {
            entity.thumbnail = data // fallback
        }

        do {
            try context.save()
        } catch {
            print("❌ Failed to import screenshot: \(error.localizedDescription)")
        }
    }

    /// Directory where full screenshots are stored
    static var fullImageDirectory: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("FullScreenshots", isDirectory: true)

        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }()
}

// MARK: - UIImage helper for thumbnails
extension UIImage {
    func asThumbnailData(maxDimension: CGFloat = 200) -> Data? {
        let largestSide = max(size.width, size.height)
        guard largestSide > 0 else { return nil }

        let scale = maxDimension / largestSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized?.jpegData(compressionQuality: 0.7)
    }
}

