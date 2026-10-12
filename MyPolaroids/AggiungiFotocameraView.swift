import SwiftUI

struct AggiungiFotocameraView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CameraViewModel

    @State private var searchText = ""
    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(sections, id: \.filmType) { section in
                    Section(section.filmType) {
                        ForEach(section.models, id: \.id) { modello in
                            NavigationLink(value: modello.id) {
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
            .searchable(text: $searchText, prompt: "Search cameras")
            .navigationTitle("Add Camera")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
            .navigationDestination(for: String.self) { modelID in
                if let modello = viewModel.modelliDisponibili.first(where: { $0.id == modelID }) {
                    PersonalizzazioneView(
                        modello: modello,
                        viewModel: viewModel,
                        onSave: { dismiss() }
                    )
                }
            }
        }
        .tint(.primary)
    }

    // MARK: - Row

    private func modelRow(_ modello: CameraModel) -> some View {
        HStack(spacing: 12) {
            CameraTile(symbol: modello.default_icon, colorHex: "000", size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(modello.name)
                    .font(.headline)
                Text("\(modello.brand) · \(String(modello.year_introduced)) · \(modello.capacity) \(modello.capacity == 1 ? "shot" : "shots")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Data

    private var fotocamereFiltrate: [CameraModel] {
        if searchText.isEmpty {
            return viewModel.modelliDisponibili
        }
        return viewModel.modelliDisponibili.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.model.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var sections: [(filmType: String, models: [CameraModel])] {
        AddCameraSections.grouped(fotocamereFiltrate)
    }
}

// MARK: - Grouping by film type

private enum AddCameraSections {
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

// MARK: - Step 2: customise

struct PersonalizzazioneView: View {
    let modello: CameraModel
    let viewModel: CameraViewModel
    let onSave: () -> Void

    @State private var nickname: String = ""
    @State private var coloreSelezionato: String = "000"
    @State private var didAdd = false

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    CameraTile(symbol: modello.default_icon, colorHex: coloreSelezionato, size: 120)
                        .animation(.snappy(duration: 0.2), value: coloreSelezionato)
                    Text(modello.name)
                        .font(.headline)
                    Text("\(modello.brand) · \(String(modello.year_introduced))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            Section("Name") {
                TextField(modello.name, text: $nickname)
            }

            Section("Color") {
                CameraColorPicker(selection: $coloreSelezionato)
            }
        }
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") { salvaFotocamera() }
            }
        }
        .sensoryFeedback(.success, trigger: didAdd)
        .tint(.primary)
    }

    private func salvaFotocamera() {
        let fotocamera = Camera(
            nickname: nickname.isEmpty ? "" : nickname,
            modello: modello.name,
            coloreIcona: coloreSelezionato,
            modelliDisponibili: viewModel.modelliDisponibili
        )
        viewModel.aggiungiFotocamera(fotocamera)
        didAdd = true
        onSave()
    }
}

#Preview {
    AggiungiFotocameraView(viewModel: CameraViewModel())
}
