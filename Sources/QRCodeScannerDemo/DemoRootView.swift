//
//  DemoRootView.swift
//  
//  
//  Created by penguinsan on 2024/07/17
//  
//

import SwiftUI

public struct DemoRootView: View {

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 80) {
                NavigationLink(QRCodeScanView.ScannerType.visionKit.title) {
                    QRCodeScanView(scannerType: .visionKit)
                }

                NavigationLink(QRCodeScanView.ScannerType.avFoundation.title) {
                    QRCodeScanView(scannerType: .avFoundation)
                }
            }
        }
    }
}

#Preview {
    DemoRootView()
}
