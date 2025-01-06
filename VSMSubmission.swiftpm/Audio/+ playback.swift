import AVFoundation

extension AudioProcessor{
    func pause() {
        playerNode.pause()
        isPlaying = false
        stopTimer()
    }

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func play() {
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
        
        // find correct positin
        guard let file = audioFile else { return }
        if currentTime >= totalDuration {
            currentTime = 0
        }
        let framePosition = AVAudioFramePosition(currentTime * sampleRate)
        playerNode.scheduleSegment(file, startingFrame: framePosition, frameCount: AVAudioFrameCount.max, at: nil)
                
        // play
        playerNode.play()
        isPlaying = true
        startTimer()
    }

    func setCurrentTime(_ newTime: TimeInterval) {
        currentTime = max(0, min(newTime, totalDuration))
        objectWillChange.send()
    }

    func seekTo(time: TimeInterval) {
        guard let audioFile = audioFile else { return }
        
        playerNode.stop() // resets the playertime !!!
        setCurrentTime(time)
        savedTime = currentTime
        let framePosition = AVAudioFramePosition(currentTime * sampleRate)

        playerNode.scheduleSegment(audioFile, startingFrame: framePosition, frameCount: AVAudioFrameCount.max, at: nil)
                
        if wasPlayingBeforeDrag {
            playerNode.play()
        }
        startTimer()

    }

    func startTimer() {
        stopTimer()
        timer = Timer.publish(every: 0.03, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateCurrentTime()
            }
    }

    private func updateCurrentTime() {
            if !isPlaying || isDragging {
                return
            }
            // playerNode is reset, so this counts elapsed time
            if let nodeTime = playerNode.lastRenderTime,
               let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
                let elapsedTime = Double(playerTime.sampleTime) / sampleRate
                currentTime = elapsedTime + savedTime
                
            if currentTime >= totalDuration {
                currentTime = totalDuration
                savedTime = 0
                currentTime = 0
                playerNode.stop()
                stopTimer()
                play() //loop from beginning
            }
            
        }
    }

    func stopTimer() {
        timer?.cancel()
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func pausePlaybackIfNeeded() {
        wasPlayingBeforeDrag = isPlaying
        if isPlaying {
            pause()
        }
    }

    func resumePlaybackIfNeeded() {
        if wasPlayingBeforeDrag {
            play()
        }
    }

}
