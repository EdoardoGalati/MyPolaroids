import SwiftUI

struct AppColors {
    // MARK: - Background Colors
    static var backgroundPrimary: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
            default:
                return UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
            }
        })
    }
    
    static var backgroundSecondary: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1.0)
            default:
                return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            }
        })
    }
    
    // MARK: - Text Colors
    static var textPrimary: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            default:
                return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            }
        })
    }
    
    static var textSecondary: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 174/255, green: 174/255, blue: 178/255, alpha: 1.0)
            default:
                return UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1.0)
            }
        })
    }
    
    // MARK: - Accent Colors
    static var accentPrimary: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            default:
                return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            }
        })
    }
    
    static var accentSecondary: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 174/255, green: 174/255, blue: 178/255, alpha: 1.0)
            default:
                return UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
            }
        })
    }
    
    // MARK: - Button Colors
    static var buttonPrimary: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            default:
                return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            }
        })
    }
    
    static var buttonText: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
            default:
                return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
            }
        })
    }
    
    // MARK: - Separator Colors
    static var separator: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 58/255, green: 58/255, blue: 60/255, alpha: 1.0)
            default:
                return UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0)
            }
        })
    }
    
    // MARK: - Tab Bar Colors
    static var tabBarBackground: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
            default:
                return UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
            }
        })
    }
    
    static var tabBarGradient: Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0)
            default:
                return UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
            }
        })
    }
}
