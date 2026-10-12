import SwiftUI
import Combine

struct ListaFotocamereView: View {
    @ObservedObject var viewModel: CameraViewModel
    @Binding var selectedTab: Int
    @State private var mostraAggiungiFotocamera = false
    @State private var mostraImpostazioni = false
    @State private var fotocameraDaModificare: Camera?
    @State private var fotocameraDaEliminare: Camera?
    @State private var deleteFeedback = false

    var body: some View {
        Group {
            if viewModel.fotocamere.isEmpty {
                EmptyState(
                    title: "No cameras",
                    message: "Add your first camera to start tracking film.",
                    image: "polaroid.600.fill.symbols",
                    isAsset: true,
                    actionTitle: "Add Camera",
                    action: { mostraAggiungiFotocamera = true }
                )
            } else {
                List {
                    ForEach(viewModel.fotocamereOrdinate) { fotocamera in
                        NavigationLink {
                            DettagliFotocameraView(
                                fotocamera: fotocamera,
                                viewModel: viewModel,
                                selectedTab: $selectedTab
                            )
                        } label: {
                            FotocameraRowView(
                                fotocamera: fotocamera,
                                pacco: viewModel.filmPackViewModel?.filmCaricato(in: fotocamera)
                            )
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                fotocameraDaEliminare = fotocamera
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                fotocameraDaModificare = fotocamera
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Cameras")
        .navigationBarTitleDisplayMode(.large)
        .tint(.primary)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    mostraImpostazioni = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    mostraAggiungiFotocamera = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Camera")
            }
        }
        .sheet(isPresented: $mostraAggiungiFotocamera) {
            AggiungiFotocameraView(viewModel: viewModel)
        }
        .sheet(isPresented: $mostraImpostazioni) {
            ImpostazioniView()
        }
        .sheet(item: $fotocameraDaModificare) { fotocamera in
            ModificaFotocameraView(
                fotocamera: Binding(
                    get: { fotocamera },
                    set: { newValue in
                        if let index = viewModel.fotocamere.firstIndex(where: { $0.id == fotocamera.id }) {
                            viewModel.fotocamere[index] = newValue
                        }
                    }
                ),
                viewModel: viewModel
            )
        }
        .alert(
            "Delete Camera",
            isPresented: Binding(
                get: { fotocameraDaEliminare != nil },
                set: { if !$0 { fotocameraDaEliminare = nil } }
            ),
            presenting: fotocameraDaEliminare
        ) { fotocamera in
            Button("Delete", role: .destructive) {
                withAnimation(.snappy) {
                    viewModel.rimuoviFotocamera(fotocamera)
                }
                deleteFeedback.toggle()
            }
            Button("Cancel", role: .cancel) { }
        } message: { fotocamera in
            Text("Are you sure you want to delete '\(fotocamera.displayName)'? This action cannot be undone.")
        }
        .sensoryFeedback(.success, trigger: deleteFeedback)
        .onReceive(viewModel.filmPackViewModel?.$pacchiFilm.eraseToAnyPublisher() ?? Just([FilmPack]()).eraseToAnyPublisher()) { _ in
            // Refresh rows when film packs change (loaded / unloaded / consumed).
            DispatchQueue.main.async {
                viewModel.objectWillChange.send()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            // Refresh when the sorting option changes in Settings.
            DispatchQueue.main.async {
                viewModel.objectWillChange.send()
            }
        }
    }

    struct FotocameraRowView: View {
        let fotocamera: Camera
        let pacco: FilmPack?

        private var subtitle: String {
            var parts: [String] = []
            if fotocamera.displayName != fotocamera.modello {
                parts.append(fotocamera.modello)
            }
            if let filmType = fotocamera.filmType, !filmType.isEmpty {
                parts.append(filmType)
            }
            if parts.isEmpty {
                parts.append(fotocamera.brand)
            }
            return parts.joined(separator: " · ")
        }

        var body: some View {
            HStack(spacing: 14) {
                CameraTile(symbol: fotocamera.icona, colorHex: fotocamera.coloreIcona, size: 56)

                VStack(alignment: .leading, spacing: 3) {
                    Text(fotocamera.displayName)
                        .font(.headline)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                if let pacco {
                    ShotsBadge(remaining: pacco.scattiRimanenti, total: pacco.scattiTotali)
                } else {
                    Chip(text: "No film")
                }
            }
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    NavigationStack {
        ListaFotocamereView(viewModel: CameraViewModel(), selectedTab: .constant(0))
    }
}
