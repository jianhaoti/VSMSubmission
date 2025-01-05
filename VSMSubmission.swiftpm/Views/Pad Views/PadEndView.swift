import SwiftUI

struct PadEnd: View {
    @ObservedObject var audioProcessor: AudioProcessor

    let theme = Theme()

    private func adjustEndTime(to newTime: Double) {
        guard let padID = audioProcessor.selectedPadID else { return }
        let clampedTime = max(audioProcessor.getChopTime(for: padID)!,
                              min(audioProcessor.totalDuration, newTime)) // startTime ≤ endTime ≤ totalDuration
        audioProcessor.setEndTime(clampedTime, for: padID)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Pad \(audioProcessor.selectedPadID ?? 0)")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.top, 10)

                Text("End Time: ")
                    .font(.subheadline)
                    .foregroundColor(.black)
                     +
                Text(audioProcessor.getEndTime(for: audioProcessor.selectedPadID!) != nil
                    ?"\(audioProcessor.getEndTime(for: audioProcessor.selectedPadID!)!, specifier: "%.2f")s"
                    : "Tap knob"
                )
                    .font(.subheadline)
                    .foregroundColor(.blue.opacity(0.8))

            Knob(
                audioProcessor: audioProcessor,
                 value: Binding(
                        get: {
                            return audioProcessor.getEndTime(for: audioProcessor.selectedPadID!) ?? 0
                        },
                        set: { newTime in
                            adjustEndTime(to: newTime)
                        }
                    ),
                 isConstrained: false,
                 size: 150,
                 title: "",
                 label: "",
                 showArc: false,
                 isTappable: true,
                 handleTap: {
                   if let padID = audioProcessor.selectedPadID {
                       audioProcessor.setEndTime(max(audioProcessor.currentTime, audioProcessor.getChopTime(for: padID)!), for: padID)
                   }
                 },
                showLine: audioProcessor.endTimes[audioProcessor.selectedPadID!] != nil
            )
        }
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center) // center
        }
    }
}
