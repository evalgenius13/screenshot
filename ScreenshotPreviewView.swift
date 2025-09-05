import SwiftUI

struct ScreenshotPreviewView: View {
    let screenshots: [ScreenshotEntity]
    @Binding var selectedIndex: Int
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $selectedIndex) {
                ForEach(screenshots.indices, id: \.self) { index in
                    if let fullImage = loadFullImage(for: screenshots[index]) {
                        Image(uiImage: fullImage)
                            .resizable()
                            .scaledToFit()
                            .tag(index)
                            .background(Color.black.ignoresSafeArea())
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .background(Color.black.ignoresSafeArea())

            // Close
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                    .padding()
            }

            // Delete
            VStack {
                Spacer()
                Button(role: .destructive) {
                    deleteScreenshot(at: selectedIndex)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .font(.headline)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.bottom, 30)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }

    private func loadFullImage(for screenshot: ScreenshotEntity) -> UIImage? {
        if let path = screenshot.fullImagePath {
            let url = URL(fileURLWithPath: path)
            if let data = try? Data(contentsOf: url) {
                return UIImage(data: data)
            }
        }
        return nil
    }

    private func deleteScreenshot(at index: Int) {
        guard screenshots.indices.contains(index) else { return }
        let screenshot = screenshots[index]

        // Delete file from disk
        if let path = screenshot.fullImagePath {
            try? FileManager.default.removeItem(atPath: path)
        }

        // Delete from Core Data
        context.delete(screenshot)
        try? context.save()

        dismiss()
    }
}

