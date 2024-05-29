public struct GDColor {
    public var redComponent: Double
    public var greenComponent: Double
    public var blueComponent: Double
    public var alphaComponent: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        redComponent = red
        greenComponent = green
        blueComponent = blue
        alphaComponent = alpha
    }
}

// MARK: Constants

extension GDColor {
    public static let red = GDColor(red: 1, green: 0, blue: 0, alpha: 1)

    public static let green = GDColor(red: 0, green: 1, blue: 0, alpha: 1)

    public static let blue = GDColor(red: 0, green: 0, blue: 1, alpha: 1)

    public static let black = GDColor(red: 0, green: 0, blue: 0, alpha: 1)

    public static let white = GDColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    public static let clear = GDColor(red: 0, green: 0, blue: 0, alpha: 0)
}

// MARK: Utils

extension GDColor {
    public static func random(alpha: Double = 0.5) -> GDColor {
        // Randomize the red, green, blue, and alpha (if not opaque) components of the color.
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        
        return GDColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// MARK: Hexadecimal

extension GDColor {
    /// The maximum representable integer for each color component.
    private static let maxHex: Int = 0xff

    /// Initializes a new `Color` instance of given hexadecimal color string.
    ///
    /// Given string will be stripped from a single leading "#", if applicable.
    /// Resulting string must met any of the following criteria:
    ///
    /// - Is a string with 8-characters and therefore a fully fledged hexadecimal
    ///   color representation **including** an alpha component. Given value will remain
    ///   untouched before conversion. Example: `ffeebbaa`
    /// - Is a string with 6-characters and therefore a fully fledged hexadecimal color
    ///   representation **excluding** an alpha component. Given RGB color components will
    ///   remain untouched and an alpha component of `0xff` (opaque) will be extended before
    ///   conversion. Example: `ffeebb` -> `ffeebbff`
    /// - Is a string with 4-characters and therefore a shortened hexadecimal color
    ///   representation **including** an alpha component. Each single character will be
    ///   doubled before conversion. Example: `feba` -> `ffeebbaa`
    /// - Is a string with 3-characters and therefore a shortened hexadecimal color
    ///   representation **excluding** an alpha component. Given RGB color character will
    ///   be doubled and an alpha of component of `0xff` (opaque) will be extended before
    ///   conversion. Example: `feb` -> `ffeebbff`
    ///
    /// - Parameters:
    ///   - string: The hexadecimal color string.
    ///   - leadingAlpha: Indicate whether given string should be treated as ARGB (`true`) or RGBA (`false`)
    /// - Throws: `.invalidColor` if given string does not match any of the above mentioned criteria or is not a valid hex color.
    public init(hex string: String, leadingAlpha: Bool = false) throws {
        let string = try GDColor.sanitize(hex: string, leadingAlpha: leadingAlpha)
        guard let code = Int(string, radix: 16) else {
            throw GDError.invalidColor(reason: "0x\(string) is not a valid hex color code")
        }
        self.init(hex: code, leadingAlpha: leadingAlpha)
    }

    /// Initializes a new `Color` instance of given hexadecimal color values.
    ///
    /// - Parameters:
    ///   - color: The hexadecimal color value, incl. red, green, blue and alpha
    ///   - leadingAlpha: Indicate whether given code should be treated as ARGB (`true`) or RGBA (`false`)
    public init(hex color: Int, leadingAlpha: Bool = false) {
        let max = Double(GDColor.maxHex)
        let first = Double((color >> 24) & GDColor.maxHex) / max
        let secnd = Double((color >> 16) & GDColor.maxHex) / max
        let third = Double((color >>  8) & GDColor.maxHex) / max
        let forth = Double((color >>  0) & GDColor.maxHex) / max
        if leadingAlpha {
            self.init(red: secnd, green: third, blue: forth, alpha: first) // ARGB
        } else {
            self.init(red: first, green: secnd, blue: third, alpha: forth) // RGBA
        }
    }

    // MARK: Private helper

    /// Sanitizes given hexadecimal color string (strips # and forms proper length).
    ///
    /// - Parameters:
    ///   - string: The hexadecimal color string to sanitize
    ///   - leadingAlpha: Indicate whether given and returning string should be treated as ARGB (`true`) or RGBA (`false`)
    /// - Returns: The sanitized hexadecimal color string
    /// - Throws: `.invalidColor` if given string is not of proper length
    private static func sanitize(hex string: String, leadingAlpha: Bool) throws -> String {

        // Drop leading "#" if applicable
        var string = string.hasPrefix("#") ? String(string.dropFirst(1)) : string

        // Evaluate if short code w/wo alpha (e.g. `feb` or `feb4`). Double up the characters if so.
        if string.count == 3 || string.count == 4 {
            string = string.map({ "\($0)\($0)" }).joined()
        }

        // Evaluate if fully fledged code w/wo alpha (e.g. `ffaabb` or `ffaabb44`), otherwise throw error
        switch string.count {
        case 6: // Hex color code without alpha (e.g. ffeeaa)
            let alpha = String(GDColor.maxHex, radix: 16) // 0xff (opaque)
            return leadingAlpha ? alpha + string : string + alpha
        case 8: // Fully fledged hex color including alpha (e.g. eebbaa44)
            return string
        default:
            throw GDError.invalidColor(reason: "0x\(string) has invalid hex color string length")
        }
    }
}
