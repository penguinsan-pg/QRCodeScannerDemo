//
//  VisionKitQRCodeScanner.swift
//
//  
//  Created by penguinsan on 2024/07/17
//  
//

import SwiftUI
import VisionKit

struct VisionKitQRCodeScanner: UIViewControllerRepresentable {

    @Binding var recognizedPayload: String

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let dataScannerViewController = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])]
        )
        dataScannerViewController.delegate = context.coordinator
        try? dataScannerViewController.startScanning()
        return dataScannerViewController
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {

        private let parent: VisionKitQRCodeScanner

        init(parent: VisionKitQRCodeScanner) {
            self.parent = parent
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard case .barcode(let barcode) = addedItems.first else {
                return
            }

            if let payloadStringValue = barcode.payloadStringValue {
                parent.recognizedPayload = payloadStringValue
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            parent.recognizedPayload = ""
        }
    }
}
