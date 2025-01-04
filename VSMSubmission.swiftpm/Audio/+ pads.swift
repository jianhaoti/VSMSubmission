import AVFoundation

enum PadState {
    case empty
    case loaded
    case favorite
}

extension AudioProcessor{
    func isPadFavorite(padID: Int) -> Bool {
        return getPadState(for: padID) == .favorite
    }

    func toggleFavorite(padID: Int) {
        let currentState = getPadState(for: padID)
        let newState: PadState = (currentState == .favorite) ? .loaded : .favorite
        setPadState(newState, for: padID)
    }

    func getPadState(for padID: Int) -> PadState {
        return padStates[padID, default: .empty]
    }
    
    func setPadState(_ state: PadState, for padID: Int) {
        padStates[padID] = state
    }

    // Modify the existing addChopTime function
    func setChopTime(_ time: Double, for padID: Int) {
        chopTimes[padID] = time
    }

    
    // Modify the existing removeChopTime function
    func removeChopTime(for padID: Int) {
        chopTimes[padID] = nil
        endTimes[padID] = nil
        setPadState(.empty, for: padID)
        print("Removed chop time for pad \(padID)")
    }

    func removeEndTime(for padID: Int) {
        endTimes.removeValue(forKey: padID)
    }

    func getChopTime(for padID: Int) -> Double? {
        return chopTimes[padID]
    }
    
    func getEndTime(for padID: Int) -> Double? {
        return endTimes[padID]
    }

    
    func setEndTime(_ newTime: Double, for padID: Int) {
        endTimes[padID] = newTime
    }

    
    func selectPad(_ padID: Int) {
        // clear any spillover effects
        clearPreviousPadEffects()
        selectedPadID = padID
        
        let anySettingIsMissing: Bool =
                                (padFilterSettings[padID] == nil ||
                                padDynamicsSettings[padID] == nil ||
                                padPitchOffsets[padID] == nil ||
                                padTempoOffsets[padID] == nil ||
                                padDistortionSettings[padID] == nil ||
                                padDelaySettings[padID] == nil)

        if anySettingIsMissing
        {
            padFilterSettings[padID] = mostRecentFilterSettings
            padDynamicsSettings[padID] = mostRecentDynamicsSettings
            padPitchOffsets[padID] = mostRecentPitchOffset
            padTempoOffsets[padID] = mostRecentTempoOffset
            padDistortionSettings[padID] = mostRecentDistortionSettings
            padDelaySettings[padID] = mostRecentDelaySettings
            padBypassStates[padID] = mostRecentBypass
            padPanSettings[padID] = mostRecentPanSettings
        }
                
        
        // Update filter settings
        updateCurrentFilterSettings(padFilterSettings[padID]!)
        updateCurrentDynamicsSettings(padDynamicsSettings[padID]!)
        updateCurrentDistortionSettings(for: padID)
//        updateCurrentDelaySettings(padDelaySettings[padID]!)
        
        setCombinedPitch()
        setCombinedTempo()
        
        // Update bypass settings
        updateBypassSettings(padID: padID)
    }

}
