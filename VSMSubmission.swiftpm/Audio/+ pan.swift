extension AudioProcessor {
    func updatePanSettings(padID: Int) {
        guard let pan = padPanSettings[padID] else { return }
        playerNode.pan = pan
    }
    
    // Normalize pan value from range [-1.0, 1.0] to range [0.0, 1.0]
    func getNormalizedPan(for padID: Int) -> Double {
        let panValue = Double(padPanSettings[padID] ?? 0.0) // Get the current pan value (default is 0.0)
        return (panValue + 1) / 2 // Normalize: -1 -> 0, 0 -> 0.5, 1 -> 1
    }

    // Denormalize pan value from range [0.0, 1.0] to range [-1.0, 1.0]
    func setNormalizedPan(for padID: Int, normalizedValue: Double) {
        let panValue = Float((normalizedValue * 2) - 1) // Denormalize: 0 -> -1, 0.5 -> 0, 1 -> 1
        padPanSettings[padID] = panValue
        
        // Update the pan settings
        mostRecentPanSettings = panValue
        updatePanSettings(padID: padID)
    }
}
