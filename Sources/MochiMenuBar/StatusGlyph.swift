// Original Mochi menu bar artwork, added for this fork.
import AppKit

/// A smiling window rendered as a monochrome template. The lower-right badge communicates
/// connection state without depending on color, so it works in either menu bar appearance.
enum StatusGlyph {
    enum State: Equatable, CaseIterable { case idle, connected, streaming, attention }
    static let size = NSSize(width: 22, height: 18)

    static let symbolFallback: NSImage? = {
        let image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: "Mochi")
        image?.isTemplate = true
        return image
    }()

    static func image(_ state: State) -> NSImage {
        let image = NSImage(size: size, flipped: true) { _ in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            draw(state, in: context)
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Mochi"
        return image
    }

    private static func draw(_ state: State, in ctx: CGContext) {
        ctx.setFillColor(NSColor.black.cgColor)
        ctx.setStrokeColor(NSColor.black.cgColor)
        ctx.setLineWidth(1.4)
        ctx.setLineCap(.round)
        ctx.addPath(CGPath(roundedRect: CGRect(x: 1.5, y: 2, width: 18, height: 14),
                           cornerWidth: 4, cornerHeight: 4, transform: nil))
        ctx.strokePath()
        ctx.move(to: CGPoint(x: 2, y: 6))
        ctx.addLine(to: CGPoint(x: 19, y: 6))
        ctx.strokePath()
        for x in [CGFloat(5), 7.5] {
            ctx.fillEllipse(in: CGRect(x: x, y: 3.5, width: 1, height: 1))
        }
        for x in [CGFloat(7), 13] {
            ctx.fillEllipse(in: CGRect(x: x, y: 8.5, width: 1.3, height: 1.7))
        }
        ctx.move(to: CGPoint(x: 8.5, y: 12))
        ctx.addQuadCurve(to: CGPoint(x: 12.5, y: 12), control: CGPoint(x: 10.5, y: 15))
        ctx.strokePath()
        guard state != .idle else { return }
        let badge = CGRect(x: 15, y: 11, width: 7, height: 7)
        ctx.setBlendMode(.clear)
        ctx.fillEllipse(in: badge.insetBy(dx: -0.8, dy: -0.8))
        ctx.setBlendMode(.normal)
        ctx.fillEllipse(in: badge)
        ctx.setBlendMode(.clear)
        if state == .streaming {
            ctx.move(to: CGPoint(x: 17.5, y: 12.7))
            ctx.addLine(to: CGPoint(x: 20.2, y: 14.5))
            ctx.addLine(to: CGPoint(x: 17.5, y: 16.3))
            ctx.closePath()
            ctx.fillPath()
        } else if state == .attention {
            ctx.fill(CGRect(x: 18, y: 12, width: 1, height: 3))
            ctx.fillEllipse(in: CGRect(x: 18, y: 15.7, width: 1, height: 1))
        }
        ctx.setBlendMode(.normal)
    }
}
