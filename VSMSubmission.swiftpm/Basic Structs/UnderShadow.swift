import SwiftUI

extension View{
    func underShadow<S: Shape>(
        using shape: S,
        angle: Angle = .degrees(180),
        color: Color = .black,
        lineWidth: CGFloat = 6,
        blur: CGFloat = 1.5) -> some View {
        let offsetX = CGFloat(cos(angle.radians - .pi/2))
        let offsetY = CGFloat(sin(angle.radians - .pi/2))

        return self
            .overlay(
                shape
                    .stroke(color, lineWidth: lineWidth)
                    .offset(x: offsetX * lineWidth * 0.6, y: offsetY * lineWidth * 0.6)
                    .blur(radius: blur/2)
                    .mask(shape)
            )
    }
}
