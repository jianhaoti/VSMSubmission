import SwiftUI

extension View {
    func overShadow<S: Shape>(
        using shape: S,
        angle: Angle = .degrees(180),
        color: Color,
        lineWidth: CGFloat,
        blur: CGFloat = 1.5) -> some View {
        let offsetX = CGFloat(cos(angle.radians - .pi/2))
        let offsetY = CGFloat(sin(angle.radians - .pi/2))

        return self
            .overlay(
                shape
                    .stroke(color, lineWidth: lineWidth)
                    .offset(x: -offsetX * lineWidth * 0.6, y: -offsetY * lineWidth * 0.6)
                    .blur(radius: blur)
                    .mask(shape)
            )
    }
}
