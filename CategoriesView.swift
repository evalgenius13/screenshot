import SwiftUI
import CoreData

struct CategoriesView: View {
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.sortOrder, ascending: true)],
        animation: .default
    ) private var categories: FetchedResults<CategoryEntity>

    @State private var showingAddAlert = false
    @State private var showingRenameAlert: CategoryEntity? = nil
    @State private var newFolderName = ""

    // ✅ Order: non-empty → empty → Other last
    private var orderedCategories: [CategoryEntity] {
        let nonEmpty = categories.filter { hasValidThumbnail($0) && $0.name != "Other" }
        let empty = categories.filter { !hasValidThumbnail($0) && $0.name != "Other" }
        let other = categories.filter { $0.name == "Other" }
        return nonEmpty + empty + other
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(orderedCategories, id: \.self) { category in
                        CategoryTile(category: category)
                            .contextMenu {
                                if !category.isSystem {
                                    Button {
                                        showingRenameAlert = category
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }

                                    Button(role: .destructive) {
                                        deleteCategory(category)
                                    } label: {
                                        Label("Delete Folder", systemImage: "trash")
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddAlert = true }) {
                        Label("Add Folder", systemImage: "plus")
                    }
                }
            }
            // Add Folder
            .alert("New Folder", isPresented: $showingAddAlert) {
                TextField("Folder Name", text: $newFolderName)
                Button("Add", action: addFolder)
                Button("Cancel", role: .cancel) {}
            }
            // Rename Folder
            .alert("Rename Folder", isPresented: Binding(
                get: { showingRenameAlert != nil },
                set: { if !$0 { showingRenameAlert = nil } }
            )) {
                TextField("New Name", text: $newFolderName)
                Button("Save") {
                    if let folder = showingRenameAlert {
                        folder.name = newFolderName
                        try? context.save()
                    }
                    newFolderName = ""
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Folder management
    private func addFolder() {
        guard !newFolderName.isEmpty else { return }
        let folder = CategoryEntity(context: context)
        folder.id = UUID()
        folder.name = newFolderName
        folder.isSystem = false
        folder.sortOrder = Int64(categories.count + 1)
        try? context.save()
        newFolderName = ""
    }

    private func deleteCategory(_ category: CategoryEntity) {
        context.delete(category)
        try? context.save()
    }

    private func hasValidThumbnail(_ category: CategoryEntity) -> Bool {
        guard let screenshots = category.screenshots as? Set<ScreenshotEntity> else { return false }
        return screenshots.contains { screenshot in
            if screenshot.isLikelyTextScreenshot { return false }
            if let data = screenshot.thumbnail,
               let uiImage = UIImage(data: data),
               !isDarkOrFlat(uiImage) {
                return true
            }
            return false
        }
    }
}

// MARK: - Category Tile
struct CategoryTile: View {
    let category: CategoryEntity
    @State private var selectedIndex: Int? = nil
    @State private var screenshotsArray: [ScreenshotEntity] = []

    var body: some View {
        VStack(spacing: 8) {
            if let screenshots = category.screenshots as? Set<ScreenshotEntity> {
                let filtered = screenshots
                    .filter { !$0.isLikelyTextScreenshot }
                    .sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
                    .filter {
                        if let data = $0.thumbnail,
                           let uiImage = UIImage(data: data) {
                            return !isDarkOrFlat(uiImage)
                        }
                        return false
                    }

                if let first = filtered.first,
                   let data = first.thumbnail,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .onTapGesture {
                            screenshotsArray = Array(filtered)
                            selectedIndex = 0
                        }
                } else {
                    // Gradient fallback
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 160)
                        .overlay(
                            Text(category.name ?? "Folder")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        )
                }
            }

            Text(category.name ?? "Other")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .fullScreenCover(isPresented: Binding(
            get: { selectedIndex != nil },
            set: { if !$0 { selectedIndex = nil } }
        )) {
            if let i = selectedIndex {
                ScreenshotPreviewView(
                    screenshots: screenshotsArray,
                    selectedIndex: Binding(
                        get: { i },
                        set: { selectedIndex = $0 }
                    )
                )
            }
        }
    }
}

