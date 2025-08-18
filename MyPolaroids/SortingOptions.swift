import Foundation

enum SortingOption: String, CaseIterable {
    case alphabeticalAZ = "Alfabetico A-Z"
    case alphabeticalZA = "Alfabetico Z-A"
    case dateAdded = "Ordine di aggiunta"
    case dateAddedReverse = "Ordine di aggiunta inverso"
    case loadedFirst = "Loaded first"
    case unloadedFirst = "Unloaded first"
    
    var displayName: String {
        switch self {
        case .alphabeticalAZ:
            return "Alphabetical A-Z"
        case .alphabeticalZA:
            return "Alphabetical Z-A"
        case .dateAdded:
            return "Date added"
        case .dateAddedReverse:
            return "Date added (reverse)"
        case .loadedFirst:
            return "Loaded first"
        case .unloadedFirst:
            return "Unloaded first"
        }
    }
    
    var icon: String {
        switch self {
        case .alphabeticalAZ:
            return "textformat.abc"
        case .alphabeticalZA:
            return "textformat.abc.dottedunderline"
        case .dateAdded:
            return "clock"
        case .dateAddedReverse:
            return "clock.arrow.circlepath"
        case .loadedFirst:
            return "camera.fill"
        case .unloadedFirst:
            return "camera"
        }
    }
}
