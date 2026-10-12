import SwiftUI

struct ModificaFotocameraView: View {
    @Binding var fotocamera: Camera
    @ObservedObject var viewModel: CameraViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var nickname: String
    @State private var modelloSelezionato: String
    @State private var coloreSelezionato: String
    @State private var mostraSelezioneModello: Bool = false
    @State private var didSave = false

    init(fotocamera: Binding<Camera>, viewModel: CameraViewModel) {
        self._fotocamera = fotocamera
        self.viewModel = viewModel
        self._nickname = State(initialValue: fotocamera.wrappedValue.nickname.isEmpty ? "" : fotocamera.wrappedValue.nickname)
        self._modelloSelezionato = State(initialValue: fotocamera.wrappedValue.modello)
        self._coloreSelezionato = State(initialValue: fotocamera.wrappedValue.coloreIcona)
    }

    private var modelloCorrente: CameraModel? {
        viewModel.modelliDisponibili.first(where: { $0.name == modelloSelezionato })
    }

    private var iconaCorrente: String {
        if let modelloCorrente { return modelloCorrente.default_icon }
        return modelloSelezionato == fotocamera.modello ? fotocamera.icona : "camera.fill"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CameraTile(symbol: iconaCorrente, colorHex: coloreSelezionato, size: 96)
                        .animation(.snappy(duration: 0.2), value: coloreSelezionato)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .listRowBackground(Color.clear)
                }

                Section("Name") {
                    TextField(modelloSelezionato, text: $nickname)
                }

                Section("Model") {
                    Button {
                        mostraSelezioneModello = true
                    } label: {
                        HStack {
                            Text(modelloSelezionato)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Section("Color") {
                    CameraColorPicker(selection: $coloreSelezionato)
                }
            }
            .navigationTitle("Edit Camera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { salvaModifiche() }
                }
            }
            .sheet(isPresented: $mostraSelezioneModello) {
                SelezioneModelloView(
                    modelloSelezionato: $modelloSelezionato,
                    modelliDisponibili: viewModel.modelliDisponibili
                )
            }
        }
        .tint(.primary)
        .presentationDetents([.large])
        .sensoryFeedback(.success, trigger: didSave)
    }

    private func salvaModifiche() {
        var fotocameraAggiornata = fotocamera
        fotocameraAggiornata.nickname = nickname.isEmpty ? "" : nickname
        fotocameraAggiornata.modello = modelloSelezionato
        fotocameraAggiornata.coloreIcona = coloreSelezionato
        fotocameraAggiornata.brand = Camera.brandDefault(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)
        fotocameraAggiornata.annoProduzione = Camera.annoProduzioneDefault(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)

        // When the model changes, refresh the model-derived fields too so the
        // glyph, capacity and film format follow the new model.
        if modelloSelezionato != fotocamera.modello {
            fotocameraAggiornata.capienza = Camera.calcolaCapienza(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)
            fotocameraAggiornata.icona = Camera.iconaDefault(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)
            fotocameraAggiornata.immagine = Camera.immagineDefault(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)
            fotocameraAggiornata.filmType = Camera.filmTypeDefault(modello: modelloSelezionato, modelliDisponibili: viewModel.modelliDisponibili)
        }

        viewModel.aggiornaFotocamera(fotocameraAggiornata)
        didSave = true
        dismiss()
    }
}

// MARK: - Model picker

struct SelezioneModelloView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var modelloSelezionato: String
    let modelliDisponibili: [CameraModel]

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(sections, id: \.filmType) { section in
                    Section(section.filmType) {
                        ForEach(section.models, id: \.id) { modello in
                            Button {
                                modelloSelezionato = modello.name
                                dismiss()
                            } label: {
                                modelRow(modello)
                            }
                        }
                    }
                }
            }
            .overlay {
                if sections.isEmpty, !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .searchable(text: $searchText, prompt: "Search models")
            .navigationTitle("Select Model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
        }
        .tint(.primary)
    }

    private func modelRow(_ modello: CameraModel) -> some View {
        HStack(spacing: 12) {
            CameraTile(symbol: modello.default_icon, colorHex: "000", size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(modello.name)
                    .font(.headline)
                Text("\(modello.brand) · \(String(modello.year_introduced)) · \(modello.capacity) shots")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if modelloSelezionato == modello.name {
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }

    private var modelliFiltrati: [CameraModel] {
        if searchText.isEmpty {
            return modelliDisponibili
        }
        return modelliDisponibili.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.model.localizedCaseInsensitiveContains(searchText) ||
            $0.brand.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var sections: [(filmType: String, models: [CameraModel])] {
        EditCameraSections.grouped(modelliFiltrati)
    }
}

// MARK: - Grouping by film type

private enum EditCameraSections {
    static let priority = ["i-Type", "600", "SX-70", "Go", "Spectra"]

    static func rank(_ filmType: String) -> Int {
        if let index = priority.firstIndex(of: filmType) { return index * 2 }
        if let index = priority.firstIndex(where: { filmType.localizedCaseInsensitiveContains($0) }) {
            return index * 2 + 1
        }
        return priority.count * 2
    }

    static func grouped(_ models: [CameraModel]) -> [(filmType: String, models: [CameraModel])] {
        let groups = Dictionary(grouping: models, by: { $0.film_type })
        let keys = groups.keys.sorted { a, b in
            let ra = rank(a), rb = rank(b)
            if ra != rb { return ra < rb }
            return a.localizedStandardCompare(b) == .orderedAscending
        }
        return keys.map { key in
            (filmType: key, models: (groups[key] ?? []).sorted { $0.year_introduced > $1.year_introduced })
        }
    }
}

#Preview {
    let viewModel = CameraViewModel()
    return ModificaFotocameraView(
        fotocamera: .constant(Camera(
            nickname: "My Polaroid",
            modello: "600",
            modelliDisponibili: viewModel.modelliDisponibili
        )),
        viewModel: viewModel
    )
}
