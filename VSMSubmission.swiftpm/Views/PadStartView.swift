import SwiftUI

struct PadStart: View {
    @ObservedObject var audioProcessor: AudioProcessor

    let theme = Theme()

    private func adjustStartTime(to newTime: Double) {        
        guard let padID = audioProcessor.selectedPadID else { return }
        let clampedTime = max(0, min(audioProcessor.totalDuration, newTime))
        audioProcessor.setChopTime(clampedTime, for: padID)
        
        // update end time if start time surpasses previous end time
        if let endTime = audioProcessor.getEndTime(for: padID){
            if clampedTime > endTime{
                audioProcessor.endTimes[padID] = clampedTime
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Pad \(audioProcessor.selectedPadID!)")
                    .font(.headline)
                    .padding(.top, 10)
                    .foregroundColor(.black)

                Text("Start Time: ")
                    .font(.subheadline)
                    .foregroundColor(.black)
                     +
                
                // when deleting, there's a moment where getChopTime fails to return a value, so default to -1
                Text("\(audioProcessor.getChopTime(for: audioProcessor.selectedPadID!) ?? -1 , specifier: "%.2f")s")
                    .font(.subheadline)
                    .foregroundColor(.red.opacity(0.8))

                Knob(
                    audioProcessor: audioProcessor,
                    value: Binding(
                            get: {
                                return audioProcessor.getChopTime(for: audioProcessor.selectedPadID!) ?? 0
                            },
                            set: { newTime in
                                adjustStartTime(to: newTime)
                            }
                        ),
                    isConstrained: false,
                    arcColor: Color.red.opacity(0.8),
                    size: 150,
                    title: "",
                    label: "",
                    showArc: false,
                    showLine: true
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center) // center
        }
    }
}
