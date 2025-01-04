import AVFoundation

struct FilterSettings {
    var filterType: AVAudioUnitEQFilterType = .lowPass
    var frequency: Float = 1000
    var bandwidth: Float = 0.5
    var gain: Float = -10
}

enum FilterParameter: String, CaseIterable {
    case frequency, bandwidth, gain
}

extension AVAudioUnitEQFilterType {
    var description: String {
        switch self {
        case .lowPass:
            return "Low Pass"
        case .highPass:
            return "High Pass"
        case .bandPass:
            return "Band Pass"
        case .lowShelf:
            return "Low Shelf"
        case .highShelf:
            return "High Shelf"
        case .parametric:
            return "Parametric"
        case .resonantLowPass:
            return ""
        case .resonantHighPass:
            return ""
        case .bandStop:
            return ""

        case .resonantLowShelf:
            return ""

        case .resonantHighShelf:
            return ""

        @unknown default:
            return "Unknown"
        }
    }
}

extension AudioProcessor{    
    // master filter settings updater
    func updateCurrentFilterSettings(_ settings: FilterSettings) {
        guard let padID = selectedPadID else { return }
        padFilterSettings[padID] = settings
        mostRecentFilterSettings = settings
        
        let filter = filterNode.bands[0]
        filter.filterType = settings.filterType
        filter.frequency = settings.frequency
        filter.bandwidth = settings.bandwidth
        filter.gain = settings.gain
        
        objectWillChange.send()
    }
    
    var currentFilterSettings: FilterSettings? {
        guard let padID = selectedPadID else { return nil }
        return padFilterSettings[padID]
    }

    func setFilterFrequency(_ frequency: Float) {
        guard var settings = currentFilterSettings else { return }
        settings.frequency = frequency
        updateCurrentFilterSettings(settings)
    }

    func setFilterBandwidth(_ bandwidth: Float) {
        guard var settings = currentFilterSettings else { return }
        settings.bandwidth = bandwidth
        updateCurrentFilterSettings(settings)
    }

    func setFilterGain(_ gain: Float) {
        guard var settings = currentFilterSettings else { return }
        settings.gain = gain
        updateCurrentFilterSettings(settings)
    }

    func nextFilterType() {
        guard var settings = currentFilterSettings else { return }
        let currentIndex = AudioProcessor.filterTypes.firstIndex(of: settings.filterType) ?? 0
        let nextIndex = (currentIndex + 1) % AudioProcessor.filterTypes.count
        settings.filterType = AudioProcessor.filterTypes[nextIndex]
        
        updateCurrentFilterSettings(settings)

        // Check if the current parameter is available, if not default to frequency
        if !availableParameters.contains(currentFilterParameter) {
            currentFilterParameter = .frequency
        }
    }

    func previousFilterType() {
        guard var settings = currentFilterSettings else { return }
        let currentIndex = AudioProcessor.filterTypes.firstIndex(of: settings.filterType) ?? 0
        let previousIndex = (currentIndex - 1 + AudioProcessor.filterTypes.count) % AudioProcessor.filterTypes.count
        settings.filterType = AudioProcessor.filterTypes[previousIndex]
        
        updateCurrentFilterSettings(settings)

        // Check if the current parameter is available in the previous, if not default to frequency
        if !availableParameters.contains(currentFilterParameter) {
            currentFilterParameter = .frequency
        }
    }

    func nextParameter() {
        let availableParams = availableParameters
        let currentIndex = availableParams.firstIndex(of: currentFilterParameter) ?? 0
        let nextIndex = (currentIndex + 1) % availableParams.count
        currentFilterParameter = availableParams[nextIndex]
    }

    func previousParameter() {
        let availableParams = availableParameters
        let currentIndex = availableParams.firstIndex(of: currentFilterParameter) ?? 0
        let previousIndex = (currentIndex - 1 + availableParams.count) % availableParams.count
        currentFilterParameter = availableParams[previousIndex]
    }

    var normalizedParameterValue: Double {
        guard let settings = currentFilterSettings else { return 0 }
        switch currentFilterParameter {
        case .frequency:
            switch settings.filterType {
            case .lowPass, .highPass:
                return Double(log10(settings.frequency / 20) / log10(20000 / 20))
            default:
                return Double(log10(settings.frequency / 20) / log10(20000 / 20))
            }
        case .bandwidth:
            switch settings.filterType {
            case .bandPass, .parametric:
                return Double((settings.bandwidth - 0.05) / (5.0 - 0.05))
            default:
                return 0 // Not applicable for other filter types
            }
        case .gain:
            switch settings.filterType {
            case .lowShelf, .highShelf, .parametric:
                return Double((settings.gain + 20) / 40)
            default:
                return 0 // Not applicable for other filter types
            }
        }
    }

    func setNormalizedParameterValue(_ value: Double) {
        guard var settings = currentFilterSettings else { return }
        switch currentFilterParameter {
        case .frequency:
            switch settings.filterType {
            case .lowPass, .highPass:
                settings.frequency = Float(pow(10, value * log10(20000 / 20))) * 20
            default:
                settings.frequency = Float(pow(10, value * log10(20000 / 20))) * 20
            }
        case .bandwidth:
            switch settings.filterType {
            case .bandPass, .parametric:
                settings.bandwidth = Float(value) * (5.0 - 0.05) + 0.05
            default:
                break // Not applicable for other filter types
            }
        case .gain:
            switch settings.filterType {
            case .lowShelf, .highShelf, .parametric:
                settings.gain = Float(value) * 40 - 20
            default:
                break // Not applicable for other filter types
            }
        }
        updateCurrentFilterSettings(settings)
    }
    var availableParameters: [FilterParameter] {
        guard let settings = currentFilterSettings else { return [] }
        
        switch settings.filterType {
            case .lowPass, .highPass:
                return [.frequency]
            case .bandPass:
                return [.frequency, .bandwidth]
            case .parametric:
                return [.frequency, .bandwidth, .gain]
            case .lowShelf, .highShelf:
                return [.frequency, .gain]
            case .resonantLowPass:
                return [.frequency, .bandwidth, .gain]

            case .resonantHighPass:
                return [.frequency, .bandwidth, .gain]

            case .bandStop:
                return [.frequency, .bandwidth, .gain]

            case .resonantLowShelf:
                return [.frequency, .bandwidth, .gain]

            case .resonantHighShelf:
                return [.frequency, .bandwidth, .gain]
            
        @unknown default:
                return [.frequency, .bandwidth, .gain]
        }
    }
}
