import SwiftUI

struct DataSyncView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataDownloader = DataDownloader.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section("Sync Status") {
                    HStack {
                        Image(systemName: dataDownloader.isLoading ? "arrow.clockwise" : "checkmark.circle")
                            .foregroundColor(dataDownloader.isLoading ? .orange : .green)
                            .rotationEffect(.degrees(dataDownloader.isLoading ? 360 : 0))
                            .animation(dataDownloader.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: dataDownloader.isLoading)
                        
                        VStack(alignment: .leading) {
                            Text(dataDownloader.isLoading ? "Syncing..." : "Synced")
                                .font(.headline)
                            if let lastUpdate = dataDownloader.lastUpdateDate {
                                Text("Last update: \(lastUpdate.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                Section("Actions") {
                    Button(action: syncData) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Sync Now")
                        }
                    }
                    .disabled(dataDownloader.isLoading)
                    
                    Button(action: clearCache) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear Cache")
                        }
                        .foregroundColor(.red)
                    }
                    .disabled(dataDownloader.isLoading)
                }
                
                Section("Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data is automatically downloaded when the app opens and saved locally for offline operation.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Cache is updated every time you manually sync.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Information", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
        .presentationDetents([.large])
    }
    
    private func syncData() {
        Task {
            do {
                // Sincronizza entrambi i tipi di dati
                async let cameras = dataDownloader.downloadCameraModels()
                async let filmPacks = dataDownloader.downloadFilmPackModels()
                
                let (_, _) = try await (cameras, filmPacks)
                
                await MainActor.run {
                    alertMessage = "Data synced successfully!"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Error during sync: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
            private func clearCache() {
            dataDownloader.clearCache()
            alertMessage = "Cache cleared successfully!"
            showingAlert = true
        }
}

#Preview {
    DataSyncView()
}
