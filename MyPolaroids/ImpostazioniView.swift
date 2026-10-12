import SwiftUI
import RevenueCat
import RevenueCatUI

struct ImpostazioniView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("ignoreCompatibility") private var ignoreCompatibility = false
    @AppStorage("cameraSortingOption") private var cameraSortingOption = SortingOption.dateAdded.rawValue
    @AppStorage("filmPackSortingOption") private var filmPackSortingOption = SortingOption.dateAdded.rawValue
    @AppStorage("cloudKitEnabled") private var cloudKitEnabled = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("notificationDelayMinutes") private var notificationDelayMinutes = 15

    @State private var showingDebugModal = false
    @State private var showingPaywall = false
    @State private var versionTapCount = 0
    @State private var syncInProgress = false
    @State private var isPremiumUser = false
    @State private var refreshTrigger = false
    @State private var showingRestoreAlert = false
    @State private var restoreAlertTitle = ""
    @State private var restoreAlertMessage = ""

    private let delayOptions = [1, 5, 10, 15, 20, 30]

    private var filmSortingOptions: [SortingOption] {
        SortingOption.allCases.filter { $0 != .loadedFirst && $0 != .unloadedFirst }
    }

    /// The preset delays, plus the stored value if it was set to something else.
    private var delayChoices: [Int] {
        delayOptions.contains(notificationDelayMinutes)
            ? delayOptions
            : (delayOptions + [notificationDelayMinutes]).sorted()
    }

    private var lastSyncDate: Date? {
        UserDefaults.standard.object(forKey: "last_icloud_sync_date") as? Date
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "–"
        return "\(version) (\(build))"
    }

    /// Writes the iCloud flag and tells every CloudKitManager instance about the change.
    private var cloudKitBinding: Binding<Bool> {
        Binding(
            get: { cloudKitEnabled },
            set: { newValue in
                cloudKitEnabled = newValue
                NotificationCenter.default.post(name: NSNotification.Name("CloudKitToggleChanged"), object: nil)
            }
        )
    }

    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { notificationsEnabled },
            set: { newValue in
                notificationsEnabled = newValue
                if newValue {
                    Task { await requestNotificationPermission() }
                }
            }
        )
    }

    private var delayBinding: Binding<Int> {
        Binding(
            get: { notificationDelayMinutes },
            set: { notificationDelayMinutes = max(1, min(1440, $0)) }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                camerasSection
                premiumSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
        }
        .tint(.primary)
        .presentationDetents([.large])
        .onAppear {
            checkPremiumStatus()
        }
        .onChange(of: refreshTrigger) { _, _ in
            checkPremiumStatus()
        }
        .sheet(isPresented: $showingDebugModal) {
            DataSyncView()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .alert(restoreAlertTitle, isPresented: $showingRestoreAlert) {
            Button("OK") { }
        } message: {
            Text(restoreAlertMessage)
        }
    }

    // MARK: - Sections

    private var camerasSection: some View {
        Section {
            Picker(selection: $cameraSortingOption) {
                ForEach(SortingOption.allCases, id: \.rawValue) { option in
                    Label(option.displayName, systemImage: option.icon)
                        .tag(option.rawValue)
                }
            } label: {
                SettingsLabel(title: "Camera sorting", systemImage: "camera", color: .blue)
            }

            Picker(selection: $filmPackSortingOption) {
                ForEach(filmSortingOptions, id: \.rawValue) { option in
                    Label(option.displayName, systemImage: option.icon)
                        .tag(option.rawValue)
                }
            } label: {
                SettingsLabel(title: "Film sorting", systemImage: "square.stack", color: .indigo)
            }

            Toggle(isOn: $ignoreCompatibility) {
                SettingsLabel(title: "Ignore compatibility", systemImage: "checkmark.shield", color: .orange)
            }
        } header: {
            Text("Cameras")
        } footer: {
            Text("When enabled, you can load any film type in any camera, bypassing compatibility checks.")
        }
    }

    private var premiumSection: some View {
        Section {
            if isPremiumUser {
                Toggle(isOn: cloudKitBinding) {
                    SettingsLabel(title: "iCloud Sync", systemImage: "icloud", color: .blue)
                }

                if cloudKitEnabled {
                    Button {
                        Task { await syncNow() }
                    } label: {
                        HStack {
                            SettingsLabel(title: "Sync now", systemImage: "arrow.clockwise", color: .green)
                            Spacer()
                            if syncInProgress {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(syncInProgress)
                }

                Toggle(isOn: notificationsBinding) {
                    SettingsLabel(title: "Photo Ready Notifications", systemImage: "bell", color: .red)
                }

                if notificationsEnabled {
                    Picker(selection: delayBinding) {
                        ForEach(delayChoices, id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    } label: {
                        SettingsLabel(title: "Delay", systemImage: "timer", color: .purple)
                    }
                }
            } else {
                lockedRow(title: "iCloud Sync", systemImage: "icloud", color: .blue)
                lockedRow(title: "Photo Ready Notifications", systemImage: "bell", color: .red)
            }

            Button {
                showingPaywall = true
            } label: {
                HStack {
                    SettingsLabel(title: "Support the project", systemImage: "heart", color: .pink)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }

            Button("Restore Purchases") {
                restorePurchases()
            }
        } header: {
            HStack(spacing: 8) {
                Text("Premium")
                if isPremiumUser {
                    Chip(text: "Premium", prominent: true)
                        .textCase(nil)
                }
            }
        } footer: {
            Text(premiumFooter)
        }
    }

    private var premiumFooter: String {
        if isPremiumUser {
            var text = "Your cameras and film packs sync across all your devices every 15 minutes."
            if let lastSyncDate {
                text += " Last sync: \(lastSyncDate.formatted(date: .abbreviated, time: .shortened))."
            }
            if notificationsEnabled {
                text += " You will be notified when a photo is ready to be scanned."
            }
            return text
        }
        return "Support the project to unlock iCloud sync across all your devices and photo ready notifications."
    }

    private func lockedRow(title: String, systemImage: String, color: Color) -> some View {
        Button {
            showingPaywall = true
        } label: {
            HStack {
                SettingsLabel(title: title, systemImage: systemImage, color: color)
                Spacer()
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                SettingsLabel(title: "Version", systemImage: "info", color: .gray)
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                versionTapCount += 1
                if versionTapCount >= 3 {
                    showingDebugModal = true
                    versionTapCount = 0
                }
            }
        }
    }

    // MARK: - Premium Functions

    private func checkPremiumStatus() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                await MainActor.run {
                    // Premium means at least one donation or an active subscription.
                    isPremiumUser = !customerInfo.activeSubscriptions.isEmpty ||
                                   !customerInfo.nonSubscriptions.isEmpty

                    // NotificationManager reads this flag.
                    UserDefaults.standard.set(isPremiumUser, forKey: "isPremiumUser")
                }
            } catch {
                await MainActor.run {
                    isPremiumUser = false
                }
            }
        }
    }

    private func restorePurchases() {
        Task {
            do {
                let customerInfo = try await Purchases.shared.restorePurchases()

                await MainActor.run {
                    isPremiumUser = !customerInfo.activeSubscriptions.isEmpty ||
                                   !customerInfo.nonSubscriptions.isEmpty

                    UserDefaults.standard.set(isPremiumUser, forKey: "isPremiumUser")

                    if isPremiumUser {
                        refreshTrigger.toggle()

                        restoreAlertTitle = "Restore Successful"
                        restoreAlertMessage = "Your premium access has been restored. You can now use iCloud sync and photo ready notifications!"
                        showingRestoreAlert = true
                    } else {
                        restoreAlertTitle = "No Purchases Found"
                        restoreAlertMessage = "We couldn't find any previous purchases to restore. Please make a donation to unlock premium features."
                        showingRestoreAlert = true
                    }
                }
            } catch {
                await MainActor.run {
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
                restoreAlertTitle = "Notifications Permission Required"
                restoreAlertMessage = "To receive photo ready notifications, please enable notifications in Settings > Instant Box > Notifications"
                showingRestoreAlert = true
            }
        }
    }

    // MARK: - Sync Functions

    private func syncNow() async {
        syncInProgress = true

        // Temporary manager just for the manual sync.
        let cloudKitManager = CloudKitManager()

        do {
            try await cloudKitManager.performFullSync()
        } catch {
            // CloudKitManager exposes the failure through syncError; nothing extra to show here.
        }

        await MainActor.run {
            syncInProgress = false
        }
    }
}

#Preview {
    ImpostazioniView()
}
