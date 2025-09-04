import SwiftUI
import Photos

struct ScreenshotDetailView: View {
    let screenshot: ScreenshotEntity
    @State private var fullImage: UIImage? = nil

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                if let fullImage = fullImage {
                    Image(uiImage: fullImage)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                } else if let thumbData = screenshot.thumbnail,
                          let thumb = UIImage(data: thumbData) {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                        .onAppear { loadFullImage() }
                } else {
                    ProgressView("Loading…")
                }

                // Debug category label
                Text("Category: \(screenshot.category ?? "Unknown")")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
