import Cocoa
import FlutterMacOS
class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // 1. Strip all window borders and titles
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.styleMask.insert(.fullSizeContentView)

    // 2. Force total transparency on the OS layer
    self.isOpaque = false
    self.backgroundColor = NSColor.clear
    self.hasShadow = false
    self.invalidateShadow()

    // 3. Force the underlying Flutter View itself to be transparent
    flutterViewController.backgroundColor = NSColor.clear

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}