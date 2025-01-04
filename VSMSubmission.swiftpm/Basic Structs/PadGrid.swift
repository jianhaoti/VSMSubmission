import SwiftUI

@available(iOS 17.0, *)
struct PadGrid: View {
    @ObservedObject var audioProcessor: AudioProcessor
    let numberOfRows: Int = 2
    let numberOfColumns: Int = 4
    let spacing: CGFloat = 50
    let fillColor: Color
    
    func calculatePadSize(for width: CGFloat) -> CGFloat {
        return (width - (spacing * CGFloat(numberOfColumns - 1))) / CGFloat(numberOfColumns)
    }

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height
            
            let padSize = calculatePadSize(for: availableWidth)
            let totalGridHeight = (padSize * CGFloat(numberOfRows)) + (spacing * CGFloat(numberOfRows - 1))
            let verticalOffset = availableHeight - totalGridHeight
            
            VStack(spacing: spacing) {
                ForEach(0..<numberOfRows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<numberOfColumns, id: \.self) { column in
                            let padID = row * numberOfColumns + column + 1
                            Pad(padID: padID,
                                audioProcessor: audioProcessor,
                                startTime: .constant(audioProcessor.getChopTime(for: padID)),
                                height: padSize,
                                width: padSize)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: -verticalOffset / 2)
        }
    }
}
