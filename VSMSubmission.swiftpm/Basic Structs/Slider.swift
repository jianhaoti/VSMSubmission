import SwiftUI

struct Slider: View {
    @ObservedObject var audioProcessor: AudioProcessor
    @Binding var value: Float
    @State private var isPressed: Bool = false
    
    let range: ClosedRange<Float>
    let increment: Float
    let center: Float
    let onValueChanged: (Float) -> Void
    let valueFormatter: (Float) -> String
    let formatCurrentValue: (Float) -> String
    
    let thumbSize: CGFloat = 20
    let hideThreshold: Float = 0.001
    let theme = Theme()

    
    var fillColor: Color {
        if audioProcessor.isSampleLoaded {
            return theme.recColor
        } else {
            return Color.gray
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            horizontalSliderContent(geometry: geometry)
        }
        .frame(width: nil, height: 50)
    }
    
    private func horizontalSliderContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 2)
                
                ForEach(Array(stride(from: range.lowerBound, through: range.upperBound, by: increment)), id: \.self) { markerValue in
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 1, height: isLabeledIncrement(markerValue) ? 10 : 7)
                            .offset(y: isLabeledIncrement(markerValue) ? 0 : -6)
                        
                        if isLabeledIncrement(markerValue) && !isThumbOnMarkedIncrement(markerValue) {
                            Text(valueFormatter(markerValue))
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                    }
                    .position(x: position(for: markerValue, in: geometry), y: geometry.size.height / 2)
                }
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: 20)
                    .position(x: position(for: center, in: geometry), y: geometry.size.height / 2)
                    .offset(y: -5)
                
                Circle()
                    .fill(fillColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .scaleEffect(isPressed ? 0.85 : 1)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
                    .position(x: position(for: value, in: geometry),
                              y: (geometry.size.height / 2) - (thumbSize / 4))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                isPressed = true
                                var newValue = value(at: gesture.location.x, in: geometry)
                                newValue = round((newValue - center) / increment) * increment + center
                                self.value = min(max(newValue, range.lowerBound), range.upperBound)
                                onValueChanged(self.value)
                            }
                            .onEnded { _ in
                                isPressed = false
                            }
                    )
            }
            
            Text(formatCurrentValue(value))
                .font(.system(size: 10))
                .foregroundColor(.black)
        }
    }
    
    
    private func position(for value: Float, in geometry: GeometryProxy) -> CGFloat {
        let percent = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return geometry.size.width * CGFloat(percent)
    }

    private func value(at position: CGFloat, in geometry: GeometryProxy) -> Float {
        let percent = Float(position / geometry.size.width)
        return percent * (range.upperBound - range.lowerBound) + range.lowerBound
    }
        
    private func isLabeledIncrement(_ value: Float) -> Bool {
        if abs(value - range.lowerBound) < hideThreshold || abs(value - range.upperBound) < hideThreshold {
            return true
        }
        
        if abs(value - center) < hideThreshold {
            return false
        }
        
        let steps = Int((value - range.lowerBound) / increment)
        return steps % 4 == 0
    }

    private func isThumbOnMarkedIncrement(_ markerValue: Float) -> Bool {
        return abs(markerValue - value) < hideThreshold
    }
}
