// Mochi's selected A1 artwork, resized for platform icons without changing the design.
import AppKit

let sourceURL = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    .deletingLastPathComponent().appendingPathComponent("design/MochiCharacter.png")
guard let artwork = NSImage(contentsOf: sourceURL) else {
    fatalError("Missing Mochi character artwork at \(sourceURL.path)")
}
func render(size: Int, to path: String) throws {
    guard let source = artwork.cgImage(forProposedRect: nil, context: nil, hints: nil),
          let context = CGContext(data: nil, width: size, height: size,
                                  bitsPerComponent: 8, bytesPerRow: size * 4,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
        throw NSError(domain: "MochiIcon", code: 1)
    }
    context.interpolationQuality = .high
    context.draw(source, in: CGRect(x: 0, y: 0, width: size, height: size))
    guard let image = context.makeImage(),
          let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
        throw NSError(domain: "MochiIcon", code: 2)
    }
    try png.write(to: URL(fileURLWithPath: path), options: .atomic)
}
guard CommandLine.arguments.count == 2 else { fatalError("usage: render-mochi-icon <output directory>") }
let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let icons = output.appendingPathComponent("Mochi.iconset", isDirectory: true)
try FileManager.default.createDirectory(at: icons, withIntermediateDirectories: true)
for points in [16, 32, 128, 256, 512] {
    try render(size: points, to: icons.appendingPathComponent("icon_\(points)x\(points).png").path)
    try render(size: points * 2, to: icons.appendingPathComponent("icon_\(points)x\(points)@2x.png").path)
}
try render(size: 1024, to: output.appendingPathComponent("AppIcon.png").path)
print("Mochi icons rendered in \(output.path)")
