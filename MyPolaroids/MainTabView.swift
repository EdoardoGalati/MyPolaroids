import SwiftUI

struct MainTabView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Cameras", image: "polaroid.600.fill.symbols", value: 0) {
                NavigationStack {
                    ListaFotocamereView(viewModel: cameraViewModel, selectedTab: $selectedTab)
                }
            }

            Tab("Film", image: "polaroid.film.symbols", value: 1) {
                if let filmPackViewModel = cameraViewModel.filmPackViewModel {
                    NavigationStack {
                        TipologiePacchiFilmView(viewModel: filmPackViewModel, selectedTab: $selectedTab)
                    }
                } else {
                    EmptyView()
                }
            }
        }
        .tint(.primary)
        .onAppear {
            if cameraViewModel.filmPackViewModel == nil {
                cameraViewModel.setupFilmPackViewModel()
            }
        }
    }
}

#Preview {
    MainTabView()
}
