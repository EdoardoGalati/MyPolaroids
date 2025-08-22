import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "polaroid.1000.fill.symbols" asset catalog image resource.
    static let polaroid1000FillSymbols = ImageResource(name: "polaroid.1000.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.1200.fill.symbols" asset catalog image resource.
    static let polaroid1200FillSymbols = ImageResource(name: "polaroid.1200.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.600.fill.symbols" asset catalog image resource.
    static let polaroid600FillSymbols = ImageResource(name: "polaroid.600.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.I-1.fill.symbols" asset catalog image resource.
    static let polaroidI1FillSymbols = ImageResource(name: "polaroid.I-1.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.I-2.fill.symbols" asset catalog image resource.
    static let polaroidI2FillSymbols = ImageResource(name: "polaroid.I-2.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.amigo.fill.symbols" asset catalog image resource.
    static let polaroidAmigoFillSymbols = ImageResource(name: "polaroid.amigo.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.film.symbols" asset catalog image resource.
    static let polaroidFilmSymbols = ImageResource(name: "polaroid.film.symbols", bundle: resourceBundle)

    /// The "polaroid.flip.fill.symbols" asset catalog image resource.
    static let polaroidFlipFillSymbols = ImageResource(name: "polaroid.flip.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.go.fill.symbols" asset catalog image resource.
    static let polaroidGoFillSymbols = ImageResource(name: "polaroid.go.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.joycom.fill.symbols" asset catalog image resource.
    static let polaroidJoycomFillSymbols = ImageResource(name: "polaroid.joycom.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.macro.fill.symbols" asset catalog image resource.
    static let polaroidMacroFillSymbols = ImageResource(name: "polaroid.macro.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.now.fill.symbols" asset catalog image resource.
    static let polaroidNowFillSymbols = ImageResource(name: "polaroid.now.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.old.fill.symbols" asset catalog image resource.
    static let polaroidOldFillSymbols = ImageResource(name: "polaroid.old.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.one600.fill.symbols" asset catalog image resource.
    static let polaroidOne600FillSymbols = ImageResource(name: "polaroid.one600.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.procam.fill.symbols" asset catalog image resource.
    static let polaroidProcamFillSymbols = ImageResource(name: "polaroid.procam.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.slr.fill.symbols" asset catalog image resource.
    static let polaroidSlrFillSymbols = ImageResource(name: "polaroid.slr.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.spectra.fill.symbols" asset catalog image resource.
    static let polaroidSpectraFillSymbols = ImageResource(name: "polaroid.spectra.fill.symbols", bundle: resourceBundle)

    /// The "polaroid.sx70.fill.symbols" asset catalog image resource.
    static let polaroidSx70FillSymbols = ImageResource(name: "polaroid.sx70.fill.symbols", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "polaroid.1000.fill.symbols" asset catalog image.
    static var polaroid1000FillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroid1000FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.1200.fill.symbols" asset catalog image.
    static var polaroid1200FillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroid1200FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.600.fill.symbols" asset catalog image.
    static var polaroid600FillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroid600FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.I-1.fill.symbols" asset catalog image.
    static var polaroidI1FillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidI1FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.I-2.fill.symbols" asset catalog image.
    static var polaroidI2FillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidI2FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.amigo.fill.symbols" asset catalog image.
    static var polaroidAmigoFillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidAmigoFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.film.symbols" asset catalog image.
    static var polaroidFilmSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidFilmSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.flip.fill.symbols" asset catalog image.
    static var polaroidFlipFillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidFlipFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.go.fill.symbols" asset catalog image.
    static var polaroidGoFillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidGoFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.joycom.fill.symbols" asset catalog image.
    static var polaroidJoycomFillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidJoycomFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.macro.fill.symbols" asset catalog image.
    static var polaroidMacroFillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidMacroFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.now.fill.symbols" asset catalog image.
    static var polaroidNowFillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidNowFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.old.fill.symbols" asset catalog image.
    static var polaroidOldFillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidOldFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.one600.fill.symbols" asset catalog image.
    static var polaroidOne600FillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidOne600FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.procam.fill.symbols" asset catalog image.
    static var polaroidProcamFillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidProcamFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.slr.fill.symbols" asset catalog image.
    static var polaroidSlrFillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidSlrFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.spectra.fill.symbols" asset catalog image.
    static var polaroidSpectraFillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidSpectraFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.sx70.fill.symbols" asset catalog image.
    static var polaroidSx70FillSymbols: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .polaroidSx70FillSymbols)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "polaroid.1000.fill.symbols" asset catalog image.
    static var polaroid1000FillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroid1000FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.1200.fill.symbols" asset catalog image.
    static var polaroid1200FillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroid1200FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.600.fill.symbols" asset catalog image.
    static var polaroid600FillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroid600FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.I-1.fill.symbols" asset catalog image.
    static var polaroidI1FillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidI1FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.I-2.fill.symbols" asset catalog image.
    static var polaroidI2FillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidI2FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.amigo.fill.symbols" asset catalog image.
    static var polaroidAmigoFillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidAmigoFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.film.symbols" asset catalog image.
    static var polaroidFilmSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidFilmSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.flip.fill.symbols" asset catalog image.
    static var polaroidFlipFillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidFlipFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.go.fill.symbols" asset catalog image.
    static var polaroidGoFillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidGoFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.joycom.fill.symbols" asset catalog image.
    static var polaroidJoycomFillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidJoycomFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.macro.fill.symbols" asset catalog image.
    static var polaroidMacroFillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidMacroFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.now.fill.symbols" asset catalog image.
    static var polaroidNowFillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidNowFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.old.fill.symbols" asset catalog image.
    static var polaroidOldFillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidOldFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.one600.fill.symbols" asset catalog image.
    static var polaroidOne600FillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidOne600FillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.procam.fill.symbols" asset catalog image.
    static var polaroidProcamFillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidProcamFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.slr.fill.symbols" asset catalog image.
    static var polaroidSlrFillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidSlrFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.spectra.fill.symbols" asset catalog image.
    static var polaroidSpectraFillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidSpectraFillSymbols)
#else
        .init()
#endif
    }

    /// The "polaroid.sx70.fill.symbols" asset catalog image.
    static var polaroidSx70FillSymbols: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .polaroidSx70FillSymbols)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif