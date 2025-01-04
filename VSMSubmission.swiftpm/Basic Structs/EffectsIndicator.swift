import SwiftUI

struct EffectsIndicator: View {
    let theme = Theme()
    let numberOfPages: Int
    let selectedColor: Color
    var onEffects: [Bool]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(onEffects[page] ? Color.gray : selectedColor)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(6)
        .background(.clear)
        .cornerRadius(10)
    }
}
