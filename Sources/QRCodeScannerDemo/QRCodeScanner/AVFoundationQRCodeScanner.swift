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

    private let previewLayer: AVCaptureVideoPreviewLayer

    init() {
        self.previewLayer = Self.makePreviewLayer(session: self.session)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        viewController.view.layer.masksToBounds = true
        viewController.view.layer.addSublayer(previewLayer)

        previewLayer.frame = viewController.view.layer.bounds

        sessionQueue.async {
            self.configureSession()
            self.session.startRunning()
        }

        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        previewLayer.frame = uiViewController.view.layer.bounds
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

extension AVFoundationQRCodeScanner {

    private static func makePreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        return layer
    }
}
