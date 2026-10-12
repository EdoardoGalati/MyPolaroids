import SwiftUI
import Combine

struct DettagliFotocameraView: View {
    @Environment(\.dismiss) private var dismiss
    let fotocamera: Camera
    @ObservedObject var viewModel: CameraViewModel
    @Binding var selectedTab: Int
    @State private var mostraModifica = false
    @State private var mostraDeleteAlert = false
    @State private var mostraCaricaFilm = false
    @State private var mostraConsumoScatti = false
    @State private var mostraRimuoviFilm = false
    @State private var mostraFilmFinito = false
    @State private var refreshTrigger = false
    @State private var mostraScartaPacco = false

    private var paccoCaricato: FilmPack? {
        viewModel.filmPackViewModel?.filmCaricato(in: fotocamera)
    }

    private var formati: [String] {
        (fotocamera.filmType ?? "")
            .split(separator: "/")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                heroSection

                if let pacco = paccoCaricato {
                    loadedFilmCard(pacco: pacco)
                } else {
                    unloadedFilmCard
                }

                infoCard
            }
            .padding(DS.margin)
        }
        .groupedScreenBackground()
        .navigationTitle(fotocamera.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .tint(.primary)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        mostraModifica = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    if paccoCaricato != nil {
                        Button(role: .destructive) {
                            mostraScartaPacco = true
                        } label: {
                            Label("Discard Film Pack", systemImage: "xmark.rectangle")
                        }
                    }

                    Divider()

                    Button(role: .destructive) {
                        mostraDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .accessibilityLabel("More")
            }
        }
        .sheet(isPresented: $mostraModifica) {
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
        .sheet(isPresented: $mostraCaricaFilm) {
            CaricaFilmView(
                fotocamera: fotocamera,
                viewModel: viewModel.filmPackViewModel!
            )
            .onDisappear {
                refreshTrigger.toggle()
            }
        }
        .sheet(isPresented: $mostraConsumoScatti) {
            ConsumoScattiView(
                fotocamera: fotocamera,
                viewModel: viewModel.filmPackViewModel!,
                selectedTab: $selectedTab
            )
            .onDisappear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let pacco = viewModel.filmPackViewModel?.filmCaricato(in: fotocamera),
                       pacco.scattiRimanenti == 0 {
                        mostraFilmFinito = true
                    }
                }
            }
        }
        .alert("Delete Camera", isPresented: $mostraDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.rimuoviFotocamera(fotocamera)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete '\(fotocamera.displayName)'? This action cannot be undone.")
        }
        .alert("Remove Film", isPresented: $mostraRimuoviFilm) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                rimuoviFilm()
            }
        } message: {
            Text("Do you want to remove the film from '\(fotocamera.displayName)'?")
        }
        .alert("Film Completed", isPresented: $mostraFilmFinito) {
            Button("Load New Film") {
                mostraCaricaFilm = true
            }
            Button("Leave Empty", role: .cancel) { }
        } message: {
            Text("The film is finished! Do you want to load a new film or leave the camera empty?")
        }
        .alert("Discard Film Pack", isPresented: $mostraScartaPacco) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) {
                rimuoviFilm()
            }
        } message: {
            Text("Do you want to discard the film pack from '\(fotocamera.displayName)'?")
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 12) {
            CameraTile(symbol: fotocamera.icona, colorHex: fotocamera.coloreIcona, size: 120)

            VStack(spacing: 4) {
                Text(fotocamera.modello)
                    .font(.title2)
                    .fontDesign(.rounded)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("\(fotocamera.brand) · \(String(fotocamera.annoProduzione))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !formati.isEmpty {
                HStack(spacing: 6) {
                    ForEach(formati, id: \.self) { formato in
                        Chip(text: formato)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Film card (loaded)

    private func loadedFilmCard(pacco: FilmPack) -> some View {
        Card(title: "Film") {
            HStack(spacing: 12) {
                ColorWheelView(
                    gradient: FilmPackColors.gradientePerTipo(
                        pacco.tipo,
                        modello: pacco.modello,
                        modelliDisponibili: viewModel.filmPackViewModel?.modelliFilm ?? []
                    ),
                    size: 36
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(pacco.modello)
                        .font(.headline)
                    Text(pacco.tipo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                if pacco.isScaduto {
                    Chip(text: "Expired", systemImage: "clock", prominent: true)
                }
            }

            ShotFrames(remaining: pacco.scattiRimanenti, total: pacco.scattiTotali, frameSize: 18)
                .padding(.vertical, 4)

            Text("\(pacco.scattiRimanenti) shot\(pacco.scattiRimanenti == 1 ? "" : "s") left")
                .font(.subheadline)
                .contentTransition(.numericText())

            if let scadenza = pacco.dataScadenza {
                Text(pacco.isScaduto ? "Expired on \(scadenza.shortDisplay)" : "Expires \(scadenza.shortDisplay)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                Button("Take Shots") {
                    scattaFoto()
                }
                .buttonStyle(.primaryBox)
                .disabled(pacco.scattiRimanenti == 0)

                Button("Unload Film") {
                    mostraRimuoviFilm = true
                }
                .buttonStyle(.secondaryBox)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Film card (unloaded)

    private var unloadedFilmCard: some View {
        Card(title: "Film") {
            Text("No film loaded")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Load Film") {
                mostraCaricaFilm = true
            }
            .buttonStyle(.primaryBox)
            .padding(.top, 4)
        }
    }

    // MARK: - Info card

    private var infoCard: some View {
        Card(title: "Details") {
            InfoRow(label: "Model", value: fotocamera.modello)
            InfoRow(label: "Brand", value: fotocamera.brand)
            InfoRow(label: "Year", value: String(fotocamera.annoProduzione))
            InfoRow(label: "Film format", value: fotocamera.filmType ?? "Unknown")
            InfoRow(label: "Added", value: fotocamera.dataAggiunta.shortDisplay)
        }
    }

    // MARK: - Actions

    private func scattaFoto() {
        guard let pacco = paccoCaricato, pacco.scattiRimanenti > 0 else { return }
        mostraConsumoScatti = true
    }

    private func rimuoviFilm() {
        guard let pacco = paccoCaricato else { return }
        let tipoPacco = pacco.tipo
        let modelliPacco = pacco.modello

        viewModel.filmPackViewModel?.rimuoviFilmDaFotocamera(fotocamera)

        // If no packs of this type and model remain, go back to the Cameras tab.
        let pacchiRimanenti = viewModel.filmPackViewModel?.pacchiFilm.filter {
            $0.tipo == tipoPacco && $0.modello == modelliPacco
        } ?? []

        if pacchiRimanenti.isEmpty {
            selectedTab = 0
        }
    }
}

#Preview {
    NavigationStack {
        DettagliFotocameraView(
            fotocamera: Camera(
                nickname: "My Camera",
                modello: "Polaroid 600",
                coloreIcona: "000"
            ),
            viewModel: CameraViewModel(),
            selectedTab: .constant(0)
        )
    }
}
