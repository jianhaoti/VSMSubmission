import SwiftUI

struct PageIndicator: View {
    let theme = Theme()
    let numberOfPages: Int
    let selectedColor: Color
    @Binding var currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? selectedColor : Color.gray)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(6)
        .background(.clear)
        .cornerRadius(10)
    }
}
