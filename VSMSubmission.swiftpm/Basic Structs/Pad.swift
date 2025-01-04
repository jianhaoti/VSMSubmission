import SwiftUI

@available(iOS 17.0, *)
struct Pad: View {
    let padID: Int
    @ObservedObject var audioProcessor: AudioProcessor
    @Binding var startTime: Double?
    var height: CGFloat
    var width: CGFloat
    
    let nonemptyColor: Color = Color(hex: "F8FCFF")
    let darkShadow = Color(hex: "BDCAD7")
    let emptyColor = Color(hex: "F7F7F7")

    @State private var isPressed: Bool = false
        
    var body: some View {
        let state = audioProcessor.getPadState(for: padID)

        baseShape(for: state)
            .overlay(stateOverlay(for: state))
            .scaleEffect(isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                        if audioProcessor.isSampleLoaded {
                            handleTap(state: state)
                            audioProcessor.selectPad(padID)
                        }
                    }
            )
    }
    
    private func baseShape(for state: PadState) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color(hex: "757575").opacity(0.05), lineWidth: 0.5)
            .fill(fillColor(for: state))
            .frame(width: width, height: height)
            .shadow(color: Color.black.opacity(isPressed ? 0.1 : 0.2), radius: isPressed ? 2 : 1, x: 0, y: isPressed ? 2 : 5)
            .shadow(color: darkShadow.opacity(isPressed ? 0.3 : 1), radius: 6, x: isPressed ? -3 : 6, y: isPressed ? -3 : 6)
            .shadow(color: .white.opacity(isPressed ? 1 : 0.2), radius: 6, x: isPressed ? 3 : -6, y: isPressed ? 3 : -6)
    }

    private func stateOverlay(for state: PadState) -> some View {
        ZStack {
            if state == .favorite {
                VStack {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.black)
                            .font(.system(size: min(width, height) * 0.075))
                        Spacer()
                    }
                    Spacer()
                }
                .padding([.top, .leading], 8)
            }
        }
    }

    private func fillColor(for state: PadState) -> Color {
        switch state {
        case .empty:
            return emptyColor
        case .loaded, .favorite:
            return nonemptyColor
        }
    }
    
    private func handleTap(state: PadState) {
        if audioProcessor.getChopTime(for: padID) == nil {
            audioProcessor.setPadState(.loaded, for: padID)
            audioProcessor.setChopTime(audioProcessor.currentTime, for: padID)
        } else {
            if let startTime = audioProcessor.getChopTime(for: padID) {
                audioProcessor.seekTo(time: startTime)
                audioProcessor.play()
            }
        }
    }
}
