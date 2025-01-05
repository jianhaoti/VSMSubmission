struct DistortionSettings {
    var wetDryMix: Float = 50.0
    var preGain: Float = 0.0
}

extension AudioProcessor{
    func updateCurrentDistortionSettings(for padID: Int) {
        guard let settings = padDistortionSettings[padID] else { return }
        distortionNode.wetDryMix = settings.wetDryMix
        distortionNode.preGain = settings.preGain
    }

    func setPadDistortionWetDryMix(padID: Int, value: Float) {
        padDistortionSettings[padID]?.wetDryMix = value
        if selectedPadID == padID {
            distortionNode.wetDryMix = value
        }
        mostRecentDistortionSettings.wetDryMix = value
    }

    func setPadDistortionPreGain(padID: Int, value: Float) {
        padDistortionSettings[padID]?.preGain = value
        if selectedPadID == padID {
            distortionNode.preGain = value
        }
        mostRecentDistortionSettings.preGain = value
    }

}
