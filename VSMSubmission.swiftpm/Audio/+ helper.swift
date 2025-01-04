extension AudioProcessor{
    func updateBypassSettings(padID: Int){
        setDistortionBypass(padBypassStates[padID]![0])
        setFilterBypass(padBypassStates[padID]![1])
        setDynamicsBypass(padBypassStates[padID]![2])
        setDelayReverbBypass(padBypassStates[padID]![3])
    }

    func setDistortionBypass(_ bypass: Bool) {
        mostRecentBypass[0] = bypass
        distortionNode.bypass = bypass
    }

    func setFilterBypass(_ bypass: Bool) {
        mostRecentBypass[1] = bypass
        filterNode.bypass = bypass
        filterNode.bands[0].bypass = bypass
    }

    func setDynamicsBypass(_ bypass: Bool) {
        mostRecentBypass[2] = bypass
        dynamicsNode.bypass = bypass
    }
    
    func setDelayReverbBypass(_ bypass: Bool){
        mostRecentBypass[3] = bypass
        delayNode.bypass = bypass
        reverbNode.wetDryMix = 0
    }
    
    // clear out any spillover from effects
    func clearPreviousPadEffects() {
        dynamicsNode.reset()
//        distortionNode.reset()
    }

}
