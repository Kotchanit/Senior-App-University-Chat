import Foundation

extension Date {
    
    public init?(iso8601: String) {
        guard let date = Date.iso8601DateFormatter.date(from: iso8601) else {
            return nil
        }
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    
    var iso8601DateString: String {
        return Date.iso8601DateFormatter.string(from: self)
    }
    
    fileprivate static var iso8601DateFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                return dateFormatter
            }()
        }
        return Static.instance
    }
    
}
