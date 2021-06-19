//
//  ViewController.swift
//  HelloCamera
//
//  Created by LuisE on 11/15/19.
//  Copyright © 2019 3zcurdia. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let session = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    @IBOutlet weak var previewView: PreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()
        validateCameraAccess()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !session.isRunning {
          session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        session.stopRunning()
        super.viewWillDisappear(animated)
    }

    func validateCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                // The user has previously granted access to the camera.
                self.setupCaptureSession()
            case .notDetermined:
                // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.setupCaptureSession()
                    }
                }
            case .denied:
                // The user has previously denied access.
                return
            case .restricted:
                // The user can't grant access due to restrictions.
                return
        @unknown default:
            fatalError()
        }
    }

    func setupCaptureSession() {
        session.beginConfiguration()
        let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                             for: .video, position: .back)!
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(videoDeviceInput) else { return }
        session.addInput(videoDeviceInput)

        guard session.canAddOutput(photoOutput) else { return }
        session.sessionPreset = .photo
        session.addOutput(photoOutput)

        session.commitConfiguration()
        previewView.session = session

        session.startRunning()
    }

    @IBAction
    func onTapCapture(_ sender: Any) {
        photoOutput.capturePhoto(with: currentSettings(), delegate: self)
    }

    func currentSettings() -> AVCapturePhotoSettings {
        let settings: AVCapturePhotoSettings
        print(self.photoOutput.availablePhotoCodecTypes)
        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format:
                [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            settings = AVCapturePhotoSettings()
        }
        settings.flashMode = .auto
        return settings
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        debugPrint(photo.metadata)
        debugPrint(photo.isRawPhoto)

        guard let data = photo.fileDataRepresentation() else { return }
        print(data)
        print(UIImage(data: data)?.jpegData(compressionQuality: 0.9))
    }
}
