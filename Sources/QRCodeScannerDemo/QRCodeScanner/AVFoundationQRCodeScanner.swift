//
//  AVFoundationQRCodeScanner.swift
//
//  
//  Created by penguinsan on 2024/07/17
//  
//

import AVFoundation
import SwiftUI
import UIKit

struct AVFoundationQRCodeScanner: UIViewControllerRepresentable {

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        sessionQueue.async {
            self.configureSession()
        }

        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

extension AVFoundationQRCodeScanner {

    private func configureSession() {
        defer {
            session.commitConfiguration()
        }

        session.beginConfiguration()

        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let videoDevice else {
            return
        }

        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
            }
        } catch {
            return
        }
    }
}
