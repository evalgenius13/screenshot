import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ScreenshotEntity.date, ascending: false)],
        animation: .default
    )
    private var screenshots: FetchedResults<ScreenshotEntity>

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Home")
                            .font(.largeTitle.bold())
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(screenshots) { screenshot in
                                if let path = screenshot.fullImagePath,
                                   let image = UIImage(contentsOfFile: path) {
                                    NavigationLink(
                                        destination: ScreenshotDetailView(
                                            screenshot: screenshot,
                                            allScreenshots: Array(screenshots)
                                        )
                                    ) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: UIScreen.main.bounds.width / 2 - 15, height: 200)
                                            .clipped()
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100) // leave space for menu
                }

                // Shared bottom menu
                PhotoStyleAppMenu()
            }
            .navigationBarHidden(true)
        }
    }
}

