import SwiftUI
import RevenueCat
import RevenueCatUI

struct ImpostazioniView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("ignoreCompatibility") private var ignoreCompatibility = false
    @AppStorage("cameraSortingOption") private var cameraSortingOption = SortingOption.dateAdded.rawValue
    @AppStorage("filmPackSortingOption") private var filmPackSortingOption = SortingOption.dateAdded.rawValue
    @State private var showingDebugModal = false
    @State private var showingPaywall = false
    @State private var versionTapCount = 0
    @State private var syncInProgress = false
    @State private var isPremiumUser = false
    @State private var refreshTrigger = false
    @State private var showingRestoreAlert = false
    @State private var restoreAlertTitle = ""
    @State private var restoreAlertMessage = ""
    @State private var showingCustomAppIconsView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 1) {
                        // Sezione Compatibilità
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Ignore Camera-Film Compatibility")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $ignoreCompatibility)
                                    .labelsHidden()
                            }
                            
                            Text("When enabled, you can load any film type in any camera, bypassing compatibility checks.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                        
                        // Sezione Ordinamento Fotocamere
                        HStack {
                            Text("Camera Sorting")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Menu {
                                ForEach(SortingOption.allCases, id: \.self) { option in
                                    Button(action: {
                                        cameraSortingOption = option.rawValue
                                    }) {
                                        HStack {
                                            Image(systemName: option.icon)
                                            Text(option.displayName)
                                            if cameraSortingOption == option.rawValue {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(SortingOption(rawValue: cameraSortingOption)?.displayName ?? "Select")
                                        .foregroundColor(AppColors.textPrimary)
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppColors.textPrimary)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                        
                        // Sezione Ordinamento Film Pack
                        HStack {
                            Text("Film Pack Sorting")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Menu {
                                ForEach(SortingOption.allCases.filter { option in
                                    option != .loadedFirst && option != .unloadedFirst
                                }, id: \.self) { option in
                                    Button(action: {
                                        filmPackSortingOption = option.rawValue
                                    }) {
                                        HStack {
                                            Image(systemName: option.icon)
                                            Text(option.displayName)
                                            if filmPackSortingOption == option.rawValue {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(SortingOption(rawValue: filmPackSortingOption)?.displayName ?? "Select")
                                        .foregroundColor(AppColors.textPrimary)
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppColors.textPrimary)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                        
                        // Sezione iCloud Sync (sotto Film Pack Sorting) - Feature Premium
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("iCloud Sync")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                // Badge Premium
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                    Text("PREMIUM")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.yellow)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(4)
                                
                                Spacer()
                                
                                if isPremiumUser {
                                    Toggle("", isOn: Binding(
                                        get: { UserDefaults.standard.bool(forKey: "cloudKitEnabled") },
                                        set: { newValue in
                                            UserDefaults.standard.set(newValue, forKey: "cloudKitEnabled")
                                            // Notifica CloudKitManager del cambio
                                            NotificationCenter.default.post(name: NSNotification.Name("CloudKitToggleChanged"), object: nil)
                                        }
                                    ))
                                    .labelsHidden()
                                } else {
                                    Button(action: {
                                        showingPaywall = true
                                    }) {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.gray)
                                            .font(.title3)
                                    }
                                }
                            }
                            
                            if isPremiumUser {
                                Text("When enabled, your cameras and film packs will automatically sync across all your devices every 15 minutes.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                
                                // Pulsante Sync Now (visibile solo se iCloud è abilitato)
                                if UserDefaults.standard.bool(forKey: "cloudKitEnabled") {
                                    Button(action: {
                                        // Avvia sincronizzazione manuale
                                        Task {
                                            await syncNow()
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                                .font(.caption)
                                            Text("Sync Now")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    .disabled(syncInProgress)
                                    
                                    if syncInProgress {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("Syncing...")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            } else {
                                Text("Unlock iCloud sync to automatically sync your cameras and film packs across all your devices every 15 minutes.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                
                                Button(action: {
                                    showingPaywall = true
                                }) {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                            .font(.caption)
                                        Text("Unlock Premium")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppColors.accentPrimary)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                        
                        // Sezione Notifiche Sviluppo Foto (Feature Premium)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text("Development Reminders")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        // Badge Premium
                                        HStack(spacing: 4) {
                                            Image(systemName: "crown.fill")
                                                .font(.caption)
                                                .foregroundColor(.yellow)
                                            Text("PREMIUM")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.yellow)
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.yellow.opacity(0.2))
                                        .cornerRadius(4)
                                    }
                                    
                                    Text("Get notified when it's time to develop your photos")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                if isPremiumUser {
                                    Toggle("", isOn: Binding(
                                        get: { UserDefaults.standard.bool(forKey: "notificationsEnabled") },
                                        set: { newValue in
                                            UserDefaults.standard.set(newValue, forKey: "notificationsEnabled")
                                            if newValue {
                                                Task {
                                                    await requestNotificationPermission()
                                                }
                                            }
                                        }
                                    ))
                                    .labelsHidden()
                                } else {
                                    Button(action: {
                                        showingPaywall = true
                                    }) {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.gray)
                                            .font(.title3)
                                    }
                                }
                            }
                            
                            if isPremiumUser && UserDefaults.standard.bool(forKey: "notificationsEnabled") {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Reminder delay (minutes):")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        TextField("15", value: Binding(
                                            get: { UserDefaults.standard.integer(forKey: "notificationDelayMinutes") },
                                            set: { newValue in
                                                let clampedValue = max(1, min(1440, newValue)) // Min 1, Max 1440 (24 ore)
                                                UserDefaults.standard.set(clampedValue, forKey: "notificationDelayMinutes")
                                            }
                                        ), format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .multilineTextAlignment(.trailing)
                                    }
                                }
                            } else if !isPremiumUser {
                                Button(action: {
                                    showingPaywall = true
                                }) {
                                    HStack {
                                        Image(systemName: "crown.fill")
                                            .font(.caption)
                                        Text("Unlock Premium")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppColors.accentPrimary)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                        
                        // Custom App Icons Section (Premium Feature)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text("Custom App Icons")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        
                                        // Premium Badge
                                        HStack(spacing: 4) {
                                            Image(systemName: "crown.fill")
                                                .font(.caption)
                                                .foregroundColor(.yellow)
                                            Text("PREMIUM")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.yellow)
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.yellow.opacity(0.2))
                                        .cornerRadius(4)
                                    }
                                    
                                    Text("Personalize your app appearance with exclusive icons")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                                
                                if isPremiumUser {
                                    Button(action: {
                                        showingCustomAppIconsView = true
                                    }) {
                                        Image(systemName: "paintbrush.fill")
                                            .foregroundColor(AppColors.accentPrimary)
                                            .font(.title3)
                                    }
                                } else {
                                    Button(action: {
                                        showingPaywall = true
                                    }) {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.gray)
                                            .font(.title3)
                                    }
                                }
                            }
                            
                            if isPremiumUser {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("Access to 17+ exclusive icons")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("Light/dark mode support")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("Easy icon switching")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                        
                        // Sezione Donations
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(AppColors.accentPrimary)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Donations")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Text("Support the project and unlock premium features")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Text("☁️ iCloud Sync across all devices\n🔔 Development Reminders for photos")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                        .padding(.top, 2)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            
                            // Pulsante Restore Purchases sempre visibile
                            Button(action: {
                                restorePurchases()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise.circle")
                                        .font(.caption)
                                    Text("Restore Purchases")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingPaywall = true
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                        
                        // Sezione Versione
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Version")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("1.2")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            versionTapCount += 1
                            if versionTapCount >= 3 {
                                showingDebugModal = true
                                versionTapCount = 0
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.backgroundSecondary)
                        .cornerRadius(16)
                    }
                    .padding(.vertical, 16)
                }
            }
            .background(AppColors.backgroundPrimary)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.navigationButton)
                }
            }
        }
        .presentationDetents([.large])
        .onAppear {
            checkPremiumStatus()
        }
        .onChange(of: refreshTrigger) { _ in
            // Forza ricontrollo dello stato premium quando refreshTrigger cambia
            checkPremiumStatus()
        }
        .sheet(isPresented: $showingDebugModal) {
            DataSyncView()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingCustomAppIconsView) {
            CustomAppIconsView()
        }
        .alert(restoreAlertTitle, isPresented: $showingRestoreAlert) {
            Button("OK") {
                // L'alert si chiude automaticamente
            }
        } message: {
            Text(restoreAlertMessage)
        }
    }
    
    // MARK: - Premium Functions
    
    private func checkPremiumStatus() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                await MainActor.run {
                    // Controlla se l'utente ha fatto almeno una donazione
                    isPremiumUser = !customerInfo.activeSubscriptions.isEmpty || 
                                   !customerInfo.nonSubscriptionTransactions.isEmpty
                    
                    // Salva lo stato premium in UserDefaults per il NotificationManager
                    UserDefaults.standard.set(isPremiumUser, forKey: "isPremiumUser")
                    
                    print("💎 [ImpostazioniView] Stato premium: \(isPremiumUser ? "PREMIUM" : "FREE")")
                }
            } catch {
                print("❌ [ImpostazioniView] Errore controllo stato premium: \(error)")
                await MainActor.run {
                    isPremiumUser = false
                }
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            do {
                print("🔄 [ImpostazioniView] Inizio restore purchases...")
                let customerInfo = try await Purchases.shared.restorePurchases()
                
                await MainActor.run {
                    // Controlla se il restore ha rivelato acquisti
                    isPremiumUser = !customerInfo.activeSubscriptions.isEmpty || 
                                   !customerInfo.nonSubscriptionTransactions.isEmpty
                    
                    // Salva lo stato premium in UserDefaults per il NotificationManager
                    UserDefaults.standard.set(isPremiumUser, forKey: "isPremiumUser")
                    
                    if isPremiumUser {
                        print("✅ [ImpostazioniView] Restore completato - Utente PREMIUM ripristinato!")
                        // Forza aggiornamento UI
                        refreshTrigger.toggle()
                        
                        // Mostra popup di successo
                        restoreAlertTitle = "Restore Successful! 🎉"
                        restoreAlertMessage = "Your premium access has been restored. You can now use iCloud sync and development reminders!"
                        showingRestoreAlert = true
                    } else {
                        print("⚠️ [ImpostazioniView] Restore completato - Nessun acquisto trovato")
                        
                        // Mostra popup di nessun acquisto trovato
                        restoreAlertTitle = "No Purchases Found"
                        restoreAlertMessage = "We couldn't find any previous purchases to restore. Please make a donation to unlock premium features."
                        showingRestoreAlert = true
                    }
                }
            } catch {
                print("❌ [ImpostazioniView] Errore restore purchases: \(error)")
                
                await MainActor.run {
                    // Mostra popup di errore
                    restoreAlertTitle = "Restore Failed"
                    restoreAlertMessage = "An error occurred while restoring purchases. Please try again or contact support."
                    showingRestoreAlert = true
                }
            }
        }
    }
    
    // MARK: - Notification Functions
    
    private func requestNotificationPermission() async {
        let granted = await NotificationManager.shared.requestNotificationPermission()
        
        if !granted {
            await MainActor.run {
                // Mostra alert per spiegare come abilitare le notifiche
                restoreAlertTitle = "Notifications Permission Required"
                restoreAlertMessage = "To receive development reminders, please enable notifications in Settings > MyPolaroids > Notifications"
                showingRestoreAlert = true
            }
        }
    }
    
    // MARK: - Sync Functions
    
    private func syncNow() async {
        syncInProgress = true
        
        // Crea un CloudKitManager temporaneo per la sincronizzazione
        let cloudKitManager = CloudKitManager()
        
        do {
            // Esegui sincronizzazione completa
            try await cloudKitManager.performFullSync()
            print("☁️ [ImpostazioniView] ✅ Sincronizzazione manuale completata")
        } catch {
            print("☁️ [ImpostazioniView] ❌ Errore sincronizzazione manuale: \(error)")
        }
        
        await MainActor.run {
            syncInProgress = false
        }
    }
}

#Preview {
    ImpostazioniView()
}
