import SwiftUI

struct BigBox: View {
    let height: CGFloat
    let width: CGFloat
    let cornerRadius: CGFloat = 10
    let strokeColor: Color = Color(hex: "757575").opacity(0.05)
    var strokeWidth: CGFloat = 1.5
    var fillColor: Color = Color(hex: "F8FCFF")
    
    let theme = Theme()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(fillColor)
            
            // Top shadow (conditionally applied based on strokeWidth)
            if strokeWidth > 0 {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.black.opacity(0.3), lineWidth: strokeWidth)
                    .offset(CGSize(width: width * 0.001, height: height * 0.01))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                
                // Bottom shadow
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.gray.opacity(0.2), lineWidth: strokeWidth)
                    .offset(CGSize(width: -width * 0.001, height: -height * 0.01))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
        }
        .frame(width: width, height: height)
    }
}
