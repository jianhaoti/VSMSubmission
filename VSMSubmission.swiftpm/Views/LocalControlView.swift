import SwiftUI

struct LocalControlView: View {
    @ObservedObject var audioProcessor: AudioProcessor
    @Binding var currentPage: Int

    let width: CGFloat
    let height: CGFloat
    let centerX: CGFloat
    let numberOfPages = 4

    let theme = Theme()
    
    var body: some View {
        TabView(selection: $currentPage) {
            // TimePitchDistortion
            TimePitchDistortionView(audioProcessor: audioProcessor,
                                    width: width,
                                    height: height
            ).tag(0)
            
            // Filters
            FilterView(
                audioProcessor: audioProcessor,
                width: width,
                height: height,
                centerX: centerX
            ).tag(1)
            
            // Dynamics
            DynamicsView(audioProcessor: audioProcessor,
                         width: width,
                         height: height
            ).tag(2)
            
            // DelayReverb
            DelayReverbView(audioProcessor: audioProcessor,
                            width: width,
                            height: height
            ).tag(3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(
            PageIndicator(numberOfPages: numberOfPages,
                          selectedColor: Color.blue.opacity(0.8),
                          currentPage: $currentPage)
            .padding(10)
            , alignment: .bottomTrailing
        )
    }
}
