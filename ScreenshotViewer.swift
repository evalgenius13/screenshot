//
//  ScreenshotViewer.swift
//  Screenshot
//

import SwiftUI

struct ScreenshotViewer: View {
    let screenshot: ScreenshotEntity
    
    var body: some View {
        ScrollView {
            VStack {
                if let data = screenshot.thumbnail, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recognized Text")
                        .font(.headline)
                    Text(screenshot.ocrText ?? "No text recognized")
                        .font(.body)
                    
                    Button(action: {
                        UIPasteboard.general.string = screenshot.ocrText
                    }) {
                        Label("Copy Text", systemImage: "doc.on.doc")
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Screenshot")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // Fake preview data
    let context = PersistenceController.shared.container.viewContext
    let shot = ScreenshotEntity(context: context)
    shot.ocrText = "Example recognized text"
    shot.category = "Test"
    
    return NavigationView {
        ScreenshotViewer(screenshot: shot)
    }
}

