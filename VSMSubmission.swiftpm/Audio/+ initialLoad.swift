import AVFoundation
import MediaPlayer

extension AudioProcessor{
    @MainActor
    func loadSample() {
        // Fallback to Bundle.module
        if let url = Bundle.main.url(forResource: "drumLoop", withExtension: "wav") {
            print("Found file in bundle: \(url)")
            loadAudio(url: url)
        }
        
//        else {
//            // Debugging the resource path
//            print("Bundle.module resource path: \(Bundle.main.resourcePath ?? "Not found")")
//            
//            // Try to list all files in the resource path
//            if let resourcePath = Bundle.main.resourcePath {
//                do {
//                    let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
//                    print("Files in Resources folder: \(files)")
//                } catch {
//                    print("Error listing files in Resources folder: \(error)")
//                }
//            }
//        }
    }

    @MainActor
    func loadAudio(url: URL) {
        self.isSampleLoaded = true
        
        // Stop playback and clear current audio
        playerNode.stop()
        playerNode.reset()
        
        // Clear current audio file
        audioFile = nil
        
        // Reset properties
        currentTime = 0
        totalDuration = 0
        savedTime = 0
        isPlaying = false
        waveformData = []
        
        // Stop any ongoing timers
        stopTimer()
        
        do {
            audioFile = try AVAudioFile(forReading: url)
            totalDuration = Double(audioFile!.length) / audioFile!.processingFormat.sampleRate
            currentTime = 0
            generateWaveformData()
        } catch {
            print("Error loading audio file: \(error)")
        }
    }
    
    @MainActor
    private func generateWaveformData() {
        guard let file = audioFile else { return }
        
        let audioFormat = file.processingFormat
        let audioFrameCount = UInt32(file.length)
        guard let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: audioFrameCount) else { return }
        
        do {
            try file.read(into: audioBuffer)
            
            guard let floatChannelData = audioBuffer.floatChannelData else { return }
            let channelData = Array(UnsafeBufferPointer(start: floatChannelData[0], count: Int(audioFrameCount)))
            
            // Downsample the audio data
            let downsampledLength = Int(audioFrameCount) / samplesPerPixel
            var downsampled = [Float]()
            
            for i in 0..<downsampledLength {
                let start = i * samplesPerPixel
                let end = min(start + samplesPerPixel, Int(audioFrameCount))
                let chunk = channelData[start..<end]
                let maxAmplitude = chunk.max() ?? 0
                let minAmplitude = chunk.min() ?? 0
                downsampled.append(maxAmplitude)
                downsampled.append(minAmplitude)
            }
            
            // Update waveformData directly
            self.waveformData = downsampled
        } catch {
            print("Error reading audio file: \(error)")
        }
    }
}
