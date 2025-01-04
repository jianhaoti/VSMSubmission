import SwiftUI
import AVFoundation

struct FilterShapeView: View {
    @ObservedObject var audioProcessor: AudioProcessor
    let size: CGSize
    let padding: CGFloat
    let theme = Theme()
        
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    if let settings = audioProcessor.currentFilterSettings {
                        switch settings.filterType {
                            case .lowPass:
                                drawLowPassFilter(in: &path, size: geometry.size, padding: padding, frequency: settings.frequency)
                            case .highPass:
                                drawHighPassFilter(in: &path, size: geometry.size, padding: padding, frequency: settings.frequency)
                            case .bandPass:
                                drawBandPassFilter(in: &path, size: geometry.size, padding: padding + 4, frequency: settings.frequency, bandwidth: settings.bandwidth)
                            case .lowShelf:
                                drawLowShelfFilter(in: &path, size: geometry.size, padding: padding, frequency: settings.frequency, gain: settings.gain)
                            case .highShelf:
                                drawHighShelfFilter(in: &path, size: geometry.size, padding: padding, frequency: settings.frequency, gain: settings.gain)
                            case .parametric:
                                drawParametricFilter(in: &path, size: geometry.size, padding: padding, frequency: settings.frequency, bandwidth: settings.bandwidth, gain: settings.gain)
                            case .resonantLowPass:
                                break
                            case .resonantHighPass:
                                break
                            case .bandStop:
                                break
                            case .resonantLowShelf:
                                break
                            case .resonantHighShelf:
                                break
                            @unknown default:
                                    break
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
                .clipShape(
                    Rectangle()
                        .size(CGSize(
                            width: geometry.size.width * 0.98,
                            height: geometry.size.height * 0.98
                        ))
                        .offset(
                            x: geometry.size.width * 0.01,
                            y: geometry.size.height * 0.01
                        )
                )

            }
        }
    }



    private func drawHighPassFilter(in path: inout Path, size: CGSize, padding: CGFloat, frequency: Float) {
        let normalizedFreq = CGFloat(logNormalize(frequency, min: 20, max: 20000))
        let cutoffX = size.width * normalizedFreq
        
        // Start at bottom left
        path.move(to: CGPoint(x: 1.5, y: size.height - padding))
        
        // Draw curve to the cutoff frequency and half the height
        path.addCurve(
            to: CGPoint(x: cutoffX, y: size.height / 2),
            control1: CGPoint(x: cutoffX * 0.3, y: size.height - padding),
            control2: CGPoint(x: cutoffX * 0.7, y: size.height / 2)
        )
        
        // Draw line to the top right but capped at half the height
        path.addLine(to: CGPoint(x: size.width - padding/2, y: size.height / 2))
    }

    private func drawLowPassFilter(in path: inout Path, size: CGSize, padding: CGFloat, frequency: Float) {
        let normalizedFreq = CGFloat(logNormalize(frequency, min: 20, max: 20000))
        let cutoffX = size.width * normalizedFreq
        
        // Start at top left but cap at half the height
        path.move(to: CGPoint(x: padding/2 , y: size.height / 2))
        
        // Draw line to the cutoff frequency and half the height
        path.addLine(to: CGPoint(x: cutoffX, y: size.height / 2))
        
        // Draw curve down to bottom right
        path.addCurve(
            to: CGPoint(x: size.width - 1.5, y: size.height - padding),
            control1: CGPoint(x: cutoffX + (size.width - cutoffX) * 0.3, y: size.height / 2),
            control2: CGPoint(x: cutoffX + (size.width - cutoffX) * 0.7, y: size.height - padding)
        )
    }
    
    private func drawBandPassFilter(in path: inout Path, size: CGSize, padding: CGFloat, frequency: Float, bandwidth: Float) {
        let normalizedFreq = CGFloat(logNormalize(frequency, min: 20, max: 20000))
        let normalizedBandwidth = CGFloat(normalize(bandwidth, min: 0.05, max: 5.0))
        let centerX = size.width * normalizedFreq
        let bandwidthX = size.width * normalizedBandwidth
        
        let peakY = size.height / 2  // Peak at the middle (0dB line)
        let bottomY = size.height - padding
        
        path.move(to: CGPoint(x: 1, y: bottomY))
        path.addCurve(
            to: CGPoint(x: centerX, y: peakY),
            control1: CGPoint(x: centerX - bandwidthX/2, y: bottomY),
            control2: CGPoint(x: centerX - bandwidthX/4, y: peakY)
        )
        path.addCurve(
            to: CGPoint(x: size.width - 1, y: bottomY),
            control1: CGPoint(x: centerX + bandwidthX/4, y: peakY),
            control2: CGPoint(x: centerX + bandwidthX/2, y: bottomY)
        )
    }
    private func drawLowShelfFilter(in path: inout Path, size: CGSize, padding: CGFloat, frequency: Float, gain: Float) {
        let normalizedFreq = CGFloat(logNormalize(frequency, min: 20, max: 20000))
        let normalizedGain = CGFloat(normalize(gain, min: -20, max: 20))
        let cutoffX = size.width * normalizedFreq
        let gainY = size.height * (1 - normalizedGain)  // Invert the Y-axis
        
        path.move(to: CGPoint(x: padding, y: gainY))
        path.addLine(to: CGPoint(x: cutoffX * 0.7, y: gainY))
        path.addCurve(
            to: CGPoint(x: cutoffX, y: size.height / 2),
            control1: CGPoint(x: cutoffX * 0.85, y: gainY),
            control2: CGPoint(x: cutoffX * 0.95, y: size.height / 2)
        )
        path.addLine(to: CGPoint(x: size.width - padding, y: size.height / 2))
    }
    
    private func drawHighShelfFilter(in path: inout Path, size: CGSize, padding: CGFloat, frequency: Float, gain: Float) {
        let normalizedFreq = CGFloat(logNormalize(frequency, min: 20, max: 20000))
        let normalizedGain = CGFloat(normalize(gain, min: -20, max: 20))
        let cutoffX = size.width * normalizedFreq
        let gainY = size.height * (1 - normalizedGain)
        
        path.move(to: CGPoint(x: padding/2, y: size.height/2))
        path.addLine(to: CGPoint(x: cutoffX * 0.7, y: size.height/2))
        path.addCurve(
            to: CGPoint(x: cutoffX, y: gainY),
            control1: CGPoint(x: cutoffX * 0.85, y: size.height/2),
            control2: CGPoint(x: cutoffX * 0.95, y: gainY)
        )
        path.addLine(to: CGPoint(x: size.width - padding/2, y: gainY))
    }
    private func drawParametricFilter(in path: inout Path, size: CGSize, padding: CGFloat, frequency: Float, bandwidth: Float, gain: Float) {
        let normalizedFreq = CGFloat(logNormalize(frequency, min: 20, max: 20000))
        let normalizedBandwidth = CGFloat(normalize(bandwidth, min: 0.05, max: 5.0))
        let normalizedGain = CGFloat(normalize(gain, min: -20, max: 20))
        let centerX = size.width * normalizedFreq
        let bandwidthX = size.width * normalizedBandwidth
        let gainY = size.height * (1 - normalizedGain)
        
        path.move(to: CGPoint(x: 0, y: size.height/2))
        path.addLine(to: CGPoint(x: centerX - bandwidthX/2, y: size.height/2))
        path.addCurve(
            to: CGPoint(x: centerX, y: gainY),
            control1: CGPoint(x: centerX - bandwidthX/4, y: size.height/2),
            control2: CGPoint(x: centerX - bandwidthX/8, y: gainY)
        )
        path.addCurve(
            to: CGPoint(x: centerX + bandwidthX/2, y: size.height/2),
            control1: CGPoint(x: centerX + bandwidthX/8, y: gainY),
            control2: CGPoint(x: centerX + bandwidthX/4, y: size.height/2)
        )
        path.addLine(to: CGPoint(x: size.width, y: size.height/2))
    }

    private func normalize(_ value: Float, min: Float, max: Float) -> Float {
        return (value - min) / (max - min)
    }
    
    private func logNormalize(_ value: Float, min: Float, max: Float) -> Float {
        let logMin = log(min)
        let logMax = log(max)
        let logValue = log(value)
        return (logValue - logMin) / (logMax - logMin)
    }

}
