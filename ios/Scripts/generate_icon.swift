import AppKit

let root = ProcessInfo.processInfo.environment["SRCROOT"] ?? FileManager.default.currentDirectoryPath
let output = root + "/HeadRoom/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

let background = NSGradient(colors: [
    NSColor(calibratedRed: 0.05, green: 0.07, blue: 0.14, alpha: 1),
    NSColor(calibratedRed: 0.13, green: 0.09, blue: 0.19, alpha: 1)
])!
background.draw(in: NSRect(origin: .zero, size: size), angle: -45)

let ring = NSBezierPath(ovalIn: NSRect(x: 170, y: 170, width: 684, height: 684))
ring.lineWidth = 92
NSColor(calibratedRed: 0.53, green: 0.43, blue: 1.0, alpha: 1).setStroke()
ring.stroke()

let check = NSBezierPath()
check.move(to: NSPoint(x: 330, y: 520))
check.line(to: NSPoint(x: 465, y: 380))
check.line(to: NSPoint(x: 715, y: 655))
check.lineWidth = 94
check.lineCapStyle = .round
check.lineJoinStyle = .round
NSColor(calibratedRed: 0.95, green: 0.28, blue: 0.72, alpha: 1).setStroke()
check.stroke()

let spark = NSBezierPath()
spark.move(to: NSPoint(x: 755, y: 710))
spark.line(to: NSPoint(x: 810, y: 790))
spark.lineWidth = 34
spark.lineCapStyle = .round
NSColor(calibratedRed: 1.0, green: 0.55, blue: 0.22, alpha: 1).setStroke()
spark.stroke()

image.unlockFocus()
guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else { exit(1) }
try png.write(to: URL(fileURLWithPath: output))
