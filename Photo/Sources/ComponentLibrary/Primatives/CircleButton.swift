import SwiftUI

public struct CircleButton: View {
    private let title: String
    private let action: () -> Void
    
    public init(
        title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(
            action: action,
            label: {
                Image(systemName: title)
                    .imageScale(.large)
            }
        )
        .buttonStyle(
            CircleButtonStyle()
        )
    }
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        CircleButton(title: "<", action: {})
    }
}
