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

    var body: some View {
        NavigationView {
            ScrollView {
                CategoriesGrid(
                    categories: Array(categories),
                    onRename: { showingRenameAlert = $0 },
                    onDelete: deleteCategory
                )
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
            .alert("New Folder", isPresented: $showingAddAlert) {
                TextField("Folder Name", text: $newFolderName)
                Button("Add") { addCategory() }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Rename Folder", isPresented: Binding(
                get: { showingRenameAlert != nil },
                set: { if !$0 { showingRenameAlert = nil } }
            )) {
                TextField("New Name", text: $newFolderName)
                Button("Save") { renameCategory() }
                Button("Cancel", role: .cancel) {}
            }
        }
        .onAppear {
            if let category = showingRenameAlert {
                newFolderName = category.name ?? ""
            }
        }
        .onChange(of: showingRenameAlert) { category in
            if let category = category {
                newFolderName = category.name ?? ""
            }
        }
    }
    
    // MARK: - Category Management
    private func addCategory() {
        let newCategory = CategoryEntity(context: context)
        newCategory.id = UUID()
        newCategory.name = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        newCategory.isSystem = false
        newCategory.sortOrder = Int64(categories.count)
        
        do {
            try context.save()
            newFolderName = ""
        } catch {
            print("Failed to add category: \(error)")
        }
    }
    
    private func renameCategory() {
        guard let category = showingRenameAlert else { return }
        category.name = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try context.save()
            newFolderName = ""
            showingRenameAlert = nil
        } catch {
            print("Failed to rename category: \(error)")
        }
    }
    
    private func deleteCategory(_ category: CategoryEntity) {
        context.delete(category)
        do {
            try context.save()
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
}

// MARK: - Extracted Grid
struct CategoriesGrid: View {
    let categories: [CategoryEntity]
    let onRename: (CategoryEntity) -> Void
    let onDelete: (CategoryEntity) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(categories, id: \.objectID) { category in
                CategoryTileWrapper(
                    category: category,
                    onRename: { onRename(category) },
                    onDelete: { onDelete(category) }
                )
            }
        }
    }
}

// MARK: - Wrapper for Context Menu
struct CategoryTileWrapper: View {
    let category: CategoryEntity
    let onRename: () -> Void
    let onDelete: () -> Void

    var body: some View {
        NavigationLink(destination: CategoryDetailView(category: category)) {
            CategoryTile(category: category)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            if !category.isSystem {
                Button(action: onRename) { Label("Rename", systemImage: "pencil") }
                Button(role: .destructive, action: onDelete) { Label("Delete Folder", systemImage: "trash") }
            }
        }
    }
}

// MARK: - Category Tile
struct CategoryTile: View {
    let category: CategoryEntity

    var body: some View {
        VStack(spacing: 8) {
            if let screenshots = category.screenshots as? Set<ScreenshotEntity> {
                let sorted = screenshots.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }

                if let first = sorted.first,
                   let data = first.thumbnail,
                   let uiImage = UIImage.downscaled(from: data, maxDimension: 600) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing))
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
    }
}

