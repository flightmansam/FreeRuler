import Foundation

// Prefs
// a KVO bridge for UserDefaults
// - registers default values
// - exposes defaults on the prefs instance for key-value observation
// - listens for changes and persists new values to UserDefaults
// - provides save method to synchronize UserDefaults on applicationWillTerminate

// TODO: there's a lot of boilerplate in here, not sure if we can reduce it
// TODO: figure out how avoid saving values that haven't changed from the default

// MARK: - global shortcut to shared prefs instance
let prefs = Prefs.shared

@objc enum Unit: Int {
    case pixels
    case millimeters
    case inches
    case ratio
}

class Prefs: NSObject {

    // MARK: - shared singleton instance
    static let shared = Prefs()

    // MARK: - public properties
    @objc dynamic var floatRulers       : Bool
    @objc dynamic var groupRulers       : Bool
    @objc dynamic var rulerShadow       : Bool
    @objc dynamic var foregroundOpacity : Int
    @objc dynamic var backgroundOpacity : Int
    @objc dynamic var unit              : Unit

    // MARK: - public save method
    func save() {
        defaults.synchronize()
    }

    // MARK: - private implementation

    private let defaults = UserDefaults.standard

    private var defaultValues: [String: Any] = [
        "groupRulers":       true,
        "floatRulers":       true,
        "rulerShadow":       false,
        "foregroundOpacity": 90,
        "backgroundOpacity": 50,
        "unit":              Unit.pixels.rawValue
    ]

    private override init() {
        defaults.register(defaults: defaultValues)

        floatRulers       = defaults.bool(forKey: "floatRulers")
        groupRulers       = defaults.bool(forKey: "groupRulers")
        rulerShadow       = defaults.bool(forKey: "rulerShadow")
        foregroundOpacity = defaults.integer(forKey: "foregroundOpacity")
        backgroundOpacity = defaults.integer(forKey: "backgroundOpacity")
        unit              = Unit(rawValue: defaults.integer(forKey: "unit")) ?? .pixels

        super.init()

        addObservers()
    }

    private var observers: [NSKeyValueObservation] = []

    private func addObservers() {
        observers = [
            observe(\Prefs.floatRulers, options: .new) { prefs, changed in
                self.defaults.set(changed.newValue, forKey: "floatRulers")
            },
            observe(\Prefs.groupRulers, options: .new) { prefs, changed in
                self.defaults.set(changed.newValue, forKey: "groupRulers")
            },
            observe(\Prefs.rulerShadow, options: .new) { prefs, changed in
                self.defaults.set(changed.newValue, forKey: "rulerShadow")
            },
            observe(\Prefs.foregroundOpacity, options: .new) { prefs, changed in
                self.defaults.set(changed.newValue, forKey: "foregroundOpacity")
            },
            observe(\Prefs.backgroundOpacity, options: .new) { prefs, changed in
                self.defaults.set(changed.newValue, forKey: "backgroundOpacity")
            },
            observe(\Prefs.unit, options: .new) { prefs, changed in
                self.defaults.set(prefs.unit.rawValue, forKey: "unit")
            },
        ]
    }

}
