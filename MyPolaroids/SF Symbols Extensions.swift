import SwiftUI

extension Image {
    static func cameraIcon(for modello: String) -> Image {
        switch modello {
        case "Polaroid 600":
            return Image(systemName: "camera.fill")
        case "Polaroid SX-70":
            return Image(systemName: "camera.aperture")
        case "Polaroid i-Type":
            return Image(systemName: "camera.metering.center")
        case "Polaroid Go":
            return Image(systemName: "camera.metering.none")
        case "Polaroid Now":
            return Image(systemName: "camera.metering.partial")
        case "Polaroid OneStep+":
            return Image(systemName: "camera.metering.spot")
        case "Polaroid OneStep 2":
            return Image(systemName: "camera.metering.unknown")
        default:
            return Image(systemName: "camera.fill")
        }
    }
}

extension String {
    static func cameraIconName(for modello: String) -> String {
        switch modello {
        case "Polaroid 600":
            return "camera.fill"
        case "Polaroid SX-70":
            return "camera.aperture"
        case "Polaroid i-Type":
            return "camera.metering.center"
        case "Polaroid Go":
            return "camera.metering.none"
        case "Polaroid Now":
            return "camera.metering.partial"
        case "Polaroid OneStep+":
            return "camera.metering.spot"
        case "Polaroid OneStep 2":
            return "camera.metering.unknown"
        default:
            return "camera.fill"
        }
    }
}
