import SwiftUI
import CoreData

struct ScreenshotDetailView: View {
    let screenshot: ScreenshotEntity

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let image = loadFullImage(for: screenshot) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 4)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.headline)

                    Text("ID: \(screenshot.id?.uuidString ?? "unknown")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let date = screenshot.date {
                        Text("Date: \(date.formatted(date: .long, time: .shortened))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let folderName = screenshot.folder?.name {
                        Text("Folder: \(folderName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Screenshot")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadFullImage(for screenshot: ScreenshotEntity) -> UIImage? {
        guard let path = screenshot.fullImagePath else { return nil }
        let url = URL(fileURLWithPath: path)
        return UIImage.downscaled(from: url, maxDimension: 1200)
    }
}

