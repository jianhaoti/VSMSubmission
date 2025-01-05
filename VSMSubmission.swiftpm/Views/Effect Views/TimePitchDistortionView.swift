import SwiftUI

struct TimePitchDistortionView: View {
    @ObservedObject var audioProcessor: AudioProcessor
    let theme = Theme()
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        HStack(spacing: 20) {
            // Pan Control Knob
//            Knob(
//                audioProcessor: audioProcessor,
//                value: Binding(
//                    get: {
//                        audioProcessor.getNormalizedPan(for: audioProcessor.selectedPadID ?? 0) // Get the normalized pan value (0.0 to 1.0)
//                    },
//                    set: { newValue in
//                        audioProcessor.setNormalizedPan(for: audioProcessor.selectedPadID ??  0, normalizedValue: newValue) // Set the pan using the normalized value
//                    }
//                ),
//                arcColor: Color.blue.opacity(0.8),
//                size: height * 0.6,
//                title: "Pan",
//                label: {
//                    let pan = audioProcessor.padPanSettings[audioProcessor.selectedPadID ?? 0] ?? 0.0
//                    if pan > 0.05 {
//                        return "Right"
//                    } else if pan < -0.05 {
//                        return "Left"
//                    } else{
//                        return "Center"
//                    }
//                }()
//            )
            
            // Pitch+Time Sliders
            VStack {
                Text("Pitch and Time")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                
                BigBox(height: height * 0.85, width: width * (1/3), strokeWidth: 0, fillColor: .clear)
                    .overlay {
                        GeometryReader { geometry in
                            VStack(spacing: 20) {
                                // Pitch Slider
                                Slider(
                                    audioProcessor: audioProcessor,
                                    value: Binding(
                                        get: {
                                            let padID = audioProcessor.selectedPadID ?? 0
                                            return audioProcessor.padPitchOffsets[padID] ?? 0.0
                                        },
                                        set: { newValue in
                                            if let padID = audioProcessor.selectedPadID {
                                                audioProcessor.setPadPitchOffset(padID: padID, newValue)
                                            }
                                        }
                                    ),
                                    range: -600...600,
                                    increment: 50,
                                    center: 0,
                                    onValueChanged: { _ in },
                                    valueFormatter: { value in
                                        let cents = Int(value)
                                        return cents == 0 ? "0" : "\(cents > 0 ? "+" : "")\(cents)"
                                    },
                                    formatCurrentValue: { value in
                                        let cents = Int(value)
                                        return "\(cents > 0 ? "+" : "")\(cents)c"
                                    }
                                )
                                .frame(width: geometry.size.width * 0.8) // Fit slider within the available space
                                
                                // Tempo Slider
                                Slider(
                                    audioProcessor: audioProcessor,
                                    value: Binding(
                                        get: {
                                            let padID = audioProcessor.selectedPadID ?? 0
                                            return audioProcessor.padTempoOffsets[padID] ?? 1.0
                                        },
                                        set: { newValue in
                                            if let padID = audioProcessor.selectedPadID {
                                                audioProcessor.setPadTempoOffset(padID: padID, newValue)
                                            }
                                        }
                                    ),
                                    range: 0.5...1.5,
                                    increment: 0.1,
                                    center: 1.0,
                                    onValueChanged: { _ in },
                                    valueFormatter: { value in
                                        String(format: "%.1fx", value)
                                    },
                                    formatCurrentValue: { value in
                                        String(format: "%.1fx", value)
                                    }
                                )
                                .frame(width: geometry.size.width * 0.8) // Fit slider within the available space
                            }
                            .padding(.horizontal, 10)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
            }
            
            
            // Distortion Knobs
            VStack {
                Text("Distortion")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                
                BigBox(height: height * 0.85, width: width * (1/2), strokeWidth: 0, fillColor: Color.clear)
                    .overlay {
                        GeometryReader { geometry in
                            HStack(spacing: 40) {
                                
                                // dry/wet
                                Knob(
                                    audioProcessor: audioProcessor,
                                    value: Binding(
                                        get: {
                                            let padID = audioProcessor.selectedPadID ?? 0
                                            return Double(audioProcessor.padDistortionSettings[padID]?.wetDryMix ?? 50.0) / 100
                                        },
                                        set: { newValue in
                                            if let padID = audioProcessor.selectedPadID {
                                                audioProcessor.setPadDistortionWetDryMix(padID: padID, value: Float(newValue * 100))
                                            }
                                        }
                                    ),
                                    arcColor: theme.recColor,
                                    size: height * 0.6,
                                    title: "Mix",
                                    label: {
                                        let wetDryMix = audioProcessor.padDistortionSettings[audioProcessor.selectedPadID ?? 0]?.wetDryMix ?? 50
                                        return wetDryMix == 0 ? "Off" : String(format: "%.0f%%", wetDryMix)
                                    }()
                                )

                                // pre-Gain
                                Knob(
                                    audioProcessor: audioProcessor,
                                    value: Binding(
                                        get: {
                                            let padID = audioProcessor.selectedPadID ?? 0
                                            return Double((audioProcessor.padDistortionSettings[padID]?.preGain ?? 0.0) + 20) / 40
                                        },
                                        set: { newValue in
                                            if let padID = audioProcessor.selectedPadID {
                                                audioProcessor.setPadDistortionPreGain(padID: padID, value: Float(newValue * 40 - 20))
                                            }
                                        }
                                    ),
                                    arcColor: Color.blue.opacity(0.8),
                                    size: height * 0.6,
                                    title: "Pre-Gain",
                                    label: String(format: "%.0f dB", audioProcessor.padDistortionSettings[audioProcessor.selectedPadID ?? 0]?.preGain ?? 0)
                                )
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
            }   
        }
    }
}
