//
//  CategoriesView.swift
//  Screenshot
//

import SwiftUI
import CoreData

struct CategoriesView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScreenshotEntity.category, ascending: true)],
        animation: .default
    ) private var screenshots: FetchedResults<ScreenshotEntity>
    
    var grouped: [String: [ScreenshotEntity]] {
        Dictionary(grouping: screenshots, by: { $0.category ?? "Other" })
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(grouped.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(grouped[category] ?? []) { shot in
                                    if let data = shot.thumbnail, let uiImage = UIImage(data: data) {
                                        NavigationLink(destination: ScreenshotViewer(screenshot: shot)) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Categories")
        }
    }
}

#Preview {
    CategoriesView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

