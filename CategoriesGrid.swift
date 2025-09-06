import SwiftUI

struct CategoriesGrid: View {
    let categories: [CategoryEntity]
    var onRename: (CategoryEntity) -> Void
    var onDelete: (CategoryEntity) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(categories, id: \.self) { category in
                VStack(spacing: 12) {
                    Text(category.name ?? "Untitled")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    HStack {
                        Spacer()
                        Button(action: { onRename(category) }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        Button(action: { onDelete(category) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 100)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
            }
        }
    }
}

