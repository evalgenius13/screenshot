import UIKit
import CoreData
import Photos

class ScreenshotImporter: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    // MARK: - Import One
    func importScreenshot(data: Data, assetIdentifier: String? = nil) {
        guard let uiImage = UIImage(data: data) else { return }

        if let assetIdentifier = assetIdentifier,
           let existing = alreadyImported(assetIdentifier),
           existing.status == "done" {
            print("⏩ Skipped reprocessing:", assetIdentifier)
            return
        }

        let entity = ScreenshotEntity(context: context)
        entity.id = UUID()
        entity.date = Date()
        entity.folder = fetchOrCreateCategory(named: "Other") // default
        entity.status = "pending"
        entity.assetIdentifier = assetIdentifier

        if let path = uiImage.saveToDocumentsAsJPEG(uuid: entity.id!) {
            entity.fullImagePath = path
        }

        if let thumb = UIImage.downscaled(from: data, maxDimension: 600),
           let thumbData = thumb.jpegData(compressionQuality: 0.8) {
            entity.thumbnail = thumbData
        }

        do { try context.save() } catch { print("❌ Save failed:", error) }

        DispatchQueue.global(qos: .userInitiated).async {
            OCRCategorizer.process(image: uiImage) { result in
                let text = result?.text ?? ""
                print("🔍 OCR Output for \(assetIdentifier ?? "unknown"): \(text)")

                // ✅ Social filter
                if !Self.looksSocial(text) {
                    print("⏩ Uncategorized screenshot, moved to Other:", assetIdentifier ?? "unknown")
                    self.updateEntity(entity, with: "Other", ocrText: text)
                    return
                }


                // Proceed with classification if social
                AIClassifier.classifyText(text, context: self.context) { aiCategory in
                    print("📂 Classified Category for \(assetIdentifier ?? "unknown"): \(aiCategory)")
                    self.updateEntity(entity, with: aiCategory, ocrText: text)
                }
            }
        }
    }

    // MARK: - Social Detection
    private static func looksSocial(_ text: String) -> Bool {
        let lower = text.lowercased()

        let markers = [
            "@", "#", "like", "likes", "views", "comments", "shares", "followers",
            "follow", "subscribe", "shop", "explore", "profile", "for you",
            "friends", "inbox", "join the conversation"
        ]

        for marker in markers {
            if lower.contains(marker) {
                return true
            }
        }
        return false
    }

    // MARK: - Import All
    func importAllScreenshots() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }

            let collections = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum,
                subtype: .smartAlbumScreenshots,
                options: nil
            )

            collections.enumerateObjects { collection, _, _ in
                let assets = PHAsset.fetchAssets(in: collection, options: nil)
                assets.enumerateObjects { asset, _, _ in
                    let options = PHImageRequestOptions()
                    options.isSynchronous = false
                    options.deliveryMode = .highQualityFormat
                    options.version = .current

                    PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                        if let data = data {
                            DispatchQueue.main.async {
                                self.importScreenshot(data: data, assetIdentifier: asset.localIdentifier)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        importAllScreenshots()
    }

    // MARK: - Helpers
    private func updateEntity(_ entity: ScreenshotEntity, with categoryName: String, ocrText: String) {
        self.context.perform {
            let finalCategory = categoryName.isEmpty ? "Other" : categoryName.capitalized
            entity.folder = self.fetchOrCreateCategory(named: finalCategory)
            entity.ocrText = ocrText
            entity.status = "done"

            do {
                try self.context.save()
                print("✅ Saved \(entity.assetIdentifier ?? "unknown") into category: \(finalCategory)")
            } catch {
                print("❌ Update failed:", error)
            }
        }
    }

    private func fetchOrCreateCategory(named name: String) -> CategoryEntity {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name ==[c] %@", name)
        if let existing = try? context.fetch(request).first { return existing }

        let newCategory = CategoryEntity(context: context)
        newCategory.id = UUID()
        newCategory.name = name
        newCategory.isSystem = (name.caseInsensitiveCompare("Other") == .orderedSame)
        newCategory.sortOrder = Int64(Date().timeIntervalSince1970)
        try? context.save()
        return newCategory
    }

    private func alreadyImported(_ id: String) -> ScreenshotEntity? {
        let request: NSFetchRequest<ScreenshotEntity> = ScreenshotEntity.fetchRequest()
        request.predicate = NSPredicate(format: "assetIdentifier == %@", id)
        return (try? context.fetch(request))?.first
    }

    // MARK: - Reset (Screenshots Only)
    func resetLibrary() {
        self.context.perform {
            let fetchScreens = NSFetchRequest<NSFetchRequestResult>(entityName: "ScreenshotEntity")
            let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchScreens)
            _ = try? self.context.execute(batchDelete)

            do {
                try self.context.save()
            } catch {
                print("❌ Reset failed:", error)
            }

            DispatchQueue.main.async {
                self.importAllScreenshots()
            }
        }
    }
}

