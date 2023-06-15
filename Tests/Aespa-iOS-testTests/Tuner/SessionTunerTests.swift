//
//  SessionTunerTests.swift
//  Aespa-iOS-testTests
//
//  Created by Young Bin on 2023/06/10.
//

import XCTest
import AVFoundation

import Cuckoo

@testable import Aespa

final class SessionTunerTests: XCTestCase {
    var mockSession: MockAespaCoreSession!
    var mockSessionProtocol: MockAespaCoreSessionRepresentable!

    
    override func setUpWithError() throws {
        let option = AespaOption(albumName: "test")
        mockSession = MockAespaCoreSession(option: option)
        mockSessionProtocol = MockAespaCoreSessionRepresentable()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testQualityTuner() throws {
        let preset: AVCaptureSession.Preset = .cif352x288
        let tuner = QualityTuner(videoQuality: preset)
        
        stub(mockSessionProtocol) { proxy in
            when(proxy.setVideoQuality(to: any())).thenDoNothing()
        }
        
        try tuner.tune(mockSessionProtocol)
        verify(mockSessionProtocol)
            .setVideoQuality(to: equal(to: AVCaptureSession.Preset.cif352x288))
            .with(returnType: Void.self)
    }
    
    func testCameraPositionTuner() throws {
        let position: AVCaptureDevice.Position = .front
        let tuner = CameraPositionTuner(position: position)
        
        stub(mockSessionProtocol) { proxy in
            when(proxy.setCameraPosition(to: any(), device: any())).thenDoNothing()
        }
        
        try tuner.tune(mockSessionProtocol)
        verify(mockSessionProtocol)
            .setCameraPosition(to: equal(to: AVCaptureDevice.Position.front), device: any())
            .with(returnType: Void.self)
    }
    
    func testAudioTuner() throws {
        stub(mockSessionProtocol) { proxy in
            when(proxy.addAudioInput()).thenDoNothing()
            when(proxy.removeAudioInput()).thenDoNothing()
        }

        var tuner = AudioTuner(isMuted: false)
        try tuner.tune(mockSessionProtocol)
        verify(mockSessionProtocol).addAudioInput()
        
        
        tuner = AudioTuner(isMuted: true)
        try tuner.tune(mockSessionProtocol)
        verify(mockSessionProtocol).removeAudioInput()
    }
    
    func testSessionLaunchTuner_whenNotRunning() throws {
        stub(mockSessionProtocol) { proxy in
            when(proxy.isRunning.get).thenReturn(false)
            when(proxy.addMovieInput()).thenDoNothing()
            when(proxy.addMovieFileOutput()).thenDoNothing()
            when(proxy.startRunning()).thenDoNothing()
        }

        let tuner = SessionLaunchTuner()
        try tuner.tune(mockSessionProtocol)
        
        verify(mockSessionProtocol)
            .addMovieInput()
            .with(returnType: Void.self)
        
        verify(mockSessionProtocol)
            .addMovieFileOutput()
            .with(returnType: Void.self)
        
        verify(mockSessionProtocol)
            .startRunning()
            .with(returnType: Void.self)
    }
    
    func testSessionLaunchTuner_whenRunning() throws {
        stub(mockSessionProtocol) { proxy in
            when(proxy.isRunning.get).thenReturn(true)
        }
        
        let tuner = SessionLaunchTuner()
        try tuner.tune(mockSessionProtocol)
        
        verify(mockSessionProtocol, never())
            .addMovieInput()
            .with(returnType: Void.self)
        
        verify(mockSessionProtocol, never())
            .addMovieFileOutput()
            .with(returnType: Void.self)
        
        verify(mockSessionProtocol, never())
            .startRunning()
            .with(returnType: Void.self)
    }
    
    func testSessionTerminationTuner_whenRunning() throws {
        stub(mockSessionProtocol) { proxy in
            when(proxy.isRunning.get).thenReturn(true)
            when(proxy.removeMovieInput()).thenDoNothing()
            when(proxy.removeAudioInput()).thenDoNothing()
            when(proxy.stopRunning()).thenDoNothing()
        }

        let tuner = SessionTerminationTuner()
        tuner.tune(mockSessionProtocol)
        
        verify(mockSessionProtocol)
            .removeMovieInput()
            .with(returnType: Void.self)
        
        verify(mockSessionProtocol)
            .removeAudioInput()
            .with(returnType: Void.self)
        
        verify(mockSessionProtocol)
            .stopRunning()
            .with(returnType: Void.self)
    }
    
    func testSessionTerminationTuner_whenNotRunning() throws {
        stub(mockSessionProtocol) { proxy in
            when(proxy.isRunning.get).thenReturn(false)
        }

        let tuner = SessionTerminationTuner()
        tuner.tune(mockSessionProtocol)
        
        verify(mockSessionProtocol, never())
            .removeMovieInput()
            .with(returnType: Void.self)
        
        verify(mockSessionProtocol, never())
            .stopRunning()
            .with(returnType: Void.self)
    }
}