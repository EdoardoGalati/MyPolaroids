import SwiftUI

struct MainTabView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Sfondo per la safe area
                Color(red: 244/255, green: 244/255, blue: 244/255)
                    .ignoresSafeArea()
                
                TabView(selection: $selectedTab) {
                ListaFotocamereView(viewModel: cameraViewModel, selectedTab: $selectedTab)
                    .tag(0)
                
                if let filmPackViewModel = cameraViewModel.filmPackViewModel {
                    TipologiePacchiFilmView(viewModel: filmPackViewModel, selectedTab: $selectedTab)
                        .tag(1)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Tab bar custom in basso
            VStack {
                Spacer()
                
                // Tab bar personalizzata con gradiente sottostante
                ZStack {
                    // Gradiente sotto la tab bar
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 244/255, green: 244/255, blue: 244/255).opacity(0),
                            Color(red: 244/255, green: 244/255, blue: 244/255).opacity(1),
                            Color(red: 244/255, green: 244/255, blue: 244/255)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    
                    // Tab bar personalizzata sopra il gradiente
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 24) {
                            // Tab Fotocamere
                            VStack(spacing: 4) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedTab = 0
                                    }
                                }) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 24))
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(selectedTab == 0 ? .black : .gray)
                                }
                                
                                // Pallino sotto la tab attiva
                                if selectedTab == 0 {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 4, height: 4)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 4, height: 4)
                                }
                            }
                            
                            // Tab Film Packs
                            VStack(spacing: 4) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedTab = 1
                                    }
                                }) {
                                    Image(systemName: "film.stack")
                                        .font(.system(size: 24))
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(selectedTab == 1 ? .black : .gray)
                                }
                                
                                // Pallino sotto la tab attiva
                                if selectedTab == 1 {
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 4, height: 4)
                                } else {
                                    Circle()
                                        .fill(Color.clear)
                                        .frame(width: 4, height: 4)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                }
            }
        }
        }
        .background(Color(red: 244/255, green: 244/255, blue: 244/255))
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            // Assicurati che il FilmPackViewModel sia configurato
            if cameraViewModel.filmPackViewModel == nil {
                cameraViewModel.setupFilmPackViewModel()
            }
        }
    }
}

#Preview {
    MainTabView()
}
