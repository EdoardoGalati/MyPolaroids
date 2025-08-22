import Foundation
import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
    @AppStorage("notificationsEnabled") var notificationsEnabled = false
    @AppStorage("notificationDelayMinutes") var notificationDelayMinutes = 15
    
    private init() {
        // Assicurati che il valore di default sia 15 minuti se non è stato impostato
        if UserDefaults.standard.object(forKey: "notificationDelayMinutes") == nil {
            UserDefaults.standard.set(15, forKey: "notificationDelayMinutes")
        }
    }
    
    // MARK: - Request Permission
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            // Aggiorna la proprietà AppStorage direttamente
            notificationsEnabled = granted
            
            print("🔔 [NotificationManager] Permesso notifiche: \(granted ? "CONCESSO" : "NEGATO")")
            return granted
        } catch {
            print("❌ [NotificationManager] Errore richiesta permesso: \(error)")
            return false
        }
    }
    
    // MARK: - Check Permission Status
    
    func checkNotificationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Schedule Development Reminder
    
    func scheduleDevelopmentReminder(for filmPack: FilmPack, camera: Camera) {
        // Controlla se l'utente è premium
        let isPremiumUser = UserDefaults.standard.bool(forKey: "isPremiumUser")
        guard isPremiumUser else {
            print("🔔 [NotificationManager] Utente non premium, salto programmazione notifiche")
            return
        }
        
        guard notificationsEnabled else {
            print("🔔 [NotificationManager] Notifiche disabilitate, salto programmazione")
            return
        }
        
        // Rimuovi notifiche esistenti per questo film pack
        removeExistingNotifications(for: filmPack.id)
        
        // Calcola quando inviare la notifica
        let delayTimeInterval = TimeInterval(notificationDelayMinutes * 60)
        let triggerDate = Date().addingTimeInterval(delayTimeInterval)
        
        // Crea il contenuto della notifica
        let content = UNMutableNotificationContent()
        content.title = "📸 Develop your photo!"
        content.body = "It's been \(notificationDelayMinutes) minute\(notificationDelayMinutes == 1 ? "" : "s") since you took a photo with \(camera.displayName). Time to develop your Polaroid!"
        content.sound = .default
        content.badge = 1
        
        // Crea il trigger temporale
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: delayTimeInterval,
            repeats: false
        )
        
        // Crea la richiesta di notifica
        let request = UNNotificationRequest(
            identifier: "development_reminder_\(filmPack.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Programma la notifica
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ [NotificationManager] Errore programmazione notifica: \(error)")
            } else {
                print("✅ [NotificationManager] Notifica programmata per \(triggerDate) - Film: \(filmPack.tipo) \(filmPack.modello)")
            }
        }
    }
    
    // MARK: - Remove Notifications
    
    func removeExistingNotifications(for filmPackId: UUID) {
        let identifier = "development_reminder_\(filmPackId.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ [NotificationManager] Notifiche rimosse per film pack: \(filmPackId)")
    }
    
    func removeAllDevelopmentReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ [NotificationManager] Tutte le notifiche di sviluppo rimosse")
    }
    
    // MARK: - Get Pending Notifications
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    

    
    // MARK: - Handle App State Changes
    
    func handleAppDidBecomeActive() {
        // Rimuovi il badge quando l'app torna attiva
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    func handleAppDidEnterBackground() {
        // Verifica che le notifiche siano ancora abilitate
        Task {
            let status = await checkNotificationStatus()
            if status != .authorized {
                await MainActor.run {
                    notificationsEnabled = false
                }
            }
        }
    }
}

// MARK: - Notification Settings

struct NotificationSettings {
    let isEnabled: Bool
    let delayMinutes: Int
    let pendingCount: Int
}
