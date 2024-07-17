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

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let dataScannerViewController = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])]
        )
        try? dataScannerViewController.startScanning()
        return dataScannerViewController
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
    }
}
