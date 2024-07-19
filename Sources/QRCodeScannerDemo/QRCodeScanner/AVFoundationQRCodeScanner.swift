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
    private let boundingBox: CAShapeLayer

    init(recognizedPayload: Binding<String>) {
        self._recognizedPayload = recognizedPayload
        self.previewLayer = Self.makePreviewLayer(session: self.session)
        self.boundingBox = Self.makeBoundingBox()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        viewController.view.layer.masksToBounds = true
        viewController.view.layer.addSublayer(previewLayer)
        viewController.view.layer.addSublayer(boundingBox)

        previewLayer.frame = viewController.view.layer.bounds
        boundingBox.frame = viewController.view.layer.bounds

        sessionQueue.async {
            self.configureSession(metadataObjectTypes: [.qr], delegate: context.coordinator)
            self.session.startRunning()
        }

        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        previewLayer.frame = uiViewController.view.layer.bounds
        boundingBox.frame = uiViewController.view.layer.bounds
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
                DispatchQueue.main.async {
                    self.parent.updateBoundingBox(nil)
                }
                return
            }

            parent.recognizedPayload = stringValue
            DispatchQueue.main.async {
                self.parent.updateBoundingBox(machineReadableCode)
            }
        }
    }
}

private extension AVFoundationQRCodeScanner {

    func configureSession(
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

    func updateBoundingBox(_ metadataObject: AVMetadataObject?) {
        guard let metadataObject,
              let transformedObject = previewLayer.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject 
        else {
            boundingBox.isHidden = true
            return
        }

        let corners = transformedObject.corners
        guard let lastPoint = corners.last else {
            boundingBox.isHidden = true
            return
        }

        let path = UIBezierPath()
        path.move(to: lastPoint)

        corners.forEach { point in
            path.addLine(to: point)
        }

        boundingBox.path = path.cgPath
        boundingBox.isHidden = false
    }
}

private extension AVFoundationQRCodeScanner {

    static func makePreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        return layer
    }

    static func makeBoundingBox() -> CAShapeLayer {
        let boundingBox = CAShapeLayer()
        boundingBox.strokeColor = UIColor.green.cgColor
        boundingBox.lineWidth = 4.0
        boundingBox.fillColor = UIColor.clear.cgColor
        return boundingBox
    }
}
