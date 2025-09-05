import SwiftUI
import CoreData

struct ScreenshotPreviewView: View {
    let screenshots: [ScreenshotEntity]
    @Binding var selectedIndex: Int
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var cache: [UUID: UIImage] = [:]
    @State private var prefetching = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if !screenshots.isEmpty {
                TabView(selection: $selectedIndex) {
                    ForEach(screenshots.indices, id: \.self) { index in
                        if let image = loadImage(for: screenshots[index]) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .tag(index)
                        } else {
                            Rectangle()
                                .fill(Color.black)
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .onChange(of: selectedIndex) { newIndex in
                    prefetchSurrounding(index: newIndex)
                }
                .onAppear {
                    prefetchSurrounding(index: selectedIndex)
                }
            }
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9))
                    .padding()
            }
        }
    }
    
    // MARK: - Image Loading
    
    private func loadImage(for screenshot: ScreenshotEntity) -> UIImage? {
        guard let id = screenshot.id else { return nil }
        
        // ✅ Use cached image first
        if let cached = cache[id] {
            return cached
        }
        
        // ✅ Try full-size image from disk
        if let path = screenshot.fullImagePath {
            let url = URL(fileURLWithPath: path)
            if let image = UIImage.downscaled(from: url, maxDimension: 1200) {
                cache[id] = image
                return image
            }
        }
        
        // ✅ Fallback to thumbnail if full image missing
        if let thumbData = screenshot.thumbnail,
           let thumb = UIImage(data: thumbData) {
            cache[id] = thumb
            return thumb
        }
        
        return nil
    }
    
    // MARK: - Prefetch
    
    private func prefetchSurrounding(index: Int) {
        guard !prefetching else { return }
        prefetching = true
        DispatchQueue.global(qos: .background).async {
            let neighbors = [index - 1, index + 1]
            for i in neighbors where screenshots.indices.contains(i) {
                _ = loadImage(for: screenshots[i])
            }
            DispatchQueue.main.async { prefetching = false }
        }
    }
    
    // MARK: - Delete
    
    private func deleteScreenshot(_ screenshot: ScreenshotEntity) {
        context.delete(screenshot)
        do {
            try context.save()
        } catch {
            print("❌ Failed to delete screenshot:", error)
        }
    }
}

