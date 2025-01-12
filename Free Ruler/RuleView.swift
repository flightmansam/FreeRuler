import Cocoa

struct RulerColors {
    let fill = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
    let numbers = #colorLiteral(red: 0.6829560399, green: 0.4503545761, blue: 0.09706548601, alpha: 1)
    let ticks = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
    let mouseTick = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 0.75)
    let mouseTickRelative = #colorLiteral(red: 0.5759353042, green: 0, blue: 0.0918385759, alpha: 0.75)
    let mouseNumber = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
}

class RuleView: NSView {

    let color = RulerColors()

    var trackingArea: NSTrackingArea?
    let trackingAreaOptions: NSTrackingArea.Options = [
        .mouseMoved,
        .mouseEnteredAndExited,
        .activeAlways,
        .inVisibleRect,
    ]
    
    var currentXString = String()
    var currentYString = String()

    private var referencePoint: NSPoint?

    func flipReferencePoint(location: NSPoint) {
        referencePoint = referencePoint == nil ? location : nil
        drawMouseTick(at: location)
    }

    func setReferencePoint(location: NSPoint) {
        referencePoint = location
        drawMouseTick(at: location)
    }

    func clearReferencePoint() {
        referencePoint = nil
    }

    func getReferencePoint() -> NSPoint? {
        return referencePoint
    }
    
    func relativeY(mouseTickY: CGFloat) -> CGFloat {
        if let refLoc = getReferencePoint() {
            let windowY = self.window?.frame.origin.y ?? 0
            let correction = -(refLoc.y - windowY - windowHeight)
            return mouseTickY - correction
        }
        return mouseTickY
    }
    
    func relativeX(mouseTickX: CGFloat) -> CGFloat {
        if let refLoc = getReferencePoint() {
            let windowX = self.window?.frame.origin.x ?? 0
            let correction = refLoc.x - windowX
            return mouseTickX - correction
        }
        return mouseTickX
    }

    override func updateTrackingAreas() {
        if trackingArea != nil {
            removeTrackingArea(trackingArea!)
        }

        trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: trackingAreaOptions,
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea!)
    }

    func drawMouseTick(at mouseLoc: NSPoint) {
        // required override
        // TODO: is there a better way to do this, maybe via a protocol?
        // AppDelegate needs to be able to infer that any RulerView has this method
        fatalError("RuleView subclass must override drawMouseTick method.")
    }

    var windowWidth: CGFloat {
        return self.window?.frame.width ?? 0
    }

    var windowHeight: CGFloat {
        return self.window?.frame.height ?? 0
    }

    var showMouseTick: Bool = true {
        didSet {
            if showMouseTick != oldValue {
                needsDisplay = true
            }
        }
    }
    
    var screen: NSScreen? {
        guard let window = window else {
            return nil
        }
        return NSScreen.screens.first { $0.frame.intersects(window.convertToScreen(frame)) }
    }

    func getUnitLabel() -> String {
        switch prefs.unit {
        case .pixels:
            return "px"
        case .millimeters:
            return "mm"
        case .inches:
            return "in"
        case .ratio:
            if frame.height > frame.width {
                return "y:1.0";
            } else {
                return "x:1.0";
            }
        }
    }

    func getMouseNumberLabel(_ number: CGFloat) -> String {
        switch prefs.unit {
        case .pixels:
            return String(format: "%d", Int(number))
        case .millimeters:
            return String(format: "%.1f", number / (screen?.dpmm.width ?? NSScreen.defaultDpmm))
        case .inches:
            return String(format: "%.3f", number / (screen?.dpi.width ?? NSScreen.defaultDpi))
        case .ratio:
            if frame.height > frame.width {
                return String(format: "%.3f", number/frame.height);
            } else {
                return String(format: "%.3f", number/frame.width);
            }
            
        }
    }

}

fileprivate let mmPerIn: CGFloat = 25.4

public extension NSScreen {

    // This is the same as what CoreGraphics assumes if no EDID data is available from the display device
    // https://developer.apple.com/documentation/coregraphics/1456599-cgdisplayscreensize
    static let defaultDpi: CGFloat = 72.0
    static let defaultDpmm: CGFloat = defaultDpi / mmPerIn
    
    var dpmm: CGSize {
        if let resolution = (deviceDescription[.size] as? NSValue)?.sizeValue,
           let screenNumber = (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value {
            let physicalSize = CGDisplayScreenSize(screenNumber)
            return CGSize(width: resolution.width / physicalSize.width,
                          height: resolution.height / physicalSize.height)
        } else {
            return CGSize(width: NSScreen.defaultDpmm, height: NSScreen.defaultDpmm)
        }
    }
    
    var dpi: CGSize {
        return CGSize(width: mmPerIn * dpmm.width,
                      height: mmPerIn * dpmm.height)
    }
    
}
