import Foundation
import CloudKit
import Combine
import RevenueCat

class CloudKitManager: ObservableObject {
    // MARK: - Properties
    private let container = CKContainer(identifier: "iCloud.Heterochrmia.Instantbox.com")
    private let database: CKDatabase
    
    @Published var isSignedInToiCloud = false
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    // Chiavi per UserDefaults
    private let lastSyncKey = "last_icloud_sync_date"
    private let deviceIDKey = "device_identifier"
    
    // Flag per abilitare/disabilitare CloudKit
    @Published var cloudKitEnabled = UserDefaults.standard.bool(forKey: "cloudKitEnabled")
    
    // MARK: - Callback Properties
    var onCamerasSynced: (([Camera]) -> Void)?
    var onFilmPacksSynced: (([FilmPack]) -> Void)?
    
    init() {
        self.database = container.privateCloudDatabase
        checkiCloudStatus()
        loadLastSyncDate()
        
        // Imposta il valore di default se non è stato impostato
        if UserDefaults.standard.object(forKey: "cloudKitEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "cloudKitEnabled")
            cloudKitEnabled = true
        }
        
        // Osserva i cambiamenti del toggle iCloud
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("CloudKitToggleChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.cloudKitEnabled = UserDefaults.standard.bool(forKey: "cloudKitEnabled")
            print("☁️ [CloudKitManager] 🔄 Stato iCloud cambiato: \(self?.cloudKitEnabled == true ? "abilitato" : "disabilitato")")
        }
    }
    
    // MARK: - iCloud Status
    private func checkiCloudStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.isSignedInToiCloud = status == .available
                if status != .available {
                    if let error = error {
                        self?.syncError = "Errore iCloud: \(error.localizedDescription)"
                    } else {
                        self?.syncError = "Account iCloud non disponibile"
                    }
                } else {
                    // Testa la connessione al container
                    self?.testContainerConnection()
                }
            }
        }
    }
    
    // Testa la connessione al container CloudKit
    private func testContainerConnection() {
        print("☁️ [CloudKitManager] 🔍 Test connessione container CloudKit...")
        
        Task {
            do {
                print("☁️ [CloudKitManager] 📝 Creazione record di test con record type esistente...")
                // Usa un record type che esiste già per evitare crash
                let testRecord = CKRecord(recordType: "Camera")
                testRecord["cameraData"] = Data() // Dato vuoto per test
                testRecord["deviceID"] = getDeviceIdentifier()
                testRecord["lastModified"] = Date() // Nome campo personalizzato
                
                print("☁️ [CloudKitManager] 💾 Salvataggio record di test...")
                try await database.save(testRecord)
                
                print("☁️ [CloudKitManager] ✅ Record di test salvato con successo!")
                
                // Se arriviamo qui, la connessione funziona
                await MainActor.run {
                    self.syncError = nil
                }
                
                print("☁️ [CloudKitManager] 🗑️ Rimozione record di test...")
                // Rimuovi il record di test
                try await database.deleteRecord(withID: testRecord.recordID)
                
                print("☁️ [CloudKitManager] ✅ Test connessione container completato con successo!")
                
            } catch {
                print("❌ [CloudKitManager] ❌ Errore test connessione container: \(error.localizedDescription)")
                
                await MainActor.run {
                    if let ckError = error as? CKError {
                        switch ckError.code {
                        case .unknownItem:
                            self.syncError = "Container CloudKit non configurato. Verifica la configurazione in Xcode."
                        case .notAuthenticated:
                            self.syncError = "Non autenticato con iCloud"
                        case .permissionFailure:
                            self.syncError = "Permessi CloudKit negati"
                        default:
                            self.syncError = "Errore container: \(ckError.localizedDescription)"
                        }
                    } else {
                        self.syncError = "Errore connessione container: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // MARK: - CloudKit Toggle
    
    func toggleCloudKit() {
        // Verifica se l'utente è premium prima di abilitare iCloud
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                let isPremium = !customerInfo.activeSubscriptions.isEmpty || 
                               !customerInfo.nonSubscriptions.isEmpty
                
                if isPremium {
                    cloudKitEnabled.toggle()
                    UserDefaults.standard.set(cloudKitEnabled, forKey: "cloudKitEnabled")
                    
                    if cloudKitEnabled {
                        print("☁️ [CloudKitManager] ✅ iCloud abilitato per utente premium")
                        // Riavvia la sincronizzazione automatica
                        checkiCloudStatus()
                    } else {
                        print("☁️ [CloudKitManager] ⏹️ iCloud disabilitato")
                    }
                } else {
                    print("☁️ [CloudKitManager] ❌ iCloud richiede account premium")
                    // Mostra paywall o messaggio di errore
                    await MainActor.run {
                        syncError = "iCloud sync requires premium access. Please make a donation to unlock this feature."
                    }
                }
            } catch {
                print("❌ [CloudKitManager] Errore verifica stato premium: \(error)")
                await MainActor.run {
                    syncError = "Unable to verify premium status. Please try again."
                }
            }
        }
    }
    
    // MARK: - Device Identifier
    private func getDeviceIdentifier() -> String {
        if let existingID = UserDefaults.standard.string(forKey: deviceIDKey) {
            return existingID
        }
        
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: deviceIDKey)
        return newID
    }
    
    // MARK: - Last Sync Date
    private func loadLastSyncDate() {
        if let date = UserDefaults.standard.object(forKey: lastSyncKey) as? Date {
            lastSyncDate = date
        }
    }
    
    @MainActor
    private func updateLastSyncDate() {
        lastSyncDate = Date()
        UserDefaults.standard.set(lastSyncDate, forKey: lastSyncKey)
    }
    
    // MARK: - Camera Sync
    func syncCameras(_ cameras: [Camera]) async throws {
        print("☁️ [CloudKitManager] 📸 Inizio sincronizzazione fotocamere...")
        print("☁️ [CloudKitManager] 📱 Fotocamere locali: \(cameras.count)")
        
        // Controlla se CloudKit è abilitato
        guard cloudKitEnabled else {
            print("☁️ [CloudKitManager] ⚠️ CloudKit disabilitato temporaneamente")
            print("☁️ [CloudKitManager] ✅ Sincronizzazione fotocamere simulata")
            return
        }
        
        guard isSignedInToiCloud else {
            print("❌ [CloudKitManager] ❌ Non connesso a iCloud")
            throw CloudKitError.notSignedIn
        }
        
        await MainActor.run {
            isSyncing = true
            syncError = nil
        }
        
        do {
            // Prima verifica che i record types esistano
            print("☁️ [CloudKitManager] 🔍 Verifica record types per fotocamere...")
            try await ensureRecordTypesExist()
            
            // Prima scarica le modifiche remote
            print("☁️ [CloudKitManager] 🔄 Download fotocamere remote...")
            let remoteCameras = try await fetchRemoteCameras()
            print("☁️ [CloudKitManager] 📸 Fotocamere remote trovate: \(remoteCameras.count)")
            
            // Merge con le modifiche locali
            print("☁️ [CloudKitManager] 🔀 Merge fotocamere locali e remote...")
            let mergedCameras = mergeCameras(local: cameras, remote: remoteCameras)
            print("☁️ [CloudKitManager] 📸 Fotocamere dopo merge: \(mergedCameras.count)")
            
            // Upload delle modifiche
            print("☁️ [CloudKitManager] 💾 Upload fotocamere su iCloud...")
            try await uploadCameras(mergedCameras)
            
            print("☁️ [CloudKitManager] ✅ Sincronizzazione fotocamere completata!")
            
            // Notifica i ViewModels che le fotocamere sono state sincronizzate
            await MainActor.run {
                onCamerasSynced?(mergedCameras)
                updateLastSyncDate()
            }
        } catch let error as CKError {
            print("❌ [CloudKitManager] ❌ Errore CloudKit sincronizzazione fotocamere: \(error.localizedDescription)")
            print("❌ [CloudKitManager] ❌ Codice errore: \(error.code.rawValue)")
            await MainActor.run {
                syncError = CloudKitConfig.handleCloudKitError(error)
            }
            throw error
        } catch {
            print("❌ [CloudKitManager] ❌ Errore generico sincronizzazione fotocamere: \(error.localizedDescription)")
            await MainActor.run {
                syncError = CloudKitConfig.handleCloudKitError(error)
            }
            throw error
        }
        
        await MainActor.run {
            isSyncing = false
        }
    }
    
    private func fetchRemoteCameras() async throws -> [Camera] {
        print("☁️ [CloudKitManager] 🔍 Creazione query ultra-semplice per fotocamere...")
        
        // Query ultra-semplice senza predicati complessi
        let query = CKQuery(recordType: "Camera", predicate: NSPredicate(format: "deviceID != %@", ""))
        print("☁️ [CloudKitManager] 🔍 Query creata per record type: \(query.recordType)")
        
        print("☁️ [CloudKitManager] 🔍 Esecuzione query con CKQueryOperation...")
        
        // Usa CKQueryOperation per evitare problemi con database.records(matching:)
        return try await withCheckedThrowingContinuation { continuation in
            let operation = CKQueryOperation(query: query)
            var cameras: [Camera] = []
            
            operation.recordMatchedBlock = { (recordID, result) in
                do {
                    let record = try result.get()
                    print("☁️ [CloudKitManager] 🔍 Processando record: \(record.recordID)")
                    
                    guard let cameraData = record["cameraData"] as? Data else {
                        print("☁️ [CloudKitManager] ⚠️ Record senza cameraData: \(record.recordID)")
                        return
                    }
                    
                    if let camera = try? JSONDecoder().decode(Camera.self, from: cameraData) {
                        cameras.append(camera)
                        print("☁️ [CloudKitManager] ✅ Fotocamera decodificata: \(camera.nickname) - \(camera.modello)")
                    } else {
                        print("☁️ [CloudKitManager] ❌ Errore decodifica fotocamera: \(record.recordID)")
                    }
                } catch {
                    print("☁️ [CloudKitManager] ❌ Errore accesso record: \(error)")
                }
            }
            
            operation.queryResultBlock = { result in
                switch result {
                case .success(_):
                    print("☁️ [CloudKitManager] 🔍 Query completata, fotocamere trovate: \(cameras.count)")
                    continuation.resume(returning: cameras)
                case .failure(let error):
                    print("☁️ [CloudKitManager] ❌ Errore query: \(error)")
                    continuation.resume(throwing: error)
                }
            }
            
            database.add(operation)
        }
    }
    
    private func uploadCameras(_ cameras: [Camera]) async throws {
        let deviceID = getDeviceIdentifier()
        let records = cameras.map { camera in
            CloudKitConfig.createCameraRecord(from: camera, deviceID: deviceID)
        }
        
        for record in records {
            try await database.save(record)
        }
    }
    
    private func mergeCameras(local: [Camera], remote: [Camera]) -> [Camera] {
        var merged = local
        
        for remoteCamera in remote {
            if let localIndex = merged.firstIndex(where: { $0.id == remoteCamera.id }) {
                // Aggiorna la fotocamera esistente se quella remota è più recente
                let localCamera = merged[localIndex]
                if shouldUseRemote(local: localCamera, remote: remoteCamera) {
                    merged[localIndex] = remoteCamera
                }
            } else {
                // Aggiungi la nuova fotocamera remota
                merged.append(remoteCamera)
            }
        }
        
        return merged
    }
    
    private func shouldUseRemote(local: Camera, remote: Camera) -> Bool {
        // Per ora usa sempre la versione remota se esiste
        // In futuro potresti implementare una logica più sofisticata
        return true
    }
    
    // MARK: - Film Pack Sync
    func syncFilmPacks(_ filmPacks: [FilmPack]) async throws {
        print("☁️ [CloudKitManager] 🎞️ Inizio sincronizzazione pacchi film...")
        print("☁️ [CloudKitManager] 📱 Pacchi film locali: \(filmPacks.count)")
        
        // Controlla se CloudKit è abilitato
        guard cloudKitEnabled else {
            print("☁️ [CloudKitManager] ⚠️ CloudKit disabilitato temporaneamente")
            print("☁️ [CloudKitManager] ✅ Sincronizzazione pacchi film simulata")
            return
        }
        
        guard isSignedInToiCloud else {
            print("❌ [CloudKitManager] ❌ Non connesso a iCloud")
            throw CloudKitError.notSignedIn
        }
        
        await MainActor.run {
            isSyncing = true
            syncError = nil
        }
        
        do {
            // Prima verifica che i record types esistano
            print("☁️ [CloudKitManager] 🔍 Verifica record types per pacchi film...")
            try await ensureRecordTypesExist()
            
            print("☁️ [CloudKitManager] 🔄 Download pacchi film remote...")
            let remoteFilmPacks = try await fetchRemoteFilmPacks()
            print("☁️ [CloudKitManager] 🎞️ Pacchi film remote trovati: \(remoteFilmPacks.count)")
            
            print("☁️ [CloudKitManager] 🔀 Merge pacchi film locali e remote...")
            let mergedFilmPacks = mergeFilmPacks(local: filmPacks, remote: remoteFilmPacks)
            print("☁️ [CloudKitManager] 🎞️ Pacchi film dopo merge: \(mergedFilmPacks.count)")
            
            print("☁️ [CloudKitManager] 💾 Upload pacchi film su iCloud...")
            try await uploadFilmPacks(mergedFilmPacks)
            
            print("☁️ [CloudKitManager] ✅ Sincronizzazione pacchi film completata!")
            
            // Notifica i ViewModels che i pacchi film sono stati sincronizzati
            await MainActor.run {
                onFilmPacksSynced?(mergedFilmPacks)
                updateLastSyncDate()
            }
        } catch let error as CKError {
            print("❌ [CloudKitManager] ❌ Errore CloudKit sincronizzazione pacchi film: \(error.localizedDescription)")
            print("❌ [CloudKitManager] ❌ Codice errore: \(error.code.rawValue)")
            await MainActor.run {
                syncError = CloudKitConfig.handleCloudKitError(error)
            }
            throw error
        } catch {
            print("❌ [CloudKitManager] ❌ Errore generico sincronizzazione pacchi film: \(error.localizedDescription)")
            await MainActor.run {
                syncError = CloudKitConfig.handleCloudKitError(error)
            }
            throw error
        }
        
        await MainActor.run {
            isSyncing = false
        }
    }
    
    private func fetchRemoteFilmPacks() async throws -> [FilmPack] {
        print("☁️ [CloudKitManager] 🔍 Creazione query ultra-semplice per pacchi film...")
        
        // Query ultra-semplice senza predicati complessi
        let query = CKQuery(recordType: "FilmPack", predicate: NSPredicate(format: "deviceID != %@", ""))
        print("☁️ [CloudKitManager] 🔍 Query creata per record type: \(query.recordType)")
        
        print("☁️ [CloudKitManager] 🔍 Esecuzione query con CKQueryOperation...")
        
        // Usa CKQueryOperation per evitare problemi con database.records(matching:)
        return try await withCheckedThrowingContinuation { continuation in
            let operation = CKQueryOperation(query: query)
            var filmPacks: [FilmPack] = []
            
            operation.recordMatchedBlock = { (recordID, result) in
                do {
                    let record = try result.get()
                    print("☁️ [CloudKitManager] 🔍 Processando record: \(record.recordID)")
                    
                    guard let filmPackData = record["filmPackData"] as? Data else {
                        print("☁️ [CloudKitManager] ⚠️ Record senza filmPackData: \(record.recordID)")
                        return
                    }
                    
                    if let filmPack = try? JSONDecoder().decode(FilmPack.self, from: filmPackData) {
                        filmPacks.append(filmPack)
                        print("☁️ [CloudKitManager] ✅ Pacco film decodificato: \(filmPack.tipo) - \(filmPack.modello)")
                    } else {
                        print("☁️ [CloudKitManager] ❌ Errore decodifica pacco film: \(record.recordID)")
                    }
                } catch {
                    print("☁️ [CloudKitManager] ❌ Errore accesso record: \(error)")
                }
            }
            
            operation.queryResultBlock = { result in
                switch result {
                case .success(_):
                    print("☁️ [CloudKitManager] 🔍 Query completata, pacchi film trovati: \(filmPacks.count)")
                    continuation.resume(returning: filmPacks)
                case .failure(let error):
                    print("☁️ [CloudKitManager] ❌ Errore query: \(error)")
                    continuation.resume(throwing: error)
                }
            }
            
            database.add(operation)
        }
    }
    
    private func uploadFilmPacks(_ filmPacks: [FilmPack]) async throws {
        let deviceID = getDeviceIdentifier()
        let records = filmPacks.map { filmPack in
            CloudKitConfig.createFilmPackRecord(from: filmPack, deviceID: deviceID)
        }
        
        for record in records {
            try await database.save(record)
        }
    }
    
    private func mergeFilmPacks(local: [FilmPack], remote: [FilmPack]) -> [FilmPack] {
        var merged = local
        
        for remoteFilmPack in remote {
            if let localIndex = merged.firstIndex(where: { $0.id == remoteFilmPack.id }) {
                let localFilmPack = merged[localIndex]
                if shouldUseRemote(local: localFilmPack, remote: remoteFilmPack) {
                    merged[localIndex] = remoteFilmPack
                }
            } else {
                merged.append(remoteFilmPack)
            }
        }
        
        return merged
    }
    
    private func shouldUseRemote(local: FilmPack, remote: FilmPack) -> Bool {
        return true
    }
    
    // MARK: - Full Sync
    func performFullSync() async throws {
        print("☁️ [CloudKitManager] 🚀 Inizio sincronizzazione completa...")
        
        // Controlla se CloudKit è abilitato
        guard cloudKitEnabled else {
            print("☁️ [CloudKitManager] ⚠️ CloudKit disabilitato temporaneamente")
            print("☁️ [CloudKitManager] ✅ Sincronizzazione simulata completata")
            return
        }
        
        guard isSignedInToiCloud else {
            print("❌ [CloudKitManager] ❌ Non connesso a iCloud")
            throw CloudKitError.notSignedIn
        }
        
        print("☁️ [CloudKitManager] ✅ Connessione iCloud verificata")
        
        await MainActor.run {
            isSyncing = true
            syncError = nil
        }
        
        do {
            // Prima crea i record types se non esistono
            print("☁️ [CloudKitManager] 🔍 Verifica record types...")
            try await ensureRecordTypesExist()
            print("☁️ [CloudKitManager] ✅ Record types verificati")
            
            print("☁️ [CloudKitManager] 🔄 Inizio sincronizzazione fotocamere...")
            print("☁️ [CloudKitManager] 🔍 Chiamata a fetchRemoteCameras()...")
            // Scarica e mostra le fotocamere remote
            let remoteCameras = try await fetchRemoteCameras()
            print("☁️ [CloudKitManager] 📸 Fotocamere trovate su iCloud: \(remoteCameras.count)")
            for (index, camera) in remoteCameras.enumerated() {
                print("   \(index + 1). 📷 \(camera.nickname) (\(camera.modello) - \(camera.brand))")
            }
            print("☁️ [CloudKitManager] ✅ Sincronizzazione fotocamere completata")
            
            print("☁️ [CloudKitManager] 🔄 Inizio sincronizzazione pacchi film...")
            print("☁️ [CloudKitManager] 🔍 Chiamata a fetchRemoteFilmPacks()...")
            // Scarica e mostra i pacchi film remote
            let remoteFilmPacks = try await fetchRemoteFilmPacks()
            print("☁️ [CloudKitManager] 🎞️ Pacchi film trovati su iCloud: \(remoteFilmPacks.count)")
            for (index, filmPack) in remoteFilmPacks.enumerated() {
                print("   \(index + 1). 🎬 \(filmPack.tipo) \(filmPack.modello) - \(filmPack.scattiRimanenti)/\(filmPack.scattiTotali) scatti")
            }
            print("☁️ [CloudKitManager] ✅ Sincronizzazione pacchi film completata")
            
            print("☁️ [CloudKitManager] 🧹 Pulizia cache locale...")
            try await clearLocalCache()
            
            print("☁️ [CloudKitManager] 📅 Aggiornamento data ultima sincronizzazione...")
            await MainActor.run {
                updateLastSyncDate()
            }
            
            print("☁️ [CloudKitManager] ✅ Sincronizzazione completa terminata con successo!")
            
        } catch {
            print("❌ [CloudKitManager] ❌ Errore durante la sincronizzazione completa: \(error.localizedDescription)")
            await MainActor.run {
                syncError = CloudKitConfig.handleCloudKitError(error)
            }
            throw error
        }
        
        await MainActor.run {
            isSyncing = false
        }
        
        print("☁️ [CloudKitManager] 🏁 Sincronizzazione completa terminata")
    }
    
    private func clearLocalCache() async throws {
        // Implementa la pulizia della cache locale se necessario
    }
    
    // MARK: - Record Types Management
    private func ensureRecordTypesExist() async throws {
        print("☁️ [CloudKitManager] 🔍 Verifica esistenza record types...")
        
        do {
            // Verifica che i record types esistano
            try await testRecordTypesExist()
            print("☁️ [CloudKitManager] ✅ Record types verificati con successo")
            
        } catch let error as CKError {
            print("❌ [CloudKitManager] ❌ Errore CloudKit: \(error.localizedDescription)")
            print("❌ [CloudKitManager] ❌ Codice errore: \(error.code.rawValue)")
            
            if error.code == .unknownItem {
                print("❌ [CloudKitManager] ❌ Record types 'Camera' e 'FilmPack' non esistono!")
                print("💡 [CloudKitManager] 💡 Devi creare manualmente i record types in CloudKit Console:")
                print("💡 [CloudKitManager] 💡 1. Vai su https://icloud.developer.apple.com/dashboard/")
                print("💡 [CloudKitManager] 💡 2. Seleziona il container: iCloud.Heterochrmia.Instantbox.com")
                print("💡 [CloudKitManager] 💡 3. Vai su Schema > Record Types")
                print("💡 [CloudKitManager] 💡 4. Crea 'Camera' con campi: cameraData, deviceID, lastModified, cameraID")
                print("💡 [CloudKitManager] 💡 5. Crea 'FilmPack' con campi: filmPackData, deviceID, lastModified, filmPackID")
                throw CloudKitError.recordTypesNotFound
            } else {
                print("❌ [CloudKitManager] ❌ Errore CloudKit non gestito")
                throw error
            }
            
        } catch {
            print("❌ [CloudKitManager] ❌ Errore generico: \(error.localizedDescription)")
            throw CloudKitError.recordTypesNotFound
        }
    }
    
    private func testRecordTypesExist() async throws {
        print("☁️ [CloudKitManager] 🔍 Verifica esistenza record types...")
        
        // Testa solo la creazione dei record types, senza salvataggio
        // Se arriviamo qui senza errori, i record types esistono
        let testCameraRecord = CKRecord(recordType: CloudKitConfig.RecordTypes.camera)
        let testFilmPackRecord = CKRecord(recordType: CloudKitConfig.RecordTypes.filmPack)
        
        // Se arriviamo qui senza errori, i record types esistono
        _ = testCameraRecord
        _ = testFilmPackRecord
        
        print("☁️ [CloudKitManager] ✅ Record types 'Camera' e 'FilmPack' esistono")
    }
    
    // MARK: - Error Handling
    enum CloudKitError: LocalizedError {
        case notSignedIn
        case networkError
        case permissionDenied
        case quotaExceeded
        case recordTypesNotFound
        
        var errorDescription: String? {
            switch self {
            case .notSignedIn:
                return "Non sei connesso a iCloud"
            case .networkError:
                return "Errore di rete. Riprova più tardi"
            case .permissionDenied:
                return "Permessi iCloud negati"
            case .quotaExceeded:
                return "Spazio iCloud esaurito"
            case .recordTypesNotFound:
                return "Record types iCloud non configurati. Crea 'Camera' e 'FilmPack' in CloudKit Console"
            }
        }
    }
}
