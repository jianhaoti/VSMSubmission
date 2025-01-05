import SwiftUI

struct PadAdjustmentView: View {
    @ObservedObject var audioProcessor: AudioProcessor
    @Binding var currentPage: Int
    
    let theme = Theme()

    var body: some View {
        if audioProcessor.selectedPadID != nil {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    PadStart(audioProcessor: audioProcessor)
                        .tag(0)
                    PadEnd(audioProcessor: audioProcessor)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        else{
            Text("Select a pad to adjust its start time")
                .foregroundColor(.gray)
        }
    }
}
