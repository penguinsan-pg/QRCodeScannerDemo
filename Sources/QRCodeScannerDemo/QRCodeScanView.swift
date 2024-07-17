//
//  QRCodeScanView.swift
//  
//  
//  Created by penguinsan on 2024/07/17
//  
//

import SwiftUI

struct QRCodeScanView: View {

    @State private var recognizedPayload = ""

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                // TODO: QRコードスキャナの View を配置する
                Color.orange
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.7)

                Text("スキャン中のQRコードの値")
                    .font(.headline)

                Text(recognizedPayload)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

#Preview {
    QRCodeScanView()
}
