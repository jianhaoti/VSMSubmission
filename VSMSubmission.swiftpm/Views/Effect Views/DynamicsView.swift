import SwiftUI

struct DynamicsView: View {
    @ObservedObject var audioProcessor: AudioProcessor
    let theme = Theme()
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        HStack(spacing: 45) {
            // Threshold Knob
            Knob(
                audioProcessor: audioProcessor,
                value: Binding(
                    get: { audioProcessor.normalizedDynamicsThreshold },
                    set: { audioProcessor.setNormalizedDynamicsThreshold($0) }
                ),
                size: height * 0.6,
                title: "Threshold",
                label: String(format: "%.1f dB", audioProcessor.currentDynamicsSettings?.highThreshold ?? -15.0)
            )

            // Big Box in the center
            VStack {
                HStack {
                    Text("Compressor")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                }
                
                ZStack {
                    BigBox(height: height * 0.85, width: width * 0.5)
                        .overlay(
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                Text("Ratio: ")
                                    .font(.system(size: 8))
                                    .foregroundColor(Color.red.opacity(0.8))
                                Text(String(format: "%.1f:1", audioProcessor.currentDynamicsSettings?.ratio ?? 2.0))
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.red.opacity(0.8))
                            }
                            .padding(6),
                            alignment: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10)) // Clip BigBox
                    
                    DynamicsShapeView(audioProcessor: audioProcessor, size: CGSize(width: width * 0.5, height: height * 0.7))
                    .frame(width: width * 0.5, height: height * 0.7) // Match BigBox size
                }
            }
            
            // Ratio Knob
            Knob(
                audioProcessor: audioProcessor,
                value: Binding(
                    get: { audioProcessor.normalizedDynamicsRatio },
                    set: { audioProcessor.setNormalizedDynamicsRatio($0) }
                 ),
                arcColor: theme.recColor,
                size: height * 0.6,
                title: "Ratio",
                label: String(format: "%.1f:1", audioProcessor.currentDynamicsSettings?.ratio ?? 2.0)
            )
        }
        .frame(width: width, height: height)
    }
}
