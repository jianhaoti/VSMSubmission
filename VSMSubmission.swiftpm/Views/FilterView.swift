import SwiftUI

struct FilterView: View {
    @ObservedObject var audioProcessor: AudioProcessor
    let width: CGFloat
    let height: CGFloat
    let centerX: CGFloat
    
    let theme = Theme()
    
    @State private var lastDragValue: CGPoint?
    @State private var lastZoomScale: CGFloat = 1.0
    
    private func getFrequencyRangeLabel(frequency: Float) -> String {
        switch frequency {
        case 0..<60: return "Sub"
        case 60..<250: return "Bass"
        case 250..<500: return "Low Mid"
        case 500..<2000: return "Mid"
        case 2000..<4000: return "High Mid"
        case 4000..<6000: return "Presence"
        case 6000...: return "Treble"
        default: return ""
        }
    }
    
    var currentParameterValueString: String {
        guard let settings = audioProcessor.currentFilterSettings else { return "" }
        switch audioProcessor.currentFilterParameter {
        case .frequency:
            return String(format: "%.0f Hz", settings.frequency)
        case .bandwidth:
            return String(format: "%.2f Q", settings.bandwidth)
        case .gain:
            return String(format: "%.1f dB", settings.gain)
        }
    }

    // Drag
    @State private var dragStartLocation: CGPoint?
    @State private var lastValidDragLocation: CGPoint?
    private let minimumDragDistance: CGFloat = 5.0  // Minimum drag distance to register a change

    
    private func handleDrag(_ value: DragGesture.Value) {
        if dragStartLocation == nil {
            dragStartLocation = value.startLocation
            lastValidDragLocation = value.startLocation
            return
        }
        
        let dragDistance = CGPoint(
            x: value.location.x - dragStartLocation!.x,
            y: value.location.y - dragStartLocation!.y
        )
        
        // Check if the drag distance is significant enough
        if abs(dragDistance.x) < minimumDragDistance && abs(dragDistance.y) < minimumDragDistance {
            return
        }
        
        let dragDelta = CGPoint(
            x: value.location.x - lastValidDragLocation!.x,
            y: value.location.y - lastValidDragLocation!.y
        )
        
        // Horizontal drag for frequency
        let frequencyDelta = Float(dragDelta.x / (width/3)) * 1000 // Using the more gradual scaling
        let newFrequency = max(20, min(20000, audioProcessor.currentFilterSettings!.frequency + frequencyDelta))
        audioProcessor.setFilterFrequency(newFrequency)

        // Vertical drag for gain (if applicable)
        if audioProcessor.availableParameters.contains(.gain) {
            let gainDelta = Float(dragDelta.y / (height * 0.7)) * -2 // Using the more gradual scaling
            let newGain = max(-20, min(20, audioProcessor.currentFilterSettings!.gain + gainDelta))
            audioProcessor.setFilterGain(newGain)
        }

        lastValidDragLocation = value.location
    }

    private func handleZoom(_ scale: CGFloat) {
        guard audioProcessor.availableParameters.contains(.bandwidth) else { return }
        let bandwidthDelta = Float(scale / lastZoomScale - 1) * 0.25 // gradual change with 0.25
        let newBandwidth = max(0.05, min(5.0, audioProcessor.currentFilterSettings!.bandwidth + bandwidthDelta))
        audioProcessor.setFilterBandwidth(newBandwidth)
        lastZoomScale = scale
    }

    var body: some View {
        GeometryReader { geometry in
            HStack (spacing: 20) {
                // Arrows
                VStack(spacing: 20) {
                    // Filter Type Selector
                    VStack {
                        Text("Type")
                            .foregroundColor(.black)
                            .font(.system(size: 10))
                        HStack {
                            Button(action: { audioProcessor.previousFilterType() }) {
                                Image(systemName: "arrow.left")
                            }
                            Text(audioProcessor.currentFilterSettings?.filterType.description ?? "")
                                .frame(width: 90)
                                .foregroundColor(.black)
                            Button(action: { audioProcessor.nextFilterType() }) {
                                Image(systemName: "arrow.right")
                            }
                        }
                    }
                    
                    // Parameter Selector
                    VStack {
                        Text("Parameter")
                            .foregroundColor(.black)
                            .font(.system(size: 10))
                        HStack {
                            // left
                            Button(action: { audioProcessor.previousParameter() }) {
                                Image(systemName: "arrow.left")
                            }
                            .disabled(audioProcessor.currentFilterSettings?.filterType == .highPass || audioProcessor.currentFilterSettings?.filterType == .lowPass)
                            
                            // middle
                            Text(audioProcessor.availableParameters.contains(audioProcessor.currentFilterParameter) ? audioProcessor.currentFilterParameter.rawValue.capitalized : "Frequency")
                                .frame(width: 90)
                                .foregroundColor(.black)
                            
                            //right
                            Button(action: { audioProcessor.nextParameter() }) {
                                Image(systemName: "arrow.right")
                            }
                            .disabled(audioProcessor.currentFilterSettings?.filterType == .highPass || audioProcessor.currentFilterSettings?.filterType == .lowPass)
                        }
                    }
                }
                
                // GUI
                VStack{
                    Text("Filter")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                    BigBox(height: height * 0.85, width: width/3, fillColor: theme.bgColor)
                        .overlay(
                            // Frequency Range Label at the top-right
                            Text(getFrequencyRangeLabel(frequency: audioProcessor.currentFilterSettings?.frequency ?? 0))
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                                .padding(8),
                            alignment: .topTrailing
                        )
                    
                        .overlay(FilterShapeView(audioProcessor: audioProcessor,
                                                 size: CGSize(width: width/6, height: height * 0.55),
                                                 padding: 4))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    handleDrag(value)
                                }
                                .onEnded { _ in
                                    dragStartLocation = nil
                                    lastValidDragLocation = nil
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { scale in
                                    handleZoom(scale)
                                }
                        )
                }
                .padding(30)
                
                // Value knob
                Knob(
                    audioProcessor: audioProcessor,
                    value: Binding(
                        get: { audioProcessor.normalizedParameterValue },
                        set: { audioProcessor.setNormalizedParameterValue($0) }
                    ),
                    size: height * 0.6,
                    title: audioProcessor.currentFilterParameter.rawValue.capitalized,
                    label: currentParameterValueString
                )
            }            
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
