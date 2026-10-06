import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

enum ProviderBrand {
    case openAI
    case anthropic
    case cursor
    case generic

    static func resolve(providerID: String) -> ProviderBrand {
        switch providerID {
        case "openai": .openAI
        case "anthropic": .anthropic
        case "cursor-team", "cursor-personal": .cursor
        default:
            providerID.hasPrefix("cursor") ? .cursor : .generic
        }
    }

    /// Asset catalog image set with light/dark SVG variants (black on light, white on dark).
    var assetName: String? {
        switch self {
        case .openAI: "ProviderOpenAI"
        case .anthropic: "ProviderAnthropic"
        case .cursor: "ProviderCursor"
        case .generic: nil
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .openAI: "OpenAI"
        case .anthropic: "Anthropic"
        case .cursor: "Cursor"
        case .generic: "Provider"
        }
    }

    var fallbackSystemImage: String {
        "circle.fill"
    }

    /// Compensates for extra padding baked into official artwork (e.g. OpenAI Blossom).
    var displayScale: CGFloat {
        switch self {
        case .openAI: 1.25
        default: 1
        }
    }
}

struct ProviderBrandIcon: View {
    @Environment(\.colorScheme) private var colorScheme

    let providerID: String
    var size: CGFloat = 12
    /// Rasterize catalog SVGs for MenuBarExtra only; Settings uses standard SwiftUI scaling.
    var rendersForMenuBar: Bool = false

    private var brand: ProviderBrand { ProviderBrand.resolve(providerID: providerID) }
    private var renderedSize: CGFloat { size * brand.displayScale }

    var body: some View {
        Group {
            if let assetName = brand.assetName {
                #if os(macOS)
                if rendersForMenuBar,
                   let image = ProviderBrandIconImage.scaledAsset(
                    named: assetName,
                    pointSize: renderedSize,
                    colorScheme: colorScheme
                   ) {
                    Image(nsImage: image)
                        .interpolation(.high)
                } else {
                    swiftUIAssetImage(assetName)
                }
                #else
                swiftUIAssetImage(assetName)
                #endif
            } else {
                Image(systemName: brand.fallbackSystemImage)
                    .font(.system(size: size * 0.85, weight: .semibold))
                    .foregroundStyle(.primary)
            }
        }
        .frame(width: renderedSize, height: renderedSize)
        .clipped()
        .accessibilityLabel(brand.accessibilityLabel)
    }

    private func swiftUIAssetImage(_ assetName: String) -> some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
    }
}

#if os(macOS)
/// MenuBarExtra ignores SwiftUI frame constraints on vector catalog images; rasterize to a fixed size.
@MainActor
enum ProviderBrandIconImage {
    private static let cache = NSCache<NSString, NSImage>()
    private static var didInstallAppearanceObserver = false

    static func installAppearanceObserverIfNeeded() {
        guard !didInstallAppearanceObserver else { return }
        didInstallAppearanceObserver = true
        NotificationCenter.default.addObserver(
            forName: .init("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                cache.removeAllObjects()
            }
        }
    }

    static func scaledAsset(
        named name: String,
        pointSize side: CGFloat,
        colorScheme: ColorScheme
    ) -> NSImage? {
        installAppearanceObserverIfNeeded()

        let scale = NSScreen.main?.backingScaleFactor ?? 2
        let appearanceKey = colorScheme == .dark ? "dark" : "light"
        let key = "\(name)-\(side)-\(scale)-\(appearanceKey)" as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        var output: NSImage?
        NSApp.effectiveAppearance.performAsCurrentDrawingAppearance {
            output = rasterize(named: name, pointSize: side, scale: scale)
        }
        if let output {
            cache.setObject(output, forKey: key)
        }
        return output
    }

    private static func rasterize(named name: String, pointSize side: CGFloat, scale: CGFloat) -> NSImage? {
        guard let source = NSImage(named: name) else { return nil }

        let pixelSide = max(1, Int((side * scale).rounded()))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: pixelSide,
            height: pixelSide,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.interpolationQuality = .high
        context.clear(CGRect(x: 0, y: 0, width: pixelSide, height: pixelSide))

        let sourceRect = NSRect(origin: .zero, size: source.size)
        guard let representation = source.bestRepresentation(
            for: sourceRect,
            context: nil,
            hints: nil
        ) else { return nil }

        let fitScale = min(
            CGFloat(pixelSide) / representation.size.width,
            CGFloat(pixelSide) / representation.size.height
        )
        let drawSize = NSSize(
            width: representation.size.width * fitScale,
            height: representation.size.height * fitScale
        )
        let drawOrigin = NSPoint(
            x: (CGFloat(pixelSide) - drawSize.width) / 2,
            y: (CGFloat(pixelSide) - drawSize.height) / 2
        )

        NSGraphicsContext.saveGraphicsState()
        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.current = graphicsContext
        representation.draw(
            in: NSRect(origin: drawOrigin, size: drawSize),
            from: NSRect(origin: .zero, size: representation.size),
            operation: .sourceOver,
            fraction: 1,
            respectFlipped: false,
            hints: nil
        )
        NSGraphicsContext.restoreGraphicsState()

        guard let cgImage = context.makeImage() else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: side, height: side))
    }
}
#endif
