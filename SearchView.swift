//
//  SearchView.swift
//  Screenshot
//

import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var query = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScreenshotEntity.date, ascending: false)],
        animation: .default
    ) private var screenshots: FetchedResults<ScreenshotEntity>
    
    var filtered: [ScreenshotEntity] {
        guard !query.isEmpty else { return [] }
        return screenshots.filter {
            ($0.ocrText?.localizedCaseInsensitiveContains(query) ?? false) ||
            ($0.category?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search screenshots...", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if filtered.isEmpty && !query.isEmpty {
                    Text("No results found")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(filtered) { shot in
                            if let data = shot.thumbnail, let uiImage = UIImage(data: data) {
                                NavigationLink(destination: ScreenshotViewer(screenshot: shot)) {
                                    HStack {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(6)
                                        VStack(alignment: .leading) {
                                            Text(shot.category ?? "Other")
                                                .font(.headline)
                                            Text(shot.ocrText ?? "")
                                                .lineLimit(1)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

