import SwiftUI

struct DelayReverbView: View {
    @ObservedObject var audioProcessor: AudioProcessor
    let theme = Theme()
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        VStack {
            Text("Delay and Reverb")
                .font(.system(size: 12))
                .foregroundColor(.black)
            
            BigBox(height: height * 0.85, width: width * 0.8, strokeWidth: 0, fillColor: .clear)
                .overlay {
                    GeometryReader { geometry in
                        HStack(spacing: 40) {
                            // Wet/Dry Mix Knob (controls both delay and reverb mix)
                            Knob( 
                                audioProcessor: audioProcessor,
                                value: Binding(
                                get: { Double(audioProcessor.mostRecentDelaySettings.wetDryMix / 100) },
                                set: { newValue in
                                audioProcessor.setDelayWetDryMix(Float(newValue) * 100)
                                }
                                ),
                                arcColor: theme.recColor,
                                size: height * 0.6,
                                title: "Mix", // Generic title
                                label: String(format: "%.0f%%", audioProcessor.mostRecentDelaySettings.wetDryMix)
                            )

                            // Delay Time Knob
                            Knob(
                                audioProcessor: audioProcessor,
                                value: Binding(
                                    get: { Double(audioProcessor.mostRecentDelaySettings.delayTime) },
                                    set: { newValue in
                                        audioProcessor.setDelayTime(Float(newValue))
                                    }
                                ),
                                arcColor: Color.blue.opacity(0.8),
                                size: height * 0.6,
                                title: "Time", // Generic title
                                label: String(format: "%.2fs", audioProcessor.mostRecentDelaySettings.delayTime)
                            )

                            // Feedback Knob
                            Knob(
                                audioProcessor: audioProcessor,
                                value: Binding(
                                    get: { Double(audioProcessor.mostRecentDelaySettings.feedback / 100) },
                                    set: { newValue in
                                        audioProcessor.setDelayFeedback(Float(newValue) * 100)
                                    }
                                ),
                                arcColor: Color.blue.opacity(0.8),
                                size: height * 0.6,
                                title: "Feedback", 
                                label: String(format: "%.0f%%", audioProcessor.mostRecentDelaySettings.feedback)
                            )
                            
                            // Low Pass Cutoff Knob
                            Knob(
                                audioProcessor: audioProcessor,
                                value: Binding(
                                    get: { Double((audioProcessor.mostRecentDelaySettings.lowPassCutoff - 2000) / 18000)},
                                    set: { newValue in
                                        audioProcessor.setDelayLowPassCutoff(Float(newValue * 18000 + 2000))
                                    }
                                ),
                                arcColor: Color.blue.opacity(0.8),
                                size: height * 0.6,
                                title: "Low-Pass", // Generic title
                                label: String(format: "%.0f Hz", audioProcessor.mostRecentDelaySettings.lowPassCutoff)
                            )
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
        }
        .frame(width: width, height: height)
    }
}
