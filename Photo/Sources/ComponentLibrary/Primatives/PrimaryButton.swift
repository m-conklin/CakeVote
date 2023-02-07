import SwiftUI

public struct PrimaryButton: View {
    let title: String
    let trailingImage: Image?
    let invertColor: Bool
    let action: () -> Void
    
    public init(
        title: String,
        trailingImage: Image? = nil,
        invertColor: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.trailingImage = trailingImage
        self.invertColor = invertColor
        self.action = action
    }
    
    public var body: some View {
        ZStack(alignment: .trailing) {
            Button(
                action: action,
                label: { Text(title) }
            )
            .buttonStyle(
                PillButtonStyle(invertColor: invertColor)
            )
            
            checkmark
        }
    }
    
    @ViewBuilder
    private var checkmark: some View {
        if let trailingImage {
            trailingImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
        }
    }
}

struct PrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButton(title: "Button", action: {} )
    }
}
