
import Foundation

extension Date {
    
    var chatFormatString: String {
        let calendar = NSCalendar.current
        if calendar.isDateInToday(self) {
            return Date.timeFormatter.string(from: self)
        }
        else if calendar.isDateInYesterday(self) {
            return "Yesterday " + Date.timeFormatter.string(from: self)
        }
        return Date.dateTimeFormatter.string(from: self)
    }
    
    fileprivate static var dateTimeFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                return dateFormatter
            }()
        }
        return Static.instance
    }
    
    fileprivate static var timeFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
                return dateFormatter
            }()
        }
        return Static.instance
    }
    
}
