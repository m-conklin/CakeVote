import SwiftUI

public struct PillButtonStyle: ButtonStyle {
    let invertColor: Bool
    
    public init(invertColor: Bool = false) {
        self.invertColor = invertColor
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration
                .label
        }
        .foregroundColor(invertColor ? .white : .gray)
        .frame(maxWidth: .infinity, minHeight: 52)
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(invertColor ? .gray : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(invertColor ? .white : .gray)
        )
        .contentShape(Rectangle())
    }
}
