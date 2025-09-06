import SwiftUI

struct ScreenshotDetailView: View {
    @ObservedObject var screenshot: ScreenshotEntity
    @Environment(\.dismiss) private var dismiss
    @State private var showChrome: Bool = true
    var allScreenshots: [ScreenshotEntity]
    @State private var currentIndex: Int = 0

    init(screenshot: ScreenshotEntity, allScreenshots: [ScreenshotEntity]) {
        self.screenshot = screenshot
        self.allScreenshots = allScreenshots
        if let index = allScreenshots.firstIndex(of: screenshot) {
            _currentIndex = State(initialValue: index)
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Screenshot(s) with swipe support
            if !allScreenshots.isEmpty {
                TabView(selection: $currentIndex) {
                    ForEach(allScreenshots.indices, id: \.self) { index in
                        screenshotImage(for: allScreenshots[index])
                            .tag(index)
                            .onTapGesture {
                                withAnimation { showChrome.toggle() }
                            }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            } else {
                screenshotImage(for: screenshot)
                    .onTapGesture {
                        withAnimation { showChrome.toggle() }
                    }
            }

            // Top chrome overlay
            if showChrome {
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        if let date = screenshot.date {
                            Text(date, style: .date)
                                .foregroundColor(.primary)
                                .font(.subheadline)
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .frame(height: 50)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .top)

                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .statusBar(hidden: !showChrome) // Hide status bar when chrome is hidden
        .onAppear {
            if let index = allScreenshots.firstIndex(of: screenshot) {
                currentIndex = index
            }
        }
    }

    // MARK: - Screenshot image renderer
    private func screenshotImage(for entity: ScreenshotEntity) -> some View {
        Group {
            if let path = entity.fullImagePath,
               let image = UIImage(contentsOfFile: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else if let thumbData = entity.thumbnail,
                      let thumb = UIImage(data: thumbData) {
                Image(uiImage: thumb)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}

