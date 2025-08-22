import SwiftUI

struct ICloudSyncView: View {
    @StateObject private var cloudKitManager = CloudKitManager()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // Sezione stato iCloud
                Section("Stato iCloud") {
                    HStack {
                        Image(systemName: cloudKitManager.isSignedInToiCloud ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(cloudKitManager.isSignedInToiCloud ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cloudKitManager.isSignedInToiCloud ? "Connesso a iCloud" : "Non connesso a iCloud")
                                .font(.headline)
                            Text(cloudKitManager.isSignedInToiCloud ? "I tuoi dati si sincronizzeranno automaticamente" : "Accedi a iCloud per sincronizzare i dati")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Sezione sincronizzazione
                Section("Sincronizzazione") {
                    HStack {
                        Image(systemName: cloudKitManager.isSyncing ? "arrow.clockwise" : "checkmark.circle.fill")
                            .foregroundColor(cloudKitManager.isSyncing ? .blue : .green)
                            .rotationEffect(.degrees(cloudKitManager.isSyncing ? 360 : 0))
                            .animation(cloudKitManager.isSyncing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: cloudKitManager.isSyncing)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cloudKitManager.isSyncing ? "Sincronizzazione in corso..." : "Sincronizzazione completata")
                                .font(.headline)
                            if let lastSync = cloudKitManager.lastSyncDate {
                                Text("Ultima sincronizzazione: \(lastSync, style: .relative) fa")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Pulsante sincronizzazione manuale
                    Button(action: {
                        Task {
                            await performManualSync()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Sincronizza ora")
                        }
                    }
                    .disabled(cloudKitManager.isSyncing || !cloudKitManager.isSignedInToiCloud)
                }
                
                // Sezione errori
                if let error = cloudKitManager.syncError {
                    Section("Errore") {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Errore di sincronizzazione")
                                    .font(.headline)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Sezione informazioni
                Section("Informazioni") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• I tuoi dati si sincronizzano automaticamente quando apporti modifiche")
                        Text("• La sincronizzazione avviene in background")
                        Text("• Assicurati di avere una connessione internet stabile")
                        Text("• La prima sincronizzazione potrebbe richiedere più tempo")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Sincronizzazione iCloud")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await performManualSync()
            }
        }
        .alert("Sincronizzazione", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Actions
    private func performManualSync() async {
        print("☁️ [ICloudSyncView] 🚀 Inizio sincronizzazione manuale...")
        
        do {
            print("☁️ [ICloudSyncView] 📞 Chiamata a cloudKitManager.performFullSync()...")
            try await cloudKitManager.performFullSync()
            
            print("☁️ [ICloudSyncView] ✅ Sincronizzazione manuale completata con successo!")
            alertMessage = "Sincronizzazione completata con successo!"
            showingAlert = true
            
        } catch {
            print("❌ [ICloudSyncView] ❌ Errore durante la sincronizzazione manuale: \(error.localizedDescription)")
            alertMessage = "Errore durante la sincronizzazione: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    ICloudSyncView()
}
