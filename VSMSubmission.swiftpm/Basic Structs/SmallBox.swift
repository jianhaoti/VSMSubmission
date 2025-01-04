//
//  SmallBox.swift
//  VSM800
//
//  Created by Paul Tee on 7/26/24.
//

import Foundation
import SwiftUI

struct SmallBox: View {
    let height: CGFloat
    let width: CGFloat
    let cornerRadius: CGFloat
    let strokeColor: Color
    let strokeWidth: CGFloat
    let fillColor: Color
    
    var body: some View {
            // Base shape with white shadow and bottom dark shadow
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(fillColor)
                .shadow(color: .white.opacity(0.2), radius: 6, x: -6, y: -6)
                .shadow(color: Color.black.opacity(0.25), radius: 1, x: 2, y: 5)
        .frame(width: width, height: height)
    }
}
