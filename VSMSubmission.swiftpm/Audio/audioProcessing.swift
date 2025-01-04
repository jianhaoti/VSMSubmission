import AVFoundation
import Combine

class AudioProcessor: ObservableObject {
    // Init
    @Published var isSampleLoaded: Bool = false
    @Published var waveformData: [Float] = []

    // Nodes
    var audioEngine: AVAudioEngine
    var playerNode: AVAudioPlayerNode
    var pitchNode: AVAudioUnitTimePitch
    var filterNode: AVAudioUnitEQ
    var dynamicsNode: AVAudioUnitEffect
    var distortionNode: AVAudioUnitDistortion
    var delayNode: AVAudioUnitDelay
    var reverbNode: AVAudioUnitReverb

    var audioFile: AVAudioFile?
    var sampleRate: Double {
        return audioFile?.processingFormat.sampleRate ?? 44100.0
    }
    let samplesPerPixel: Int = 200

    // Playback
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    @Published var isDragging: Bool = false
    
    var wasPlayingBeforeDrag = false
    var savedTime: Double = 0
    var timer: AnyCancellable?

    // Pads
    @Published var padStates: [Int: PadState] = [:]
    @Published var chopTimes: [Int: Double] = [:]
    @Published var endTimes: [Int: Double] = [:]
    @Published var selectedPadID: Int?
    
    // TimePitch
    @Published var globalPitch: Float = 0.0
    @Published var globalTempo: Float = 1.0
    @Published var padPitchOffsets: [Int: Float] = [:]
    @Published var padTempoOffsets: [Int: Float] = [:]

    var mostRecentPitchOffset: Float = 0.0 // Default pitch offset value
    var mostRecentTempoOffset: Float = 1.0 // Default tempo offset value
    
    // Pan
    @Published var padPanSettings: [Int: Float] = [:]
    var mostRecentPanSettings: Float = 0{
        didSet{
            print("Most recent pan is: \(mostRecentPanSettings)")
        }
    }

    // Distortion    
    @Published var padDistortionSettings: [Int: DistortionSettings] = [:]
    var mostRecentDistortionSettings = DistortionSettings()

    @Published var padDistortionWetDryMix: [Int: Float] = [:] // Stores wet/dry mix per pad
    @Published var padDistortionPreGain: [Int: Float] = [:] // Stores pre-gain per pad

    
    // Filter
    static let filterTypes: [AVAudioUnitEQFilterType] = [
        .lowPass, .highPass, .bandPass, .lowShelf, .highShelf, .parametric
    ]

    @Published var padFilterSettings: [Int: FilterSettings] = [:]
    @Published var currentFilterParameter: FilterParameter = .frequency

    var mostRecentFilterSettings: FilterSettings = FilterSettings()

    // Dynamics
    @Published var padDynamicsSettings: [Int: DynamicsSettings] = [:]
    
    var mostRecentDynamicsSettings: DynamicsSettings = DynamicsSettings()
    
    // DelayReverb
    @Published var padDelaySettings: [Int: DelaySettings] = [:]
    var mostRecentDelaySettings = DelaySettings()
        

    // Bypass variable stored states
    @Published var padBypassStates: [Int: [Bool]] = [:]
    var mostRecentBypass: [Bool] = [true, true, true, true] // tpd, filter, dynamics, dr

    init() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        pitchNode = AVAudioUnitTimePitch()
        filterNode = AVAudioUnitEQ(numberOfBands: 1)
        dynamicsNode = AVAudioUnitEffect(audioComponentDescription: AudioComponentDescription(
            componentType: kAudioUnitType_Effect,
            componentSubType: kAudioUnitSubType_DynamicsProcessor,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0
        ))
        distortionNode = AVAudioUnitDistortion()
        delayNode = AVAudioUnitDelay()
        reverbNode = AVAudioUnitReverb()
        
        // Initalize Filter
        let band = filterNode.bands[0]
        band.filterType = .lowPass // Set a default filter type
        band.frequency = 1000.0 // Set a default frequency
        
        // Initalize Distortion
        distortionNode.wetDryMix = mostRecentDistortionSettings.wetDryMix
        distortionNode.preGain = mostRecentDistortionSettings.preGain
        
        // Initialize Delay
        delayNode.wetDryMix = mostRecentDelaySettings.wetDryMix
        delayNode.delayTime = TimeInterval(mostRecentDelaySettings.delayTime)
        delayNode.feedback = mostRecentDelaySettings.feedback
        delayNode.lowPassCutoff = mostRecentDelaySettings.lowPassCutoff
        
        // bypass at start
        band.bypass = true
        dynamicsNode.bypass = true
        distortionNode.bypass = true
        delayNode.bypass = true
        reverbNode.wetDryMix = 0 // REVERB BYPASS IS BUGGED - IT SHUTS DOWN THE WHOLE SOUND FILE WHEN BYPASSED.
        
        audioEngine.attach(playerNode)
        audioEngine.attach(pitchNode)
        audioEngine.attach(filterNode)
        audioEngine.attach(dynamicsNode)
        audioEngine.attach(distortionNode)
        audioEngine.attach(delayNode)
        audioEngine.attach(reverbNode)

        audioEngine.connect(playerNode, to: pitchNode, format: nil)
        audioEngine.connect(pitchNode, to: distortionNode, format: nil)
        audioEngine.connect(distortionNode, to: filterNode, format: nil)
        audioEngine.connect(filterNode, to: dynamicsNode, format: nil)
        audioEngine.connect(dynamicsNode, to: delayNode, format: nil)
        audioEngine.connect(delayNode, to: reverbNode, format: nil)
        audioEngine.connect(reverbNode, to: audioEngine.outputNode, format: nil)
        
        for padID in 1...8 {
            padStates[padID] = .empty
            padPitchOffsets[padID] = 0.0
            padPitchOffsets[padID] = 1.0
            padPanSettings[padID] = 0.0

        }

        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
}
