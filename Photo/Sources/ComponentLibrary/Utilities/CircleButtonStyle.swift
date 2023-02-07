import SwiftUI

struct CircleButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration
                .label
        }
        .foregroundColor(.gray)
        .frame(width: 52, height: 52)
        .padding(2)
        .background(
            Circle()
                .fill(.white)
        )
        .overlay(
            Circle()
                .stroke(.gray)
        )
        .contentShape(Circle())
    }
}
