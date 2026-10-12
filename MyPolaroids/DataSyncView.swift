import SwiftUI

struct DataSyncView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataDownloader = DataDownloader.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var cameraModelsCount = 0
    @State private var filmTypesCount = 0
    @State private var filmModelsCount = 0
    @State private var cacheExpiryDate: Date?

    var body: some View {
        NavigationStack {
            Form {
                Section("Catalog") {
                    LabeledContent("Camera models", value: "\(cameraModelsCount)")
                    LabeledContent("Film types", value: "\(filmTypesCount)")
                    LabeledContent("Film models", value: "\(filmModelsCount)")
                    LabeledContent("Last update", value: formatted(dataDownloader.lastUpdateDate))
                    LabeledContent("Cache expiry", value: formatted(cacheExpiryDate))
                }

                Section {
                    Button {
                        syncData()
                    } label: {
                        HStack {
                            Text("Refresh now")
                            Spacer()
                            if dataDownloader.isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(dataDownloader.isLoading)

                    Button("Clear cache", role: .destructive) {
                        clearCache()
                    }
                    .disabled(dataDownloader.isLoading)
                } footer: {
                    Text("The catalog is downloaded when the app opens and kept locally for offline use.")
                }
            }
            .navigationTitle("Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
            .alert("Information", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .tint(.primary)
        .presentationDetents([.large])
        .onAppear(perform: reloadCounts)
    }

    private func formatted(_ date: Date?) -> String {
        guard let date else { return "–" }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    private func reloadCounts() {
        cameraModelsCount = dataDownloader.loadFromCache(
            forKey: DataConfig.UserDefaultsKeys.cameraModelsCache,
            type: [CameraModel].self
        )?.count ?? 0
        filmTypesCount = dataDownloader.loadFromCache(
            forKey: DataConfig.UserDefaultsKeys.filmPackTypesCache,
            type: [FilmPackType].self
        )?.count ?? 0
        filmModelsCount = dataDownloader.loadFromCache(
            forKey: DataConfig.UserDefaultsKeys.filmPackModelsCache,
            type: [FilmPackModel].self
        )?.count ?? 0
        cacheExpiryDate = UserDefaults.standard.object(forKey: DataConfig.UserDefaultsKeys.cacheExpirationDate) as? Date
    }

    private func syncData() {
        Task {
            do {
                async let cameras = dataDownloader.downloadCameraModels()
                async let filmPacks = dataDownloader.downloadFilmPackModels()

                let (_, _) = try await (cameras, filmPacks)

                await MainActor.run {
                    reloadCounts()
                    alertMessage = "Data synced successfully!"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    reloadCounts()
                    alertMessage = "Error during sync: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }

    private func clearCache() {
        dataDownloader.clearCache()
        reloadCounts()
        alertMessage = "Cache cleared successfully!"
        showingAlert = true
    }
}

#Preview {
    DataSyncView()
}
