//
//  QRCodeScanView.swift
//  
//  
//  Created by penguinsan on 2024/07/17
//  
//

import SwiftUI

struct QRCodeScanView: View {

    enum ScannerType {
        case visionKit
        case avFoundation

        var title: String {
            switch self {
            case .visionKit:
                "VisionKitでスキャン"
            case .avFoundation:
                "AVFoundationでスキャン"
            }
        }
    }

    @State private var recognizedPayload = ""

    let scannerType: ScannerType

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                scanner()
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.7)

                Text("スキャン中のQRコードの値")
                    .font(.headline)

                Text(recognizedPayload)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
            }
        }
        .navigationTitle(scannerType.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func scanner() -> some View {
        switch scannerType {
        case .visionKit:
            VisionKitQRCodeScanner(recognizedPayload: $recognizedPayload)
        case .avFoundation:
            AVFoundationQRCodeScanner(recognizedPayload: $recognizedPayload)
        }
    }
}

#Preview {
    NavigationStack {
        QRCodeScanView(scannerType: .visionKit)
    }
}
