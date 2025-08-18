import Foundation
import AVFoundation
import Photos
import UIKit
import Combine

class PermissionManager: ObservableObject {
    @Published var cameraPermission: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryPermission: PHAuthorizationStatus = .notDetermined
    
    init() {
        checkPermissions()
    }
    
    func checkPermissions() {
        cameraPermission = AVCaptureDevice.authorizationStatus(for: .video)
        photoLibraryPermission = PHPhotoLibrary.authorizationStatus()
    }
    
    func requestCameraPermission() async -> Bool {
        let status = await AVCaptureDevice.requestAccess(for: .video)
        await MainActor.run {
            cameraPermission = status ? .authorized : .denied
        }
        return status
    }
    
    func requestPhotoLibraryPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            photoLibraryPermission = status
        }
        return status == .authorized || status == .limited
    }
    
    func showPermissionAlert(for type: PermissionType) -> UIAlertController {
        let alert = UIAlertController(
            title: "Autorizzazione Richiesta",
            message: getPermissionMessage(for: type),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Impostazioni", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Annulla", style: .cancel))
        
        return alert
    }
    
    private func getPermissionMessage(for type: PermissionType) -> String {
        switch type {
        case .camera:
            return "L'accesso alla fotocamera è necessario per scattare foto personalizzate delle tue fotocamere Polaroid. Vai su Impostazioni > Privacy e Sicurezza > Fotocamera per abilitare l'accesso."
        case .photoLibrary:
            return "L'accesso alla galleria fotografica è necessario per selezionare foto personalizzate per le tue fotocamere Polaroid. Vai su Impostazioni > Privacy e Sicurezza > Foto per abilitare l'accesso."
        }
    }
}

enum PermissionType {
    case camera
    case photoLibrary
}
