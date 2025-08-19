//
//  MyPolaroidsApp.swift
//  MyPolaroids
//
//  Created by Edoardo Galati on 8/15/25.
//

import SwiftUI
import RevenueCat

@main
struct MyPolaroidsApp: App {
    
    init() {
        // Inizializza RevenueCat
        setupRevenueCat()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupRevenueCat() {
        // Configura RevenueCat con la Public API Key corretta
        Purchases.configure(withAPIKey: "appl_DeoKrpolsreMpiVetkAoTcsYNIK")
        
        print("🚀 RevenueCat inizializzato")
        
        // Verifica la configurazione
        Task {
            do {
                let customerInfo = try await Purchases.shared.customerInfo()
                print("✅ Customer info caricata: \(customerInfo.entitlements)")
            } catch {
                print("❌ Errore caricamento customer info: \(error)")
            }
        }
    }
}
