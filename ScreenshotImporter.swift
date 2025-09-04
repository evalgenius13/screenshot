import Foundation
import Photos
import UIKit
import CoreData

class ScreenshotImporter {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Import all screenshots from the iOS "Screenshots" smart album
    func importScreenshots() {
        let screenshotsAlbum = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumScreenshots,
            options: nil
        )

        guard let album = screenshotsAlbum.firstObject else {
            print("⚠️ No screenshots album found")
            return
        }

        let assets = PHAsset.fetchAssets(in: album, options: nil)
        assets.enumerateObjects { asset, _, _ in
            self.process(asset: asset)
        }
    }

    /// Process a single screenshot PHAsset
    private func process(asset: PHAsset) {
        // Prevent duplicates by checking if we already saved this asset
        let fetchRequest: NSFetchRequest<ScreenshotEntity> = ScreenshotEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", asset.localIdentifier)

        if let count = try? context.count(for: fetchRequest), count > 0 {
            print("⏭ Skipping duplicate: \(asset.localIdentifier)")
            return
        }

        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat

        imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
            guard let data = data, let uiImage = UIImage(data: data) else {
                print("⚠️ Could not decode screenshot for asset \(asset.localIdentifier)")
                return
            }

            // Run OCR
            OCRCategorizer.process(image: uiImage) { result in
                guard let result = result else {
                    print("⚠️ OCR failed for asset \(asset.localIdentifier)")
                    return
                }

                // Classify with AI (via Vercel API)
                AIClassifier.classifyText(result.text) { aiCategory in
                    self.context.perform {
                        let screenshot = ScreenshotEntity(context: self.context)
                        screenshot.id = asset.localIdentifier
                        screenshot.date = asset.creationDate ?? Date()
                        screenshot.thumbnail = data
                        screenshot.ocrText = result.text
                        screenshot.category = aiCategory

                        do {
                            try self.context.save()
                            print("✅ Saved screenshot: \(asset.localIdentifier) → \(aiCategory)")
                        } catch {
                            print("❌ Core Data save failed: \(error)")
                        }
                    }
                }
            }
        }
    }
}

