import Foundation

public struct Failure: Error, Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.error.localizedDescription == rhs.error.localizedDescription
    }
    
    public var error: Error
    
    public var localizedDescription: String {
        error.localizedDescription
    }
    
    public init(error: Error) {
        self.error = error
    }
}
