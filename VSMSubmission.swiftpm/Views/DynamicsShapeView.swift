import SwiftUI

struct DynamicsShapeView: View {
    @ObservedObject var audioProcessor: AudioProcessor
    let size: CGSize

    var body: some View {
        GeometryReader { geometry in
            let cornerRadius: CGFloat = 0
            let adjustedWidth = geometry.size.width
            let adjustedHeight = geometry.size.height

            let normalizedThreshold = CGFloat(audioProcessor.normalizedDynamicsThreshold)

            let thresholdX = adjustedWidth * normalizedThreshold
            let thresholdY = cornerRadius + adjustedHeight * (1 - normalizedThreshold)

            ZStack {
                // Input diagonal line (gray)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: thresholdX, y: thresholdY))
                }
                .stroke(Color.gray, lineWidth: 1)
                
                // Dashed continuation of 1:1 line
                if (audioProcessor.currentDynamicsSettings?.ratio ?? 2.0) != 1 {
                    Path { path in
                        path.move(to: CGPoint(x: thresholdX, y: thresholdY))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: max(0, thresholdY - (adjustedWidth - thresholdX))))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(Color.gray.opacity(0.5))
                }

                // Output diagonal line (red)
                Path { path in
                    path.move(to: CGPoint(x: thresholdX, y: thresholdY))
                    let aspectRatio = geometry.size.width / geometry.size.height
                    let slope = 1 / CGFloat(audioProcessor.currentDynamicsSettings?.ratio ?? 2.0)

                    let endX = geometry.size.width
                    let endY = thresholdY - (endX - thresholdX) * slope / aspectRatio

                    path.addLine(to: CGPoint(x: endX, y: max(0, endY)))
                }
                .stroke(Color.red.opacity(0.8), lineWidth: 1.5)

                // Threshold line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: thresholdY))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: thresholdY))
                }
                .stroke(Color.blue, lineWidth: 1.5)

                // Threshold value
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("Threshold: ")
                        .font(.system(size: 8))
                        .foregroundColor(.blue)
                    Text(String(format: "%.1f dB", audioProcessor.currentDynamicsSettings?.highThreshold ?? -15.0))
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
                .position(x: geometry.size.width * 0.2, y: thresholdY - 10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10)) // Clip contents inside BigBox
        }
        .frame(width: size.width, height: size.height)
    }
}
