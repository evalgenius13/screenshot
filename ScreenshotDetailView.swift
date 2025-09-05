import SwiftUI
import Photos

struct ScreenshotDetailView: View {
    let screenshot: ScreenshotEntity
    @State private var fullImage: UIImage? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let fullImage = fullImage {
                    Image(uiImage: fullImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else if let thumbData = screenshot.thumbnail,
                          let thumb = UIImage(data: thumbData) {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .onAppear { loadFullImage() }
                } else {
                    ProgressView("Loading…")
                }

                if let folder = screenshot.folder?.name {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Category")
                            .font(.headline)
                        Text(folder)
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationTitle("Screenshot")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadFullImage() {
        let assetId = screenshot.id ?? ""
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
        guard let asset = fetchResult.firstObject else { return }

        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            if let image = image {
                DispatchQueue.main.async { self.fullImage = image }
            }
        }
    }
}

