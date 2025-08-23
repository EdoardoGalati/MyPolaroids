import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Sfondo per la safe area
                AppColors.backgroundPrimary
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
                            AppColors.tabBarGradient.opacity(0),
                            AppColors.tabBarGradient.opacity(1),
                            AppColors.tabBarGradient
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
                                    Image("polaroid.600.fill.symbols")
                                        .font(.system(size: 32))
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(selectedTab == 0 ? AppColors.accentPrimary : AppColors.accentSecondary)
                                }
                                
                                // Pallino sotto la tab attiva
                                if selectedTab == 0 {
                                    Circle()
                                        .fill(AppColors.accentPrimary)
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
                                    Image("polaroid.film.symbols")
                                        .font(.system(size: 32))
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(selectedTab == 1 ? AppColors.accentPrimary : AppColors.accentSecondary)
                                }
                                
                                // Pallino sotto la tab attiva
                                if selectedTab == 1 {
                                    Circle()
                                        .fill(AppColors.accentPrimary)
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
        .background(AppColors.backgroundPrimary)
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
        .environmentObject(CameraViewModel())
}
