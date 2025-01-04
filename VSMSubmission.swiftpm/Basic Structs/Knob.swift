import SwiftUI

struct Knob: View {
    @ObservedObject var audioProcessor: AudioProcessor
    @Binding var value: Double // 0.0 to 1.0 if constrained
    var isConstrained: Bool = true
    var arcColor: Color = .blue.opacity(0.8)
    
    let size: CGFloat
    let title: String
    let label: String?
    
    var showArc: Bool = true
    var isTappable: Bool = false
    var handleTap: (() -> Void)? = nil
    var showLine: Bool = false

    
    var body: some View {
        VStack(spacing: 12) {
            if showArc{
                Text(title)
                    .foregroundColor(.black)
                    .font(.system(size: 10))
            }
            
            ZStack {
                if showArc{
                    Arc(startAngle: .degrees(135),
                        endAngle: .degrees(135 + 270 * value)
                    )
                    .stroke(arcColor, lineWidth: 10)
                    .frame(width: size, height: size)
                    
                    // thumb on end of the circle
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 15, height: 15)
                        .offset(y: -size/2)
                        .rotationEffect(.degrees(270 * value - 135))
                }
                
                CircleKnob(value: $value,
                           isConstrained: isConstrained,
                           size: size * 0.7,
                           label: label,
                           isTappable: isTappable,
                           handleTap: handleTap,
                           hasBeenTapped: showLine
                )
                
                if showLine {
                    LineIndicator(size: size * 0.7, value: value, color: arcColor)
                }
            }
            .frame(width: size, height: size)
        }
    }
}

struct CircleKnob: View {
    @Binding var value: Double
    let isConstrained: Bool
    let size: CGFloat
    let label: String?
    
    let theme = Theme()
    let isTappable: Bool
    @State private var isDragging = false
    let handleTap: (() -> Void)?
    var hasBeenTapped: Bool
    
    @State private var isPressed = false
    @State private var dragAngle: Double = 0
    @State private var previousAngle: Double = 0
        
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .modifier(ShadowModifier(isPressed: isPressed, theme: theme))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(value * 270 - 135))
                .gesture(
                    // drag
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let dragThreshold: CGFloat = 10.0  // Set the threshold for distinguishing taps from drags

                            if abs(gesture.translation.width) > dragThreshold || abs(gesture.translation.height) > dragThreshold {
                                isDragging = true  // Mark the gesture as a drag
                            }
                            
                            // shadow control
                            else if !hasBeenTapped && isTappable{
                                isPressed = true
                            }

                            // if tappable, only execute the drag once it's tapped
                            if (isDragging && !isTappable) || (isDragging && isTappable && hasBeenTapped) {
                                // Drag logic
                                let center = CGPoint(x: size / 2, y: size / 2)
                                let currentAngle = atan2(gesture.location.y - center.y, gesture.location.x - center.x)
                                
                                if gesture.translation == .zero {
                                    previousAngle = currentAngle
                                }
                                
                                var angleDelta = currentAngle - previousAngle
                                if angleDelta > .pi { angleDelta -= 2 * .pi }
                                if angleDelta < -.pi { angleDelta += 2 * .pi }
                                
                                dragAngle += angleDelta
                                previousAngle = currentAngle
                                
                                let sensitivity: Double = 0.2
                                var newValue = value + (angleDelta / (2 * .pi)) * sensitivity
                                
                                if isConstrained {
                                    newValue = min(max(newValue, 0), 1)
                                }
                                
                                value = newValue
                            }
                        }

                        .onEnded { gesture in
                            if !isDragging {
                                if isTappable && (hasBeenTapped == false) {
                                    (handleTap ?? { print("no tap function") })()
                                }
                            }
                            
                            // Reset  states
                            isDragging = false
                            isPressed = false
                        }
                )
            
            // Center of knob: Custom label or default to progress%
            if let label = label {
                Text(label)
                    .font(.system(size: size/7, weight: .bold))
                    .foregroundStyle(.gray)
                    .minimumScaleFactor(0.5)
                
            }
            
            else {
                Text("\(Int(value * 100))%")
                    .font(.system(size: size/6, weight: .bold))
                    .foregroundStyle(.gray)

            }
        }
    }
}

struct Arc: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        return path
    }
}

struct LineIndicator: View {
    let size: CGFloat
    let value: Double
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Calculate the angle for the line based on value
                let angle = Angle.degrees(360 * value - 90)
                
                // Calculate the end point of the line
                let endX = center.x + cos(angle.radians) * size * 0.9 / 2
                let endY = center.y + sin(angle.radians) * size * 0.9 / 2
                
                // Draw the line from the center to the outer boundary
                path.move(to: center)
                path.addLine(to: CGPoint(x: endX, y: endY))
            }
            .stroke(color, lineWidth: 2)
        }
        .frame(width: size, height: size)
    }
}


struct ShadowModifier: ViewModifier {
    let isPressed: Bool
    let theme: Theme

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isPressed {
                        content.overShadow(using: Circle(), color: theme.darkShadow.opacity(0.6), lineWidth: 2.5)
                    } else {
                        content.underShadow(using: Circle(), color: theme.darkShadow, lineWidth: 2.5)
                    }
                }
            )
    }
}
