//
//  HomeView.swift
//  Screenshot
//

import SwiftUI
import CoreData

struct HomeView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScreenshotEntity.date, ascending: false)],
        animation: .default
    ) private var screenshots: FetchedResults<ScreenshotEntity>
    
    var body: some View {
        NavigationView {
            Group {
                if screenshots.isEmpty {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .padding()
                        Text("No screenshots found")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                            ForEach(screenshots) { shot in
                                if let data = shot.thumbnail, let uiImage = UIImage(data: data) {
                                    NavigationLink(destination: ScreenshotViewer(screenshot: shot)) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Recent")
        }
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

