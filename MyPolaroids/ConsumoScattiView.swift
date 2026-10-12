import SwiftUI

struct ConsumoScattiView: View {
    let fotocamera: Camera
    @ObservedObject var viewModel: FilmPackViewModel
    @Binding var selectedTab: Int
    @State private var numeroScatti: Int
    @State private var recordFeedback = false
    @Environment(\.dismiss) private var dismiss

    init(fotocamera: Camera, viewModel: FilmPackViewModel, selectedTab: Binding<Int>) {
        self.fotocamera = fotocamera
        self.viewModel = viewModel
        self._selectedTab = selectedTab
        self._numeroScatti = State(initialValue: 1)
    }

    private var pacco: FilmPack? {
        viewModel.filmCaricato(in: fotocamera)
    }

    var scattiDisponibili: Int {
        pacco?.scattiRimanenti ?? 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let pacco {
                    VStack(spacing: 10) {
                        Text("\(pacco.tipo) · \(pacco.modello)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        ShotFrames(remaining: pacco.scattiRimanenti, total: pacco.scattiTotali, frameSize: 14)
                    }
                }

                if scattiDisponibili > 0 {
                    HStack(spacing: 28) {
                        Button {
                            withAnimation(.snappy) {
                                numeroScatti = max(1, numeroScatti - 1)
                            }
                        } label: {
                            Image(systemName: "minus")
                                .glassCircleButton()
                        }
                        .buttonStyle(.plain)
                        .disabled(numeroScatti <= 1)
                        .accessibilityLabel("Fewer shots")

                        Text("\(numeroScatti)")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .frame(minWidth: 64)

                        Button {
                            withAnimation(.snappy) {
                                numeroScatti = min(scattiDisponibili, numeroScatti + 1)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .glassCircleButton()
                        }
                        .buttonStyle(.plain)
                        .disabled(numeroScatti >= scattiDisponibili)
                        .accessibilityLabel("More shots")
                    }
                    .padding(.vertical, 8)
                } else {
                    Text("No shots available")
                        .font(.title2)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 8)
                }

                Spacer(minLength: 0)

                Button("Record \(numeroScatti) shot\(numeroScatti == 1 ? "" : "s")") {
                    confermaScatti()
                }
                .buttonStyle(.primaryBox)
                .disabled(scattiDisponibili == 0)
            }
            .padding(DS.margin)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Take Shots")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
            }
        }
        .tint(.primary)
        .presentationDetents([.medium])
        .interactiveDismissDisabled()
        .sensoryFeedback(.success, trigger: recordFeedback)
        .onChange(of: scattiDisponibili) { _, nuovo in
            if nuovo > 0 && numeroScatti > nuovo {
                numeroScatti = nuovo
            }
        }
    }

    private func confermaScatti() {
        guard scattiDisponibili > 0 else { return }

        // Remember the pack type before consuming: a finished pack is removed by the view model.
        let paccoPrima = viewModel.filmCaricato(in: fotocamera)
        let tipoPacco = paccoPrima?.tipo ?? ""
        let modelliPacco = paccoPrima?.modello ?? ""

        let filmFinito = viewModel.consumaScatti(numeroScatti, da: fotocamera)
        recordFeedback.toggle()

        if filmFinito {
            // If no packs of this type and model remain, go back to the Cameras tab.
            let pacchiRimanenti = viewModel.pacchiFilm.filter {
                $0.tipo == tipoPacco && $0.modello == modelliPacco
            }

            if pacchiRimanenti.isEmpty {
                selectedTab = 0
            }
        }
        dismiss()
    }
}

#Preview {
    ConsumoScattiView(
        fotocamera: Camera(
            nickname: "My Camera",
            modello: "Polaroid 600"
        ),
        viewModel: FilmPackViewModel(),
        selectedTab: .constant(0)
    )
}
