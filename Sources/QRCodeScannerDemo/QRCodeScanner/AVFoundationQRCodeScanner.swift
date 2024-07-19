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

    @Binding var recognizedPayload: String

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let metadataOutput = AVCaptureMetadataOutput()
    private let metadataObjectQueue = DispatchQueue(label: "metadataObjectQueue")

    private let previewLayer: AVCaptureVideoPreviewLayer

    init(recognizedPayload: Binding<String>) {
        self._recognizedPayload = recognizedPayload
        self.previewLayer = Self.makePreviewLayer(session: self.session)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        viewController.view.layer.masksToBounds = true
        viewController.view.layer.addSublayer(previewLayer)

        previewLayer.frame = viewController.view.layer.bounds

        sessionQueue.async {
            self.configureSession(metadataObjectTypes: [.qr], delegate: context.coordinator)
            self.session.startRunning()
        }

        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        previewLayer.frame = uiViewController.view.layer.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {

        private let parent: AVFoundationQRCodeScanner

        init(parent: AVFoundationQRCodeScanner) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first,
                  let machineReadableCode = metadataObject as? AVMetadataMachineReadableCodeObject,
                  machineReadableCode.type == .qr,
                  let stringValue = machineReadableCode.stringValue
            else {
                parent.recognizedPayload = ""
                return
            }

            parent.recognizedPayload = stringValue
        }
    }
}

extension AVFoundationQRCodeScanner {

    private func configureSession(
        metadataObjectTypes: [AVMetadataObject.ObjectType],
        delegate: AVCaptureMetadataOutputObjectsDelegate
    ) {
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

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)

            metadataOutput.metadataObjectTypes = metadataObjectTypes
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: metadataObjectQueue)
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
