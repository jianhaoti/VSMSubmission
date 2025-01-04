import AVFoundation
import Combine

extension AudioProcessor {
    // GLOBAL
    func getCombinedPitch(for padID: Int) -> Float {
        let localOffset = padPitchOffsets[padID] ?? 0.0
        return globalPitch + localOffset
    }

    func getCombinedTempo(for padID: Int) -> Float {
        let localOffset = padTempoOffsets[padID] ?? 1.0
        return globalTempo * localOffset
    }
    
    func setGlobalPitch(_ pitch: Float) {
        globalPitch = pitch
        setCombinedPitch()
    }

    func setGlobalTempo(_ tempo: Float) {
        globalTempo = tempo
        setCombinedTempo()
    }

    // LOCAL
    func getPadPitchOffset(padID:Int) -> Float {
        return padPitchOffsets[padID]!
    }
    
    func setPadPitchOffset(padID: Int, _ offset: Float) {
        padPitchOffsets[padID] = offset
        if selectedPadID == padID {
            setCombinedPitch()
        }
        mostRecentPitchOffset = offset
    }

    func setPadTempoOffset(padID: Int, _ offset: Float) {
        padTempoOffsets[padID] = offset
        if selectedPadID == padID {
            setCombinedTempo()
        }
        mostRecentTempoOffset = offset
    }

    
    // COMBINED
    func setCombinedPitch() {
        // If no pad is selected, use the global pitch
        guard let padID = selectedPadID else {
            pitchNode.pitch = min(max(globalPitch, -2400), 2400) // Use the global pitch if no pad is selected
            return
        }
        let combinedPitch = getCombinedPitch(for: padID)
        pitchNode.pitch = min(max(combinedPitch, -2400), 2400) // Clamped pitch range
    }

    func setCombinedTempo() {
        // If no pad is selected, use the global tempo
        guard let padID = selectedPadID else {
            pitchNode.rate = min(max(globalTempo, 0.25), 4.0) // Use the global tempo if no pad is selected
            return
        }
        let combinedTempo = getCombinedTempo(for: padID)
        pitchNode.rate = min(max(combinedTempo, 0.25), 4.0) // Clamped tempo range
    }
}
