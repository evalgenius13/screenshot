import UIKit
import CoreData
import Photos

class ScreenshotImporter: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        PHPhotoLibrary.shared().register(self) // ✅ auto-import
    }

    /// Import a single screenshot
    func importScreenshot(data: Data, assetIdentifier: String? = nil) {
        guard let uiImage = UIImage(data: data) else { return }

        // Deduplication check
        if let assetIdentifier = assetIdentifier, alreadyImported(assetIdentifier) {
            print("⏩ Skipped duplicate:", assetIdentifier)
            return
        }

        let entity = ScreenshotEntity(context: context)
        entity.id = UUID()
        entity.date = Date()
        entity.folder = fetchOrCreateCategory(named: "Other") // ✅ always same Other
        entity.status = "pending"
        entity.assetIdentifier = assetIdentifier

        // ✅ Always save as JPEG to ensure consistency
        if let path = uiImage.saveToDocumentsAsJPEG(uuid: entity.id!) {
            entity.fullImagePath = path
        }

        if let thumb = UIImage.downscaled(from: data, maxDimension: 600),
           let thumbData = thumb.jpegData(compressionQuality: 0.8) {
            entity.thumbnail = thumbData
        }

        do { try context.save() } catch { print("❌ Save failed:", error) }

        // Run OCR + AI in background
        DispatchQueue.global(qos: .userInitiated).async {
            OCRCategorizer.process(image: uiImage) { result in
                let text = result?.text ?? ""
                AIClassifier.classifyText(text) { aiCategory in
                    DispatchQueue.main.async {
                        self.updateEntity(entity, with: aiCategory, ocrText: text)
                    }
                }
            }
        }
    }

    /// Import all existing screenshots
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
        importAllScreenshots() // ✅ auto-import new screenshots
    }

    // MARK: - Helpers

    private func updateEntity(_ entity: ScreenshotEntity, with categoryName: String, ocrText: String) {
        let finalCategory = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameToUse = finalCategory.isEmpty ? "Other" : finalCategory
        entity.folder = fetchOrCreateCategory(named: nameToUse)
        entity.ocrText = ocrText
        entity.status = "done"

        do { try context.save() } catch { print("❌ Update failed:", error) }
    }

    /// Always reuse the same CategoryEntity, especially for "Other"
    private func fetchOrCreateCategory(named name: String) -> CategoryEntity {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        // Case-insensitive match ensures "other" and "Other" are treated the same
        request.predicate = NSPredicate(format: "name ==[c] %@", name)

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let newCategory = CategoryEntity(context: context)
        newCategory.id = UUID()
        newCategory.name = name
        newCategory.isSystem = (name.caseInsensitiveCompare("Other") == .orderedSame)
        newCategory.sortOrder = Int64(Date().timeIntervalSince1970)

        do { try context.save() } catch {
            print("❌ Failed to save category:", error)
        }

        return newCategory
    }

    private func alreadyImported(_ id: String) -> Bool {
        let request: NSFetchRequest<ScreenshotEntity> = ScreenshotEntity.fetchRequest()
        request.predicate = NSPredicate(format: "assetIdentifier == %@", id)
        return (try? context.count(for: request)) ?? 0 > 0
    }
}

