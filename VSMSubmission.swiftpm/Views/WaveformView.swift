import SwiftUI

struct WaveformView: View {
    @ObservedObject var audioProcessor: AudioProcessor
    var data: [Float]
    
    @State private var initialDragOffset: CGFloat?
    @State private var updateTime: TimeInterval = 0
    
    let recColor: Color = Color(hex:"FFB2B2")

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                
                // Waveform
                if !data.isEmpty {
                    waveformPath(in: geometry)
                        .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                        .frame(width: waveformWidth(for: geometry))
                        .offset(x: calculatedOffset(for: geometry))
                }
                
                // Chop markers
                ForEach(Array(audioProcessor.chopTimes), id: \.key) { padID, chopTime in
                    Rectangle()
                        .fill(recColor)
                        .frame(width: 2)
                        .offset(x: chopPosition(for: chopTime, in: geometry) + calculatedOffset(for: geometry))
                }
                
                // End marker for selected pad if present
                if let padID = audioProcessor.selectedPadID {
                    if let endTime = audioProcessor.endTimes[padID]{
                        Rectangle()
                            .fill(.blue.opacity(0.5))
                            .frame(width:2)
                            .offset(x: chopPosition(for: endTime, in: geometry) + calculatedOffset(for: geometry))
                    }
                }
                
                // Time tracking bar
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            .contentShape(Rectangle())
            .clipShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 1, coordinateSpace: .local)
                    .onChanged { value in
                        if !audioProcessor.isDragging {
                            audioProcessor.isDragging = true
                            audioProcessor.pausePlaybackIfNeeded()
                            initialDragOffset = calculatedOffset(for: geometry)
                        }
                        if let initialOffset = initialDragOffset {
                            let dragDelta = value.translation.width
                            let newOffset = limitOffset(initialOffset + dragDelta, for: geometry)
                            updateTime = max(0, min(timeFromOffset(newOffset, in: geometry), audioProcessor.totalDuration))
                            audioProcessor.setCurrentTime(updateTime)
                        }
                    }
                    .onEnded { _ in
                        audioProcessor.isDragging = false
                        audioProcessor.seekTo(time: updateTime)
                        audioProcessor.resumePlaybackIfNeeded()
                        initialDragOffset = nil
                    }
            )
            .animation(.linear(duration: 0.1), value: audioProcessor.currentTime)
        }
    }
    
    private func waveformWidth(for geometry: GeometryProxy) -> CGFloat {
        return max(geometry.size.width, CGFloat(data.count / 2))
    }

    private func waveformPath(in geometry: GeometryProxy) -> Path {
        let width = waveformWidth(for: geometry)
        return Path { path in
            let stepX = width / CGFloat(data.count / 2)
            let midY = geometry.size.height / 2
            let scale = geometry.size.height / 2
            
            for i in stride(from: 0, to: data.count, by: 2) {
                let x = CGFloat(i / 2) * stepX
                let highY = midY - CGFloat(data[i]) * scale
                let lowY = midY - CGFloat(data[i + 1]) * scale
                
                path.move(to: CGPoint(x: x, y: highY))
                path.addLine(to: CGPoint(x: x, y: lowY))
            }
        }
    }
    
    // bounds amount user can scroll
    private func limitOffset(_ proposedOffset: CGFloat, for geometry: GeometryProxy) -> CGFloat {
        let maxRightOffset = min(0, geometry.size.width - waveformWidth(for: geometry))
        let maxLeftOffset = geometry.size.width / 2  // This allows dragging back to the start
        return max(maxRightOffset, min(maxLeftOffset, proposedOffset))
    }
    
    // inverse of timeFromOffset
    private func calculatedOffset(for geometry: GeometryProxy) -> CGFloat {
        let proportion = CGFloat(audioProcessor.currentTime / audioProcessor.totalDuration)
        
        let totalOffset = waveformWidth(for: geometry) * proportion // calculates position @ current time
        
        let initialShift = geometry.size.width / 2 // to align with half the screen
        
        return CGFloat(-totalOffset + initialShift)
    }

    //inverse of calculatedOffset
    private func timeFromOffset(_ offset: CGFloat, in geometry: GeometryProxy) -> TimeInterval {
        let waveformWidth = waveformWidth(for: geometry)
        let initialShift = geometry.size.width/2
        return TimeInterval((-offset + CGFloat(initialShift)) * (audioProcessor.totalDuration / waveformWidth))
    }
    
    private func chopPosition(for chopTime: Double, in geometry: GeometryProxy) -> CGFloat {
        let proportion = CGFloat(chopTime / audioProcessor.totalDuration)
        return waveformWidth(for: geometry) * proportion
    }
}
