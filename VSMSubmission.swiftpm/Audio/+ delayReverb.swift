import Foundation
struct DelaySettings {
    var wetDryMix: Float = 50.0
    var delayTime: Float = 0.5
    var feedback: Float = 50.0
    var lowPassCutoff: Float = 10000.0 // Low-pass cutoff frequency in Hz
}

struct ReverbSettings {
    var wetDryMix: Float = 50.0
}

extension AudioProcessor {
    func updateCurrentDelaySettings(_ settings: DelaySettings) {
        guard let padID = selectedPadID else { return }
        padDelaySettings[padID] = settings
        mostRecentDelaySettings = settings

        setDelayWetDryMix(settings.wetDryMix)
        setDelayTime(settings.delayTime)
        setDelayFeedback(settings.feedback)
        setDelayLowPassCutoff(settings.lowPassCutoff)

        objectWillChange.send()
    }

    func setDelayWetDryMix(_ mix: Float) {
        delayNode.wetDryMix = mix
        mostRecentDelaySettings.wetDryMix = mix
        objectWillChange.send()
    }

    func setDelayTime(_ time: Float) {
        delayNode.delayTime = TimeInterval(time)
        mostRecentDelaySettings.delayTime = time
        objectWillChange.send()
    }

    func setDelayFeedback(_ feedback: Float) {
        delayNode.feedback = feedback
        mostRecentDelaySettings.feedback = feedback
        objectWillChange.send()
    }

    func setDelayLowPassCutoff(_ cutoff: Float) {
        delayNode.lowPassCutoff = cutoff
        mostRecentDelaySettings.lowPassCutoff = cutoff
        objectWillChange.send()
    }
}
