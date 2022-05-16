//
//  ViewController.swift
//  CameraFilter
//
//  Created by Gustavo Kumasawa on 16/05/22.
//

import UIKit
import AVFoundation

class CameraFilterVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private lazy var imageView: UIImageView = {
        let iv = UIImageView(frame: self.view.frame)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(
            session: captureSession
        )
        
        preview.videoGravity = .resizeAspectFill
        preview.frame = self.view.frame
        
        return preview
    }()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let captureSession = AVCaptureSession()
    
    private lazy var filterHandler = CameraFilterHandler()
    
    private lazy var sepiaToneFilterButton = ApplyFilterButton(
        cameraFilterHandler: filterHandler,
        filter: .sepiaTone
    )
    private lazy var darkScratchesFilterButton = ApplyFilterButton(
        cameraFilterHandler: filterHandler,
        filter: .darkScratches
    )
    private lazy var whiteSpecksFilterButton = ApplyFilterButton(
        cameraFilterHandler: filterHandler,
        filter: .whiteSpecks
    )
    private lazy var colorInvertFilterButton = ApplyFilterButton(
        cameraFilterHandler: filterHandler,
        filter: .colorInvert
    )
    private lazy var redIncreaseFilterButton = ApplyFilterButton(
        cameraFilterHandler: filterHandler,
        filter: .redIncrease
    )
    private lazy var bloomFilterButton = ApplyFilterButton(
        cameraFilterHandler: filterHandler,
        filter: .bloom
    )
    private lazy var noirFilterButton = ApplyFilterButton(
        cameraFilterHandler: filterHandler,
        filter: .noir
    )
    private lazy var blinkFilterButton = ApplyFilterButton(
        cameraFilterHandler: filterHandler,
        filter: .blink
    )
    private lazy var colorGlitchFilterButton = ApplyFilterButton(
        cameraFilterHandler: filterHandler,
        filter: .colorGlitch
    )
    private lazy var filterButtons: [ApplyFilterButton] = [
        sepiaToneFilterButton,
        darkScratchesFilterButton,
        whiteSpecksFilterButton,
        colorInvertFilterButton,
        redIncreaseFilterButton,
        bloomFilterButton,
        noirFilterButton,
        blinkFilterButton,
        colorGlitchFilterButton
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSubViews()
        self.setCameraInput()
        self.setCameraOutput()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = self.view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        stopCamera()
    }
    
    private func setupSubViews() {
        self.view.addSubview(imageView)
        filterButtons.forEach({ self.view.addSubview($0) })
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let firstButtonConstraints: [NSLayoutConstraint] = [
            filterButtons[0].topAnchor.constraint(
                equalTo: self.view.topAnchor,
                constant: 50
            ),
            filterButtons[0].leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 20
            )
        ]
        NSLayoutConstraint.activate(firstButtonConstraints)
        
        for (i, filterButton) in filterButtons.enumerated() {
            filterButton.translatesAutoresizingMaskIntoConstraints = false
            
            if i == 0 {
                continue
            }
            
            let buttonConstraints: [NSLayoutConstraint] = [
                filterButton.topAnchor.constraint(
                    equalTo: filterButtons[i-1].bottomAnchor,
                    constant: 20
                ),
                filterButton.leadingAnchor.constraint(
                    equalTo: self.view.leadingAnchor,
                    constant: 20
                )
            ]
            NSLayoutConstraint.activate(buttonConstraints)
        }
    }
    
    private func startCamera() {
        videoDataOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue(label: "camera_frame_processing_queue")
        )
        captureSession.startRunning()
    }
    
    private func stopCamera() {
        videoDataOutput.setSampleBufferDelegate(nil, queue: nil)
        captureSession.stopRunning()
    }
    
    private func setCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        ).devices.first else {
            fatalError("No back camera device found.")
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: device)
        } catch {
            print("Failed to load video input")
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add videoInput to captureSession")
        }
    }
    
    func setCameraOutput() {
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        videoDataOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue(label: "camera_frame_processing_queue")
        )

        captureSession.addOutput(videoDataOutput)

        guard let connection = videoDataOutput.connection(
            with: AVMediaType.video
        ), connection.isVideoOrientationSupported else {
            return
        }
        connection.videoOrientation = .portrait
    }
    
    // MARK: AVCaptureVideo Delegate
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        guard let pixelBuffer = pixelBuffer else {
            return
        }
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let filteredImage = filterHandler.applyFilter(image: cameraImage)
        
        DispatchQueue.main.async {
            self.imageView.image = UIImage(ciImage: filteredImage)
        }
        
    }
}
