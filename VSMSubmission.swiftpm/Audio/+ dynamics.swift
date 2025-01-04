import AVFoundation

struct DynamicsSettings {
    var lowThreshold: Float = -20.0
    var highThreshold: Float = -25.0
    var ratio: Float = 2.0
    var attackTime: Float = 0.005
    var releaseTime: Float = 0.1
    var masterGain: Float = 0.0
}

extension AudioProcessor {    
    func updateCurrentDynamicsSettings(_ settings: DynamicsSettings) {
        guard let padID = selectedPadID else { return }
        padDynamicsSettings[padID] = settings
        mostRecentDynamicsSettings = settings

        // Apply the settings to the dynamics node
        setLowThreshold(settings.lowThreshold)
        setHighThreshold(settings.highThreshold)
        setRatio(settings.ratio)
        setAttackTime(settings.attackTime)
        setReleaseTime(settings.releaseTime)
        setMasterGain(settings.masterGain)
        
        objectWillChange.send()
    }

    
    var currentDynamicsSettings: DynamicsSettings? {
        guard let padID = selectedPadID else { return nil }
        return padDynamicsSettings[padID]
    }

    func setLowThreshold(_ lowThreshold: Float) {
        AudioUnitSetParameter(dynamicsNode.audioUnit, kDynamicsProcessorParam_Threshold, kAudioUnitScope_Global, 0, lowThreshold, 0)
        objectWillChange.send()
    }

    func setHighThreshold(_ highThreshold: Float) {
        guard let padID = selectedPadID else { return }
        
        padDynamicsSettings[padID]?.highThreshold = highThreshold
        AudioUnitSetParameter(dynamicsNode.audioUnit, kDynamicsProcessorParam_ExpansionThreshold, kAudioUnitScope_Global, 0, highThreshold, 0)
        
        // Trigger update for UI
        objectWillChange.send()
    }

    func setRatio(_ ratio: Float) {
        guard let padID = selectedPadID else { return }
        
        padDynamicsSettings[padID]?.ratio = ratio
        AudioUnitSetParameter(dynamicsNode.audioUnit, kDynamicsProcessorParam_ExpansionRatio, kAudioUnitScope_Global, 0, ratio, 0)
        objectWillChange.send()
    }

    func setAttackTime(_ attackTime: Float) {
        AudioUnitSetParameter(dynamicsNode.audioUnit, kDynamicsProcessorParam_AttackTime, kAudioUnitScope_Global, 0, attackTime, 0)
        objectWillChange.send()
    }

    func setReleaseTime(_ releaseTime: Float) {
        AudioUnitSetParameter(dynamicsNode.audioUnit, kDynamicsProcessorParam_ReleaseTime, kAudioUnitScope_Global, 0, releaseTime, 0)
        objectWillChange.send()
    }

    func setMasterGain(_ gain: Float) {
        AudioUnitSetParameter(dynamicsNode.audioUnit, kDynamicsProcessorParam_OverallGain, kAudioUnitScope_Global, 0, gain, 0)
        objectWillChange.send()
    }
    
    // normalizations
    func clamp(_ value: Double, min: Double, max: Double) -> Double {
        return Swift.max(min, Swift.min(max, value))
    }
    
    var normalizedDynamicsThreshold: Double {
        guard let settings = currentDynamicsSettings else { return 0 }
        return Double((settings.highThreshold + 30) / 30)  // Normalize -30 to 0 range
    }
    
    func setNormalizedDynamicsThreshold(_ normalizedValue: Double) {
        let threshold = Float(normalizedValue * 30 - 30)  // Denormalize back to -30 to 0
        setHighThreshold(threshold)
    }
    
    var normalizedDynamicsRatio: Double {
        guard let settings = currentDynamicsSettings else { return 0 }
        return clamp((log2(Double(settings.ratio)) / log2(10)), min: 0, max: 1)
    }
    
    func setNormalizedDynamicsRatio(_ normalizedValue: Double) {
        let ratio = Float(pow(10, normalizedValue))  // Denormalize from 1:1 to 20:1 range
        setRatio(ratio)
    }
}
