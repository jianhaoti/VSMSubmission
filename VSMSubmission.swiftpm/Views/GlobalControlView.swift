import SwiftUI

extension GlobalControlView {
    // Helper functions for labels
    private func getPitchLabel(for value: Float) -> String {
        let cents = Int(value)
        return cents == 0 ? "0c" : "\(cents > 0 ? "+" : "")\(cents)c"
    }
    
    private func getTempoLabel(for value: Float) -> String {
        return String(format: "%.1fx", value)
    }

}

struct GlobalControlView: View{
    @ObservedObject var audioProcessor: AudioProcessor
    @Binding var globalPitchValue: Float
    @Binding var globalTempoValue: Float
    
    var body: some View {
        GeometryReader { sliderGeometry in
            VStack(spacing: 5){
                Text("Pitch and Time")
                    .font(.system(size: 12))
                    .foregroundColor(.black)

                VStack(spacing: 15) {
                    Slider(audioProcessor: audioProcessor,
                           value: $globalPitchValue,
                           range: -600...600,
                           increment: 50,
                           center: 0,
                           onValueChanged: { audioProcessor.setGlobalPitch($0) },
                           valueFormatter: { value in
                        let cents = Int(value)
                        if cents == 0 {
                            return "0"
                        } else {
                            return "\(cents > 0 ? "+" : "")\(cents)"
                        }
                    },
                           formatCurrentValue: { getPitchLabel(for: $0) })
                    .frame(width: sliderGeometry.size.width * 0.8)
                    .disabled(!audioProcessor.isSampleLoaded)
                    
                    Slider(audioProcessor: audioProcessor,
                           value: $globalTempoValue,
                           range: 0.5...1.5,
                           increment: 0.1,
                           center: 1,
                           onValueChanged: { audioProcessor.setGlobalTempo($0) },
                           valueFormatter: { value in
                        return String(format: "%.1f", value)},
                           formatCurrentValue: { getTempoLabel(for: $0) })
                    .frame(width: sliderGeometry.size.width * 0.8)
                    .disabled(!audioProcessor.isSampleLoaded)
                    
                }
            }
            .frame(width: sliderGeometry.size.width, height: sliderGeometry.size.height)
        }
    }
}
