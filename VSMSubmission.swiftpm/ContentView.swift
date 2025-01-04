import SwiftUI
import UniformTypeIdentifiers

@available(iOS 17.0, *)
struct ContentView: View {
    @StateObject private var audioProcessor = AudioProcessor()
    
    init() {
        let audio = AudioProcessor()
        _audioProcessor = StateObject(wrappedValue: audio)
    }

    @State private var showingSettingsMenu = false
    @State private var isImporting: Bool = false

    @State private var loadIsPressed: Bool = false
    @State private var globalViewText: String = "Tap to load sample"

    @State private var globalPitchValue: Float = 0
    @State private var globalTempoValue: Float = 1
    @State private var showDeleteConfirmation = false

    @State private var showOptions = false
    
    // paginiation states
    @State var currentLocalEffectPage = 0
    @State var currentPadAdjPage = 0


    // added context
    let theme = Theme()
    
    let leftPortionSize: CGFloat = 0.55
    let rightPortionSize: CGFloat = 0.25
    let hitboxSize: CGFloat = 40
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            // Check if the app is in portrait orientation
            if geometry.size.height > geometry.size.width {
                // Display text when in portrait orientation
                VStack {
                    Text("Switch to horizontal")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            } else {
                // Display the main content when in landscape orientation
                landscapeContentView(geometry: geometry)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

        
    @available(iOS 17.0, *)
    private func landscapeContentView(geometry: GeometryProxy) -> some View {
        GeometryReader { geometry in
            HStack {
                Spacer() // Left spacer
                VStack(spacing: 40) {
                    // First row of BigBoxes
                    HStack(spacing: 60) {
                        // Global view
                        ZStack {
                            Text("Sampled Waveform")
                                .foregroundColor(theme.grayText)
                                .font(.system(size: 12))
                                .padding(.bottom, geometry.size.height * 0.02)
                                .offset(y: -geometry.size.height * 0.1)
                            
                            BigBox(height: geometry.size.height * 0.2,
                                   width: geometry.size.width * leftPortionSize,
                                   fillColor: theme.lightBlue)
                            // Waveform
                            .overlay(
                                Group {
                                    if !audioProcessor.waveformData.isEmpty {
                                        GeometryReader { globalViewBox in
                                            ZStack {
                                                WaveformView(audioProcessor: audioProcessor, data: audioProcessor.waveformData).frame(width: globalViewBox.size.width, height: globalViewBox.size.height * 0.965)
                                                    .position(x: globalViewBox.size.width / 2, y: globalViewBox.size.height / 2)
                                                    .clipped()
                                                
                                                VStack {
                                                    Spacer().frame(height: globalViewBox.size.height * 0.08) // Adjust the height of the transparent box
                                                    HStack {
                                                        Spacer()
                                                        BigBox(height: globalViewBox.size.height * 0.26,
                                                               width: globalViewBox.size.width * 0.16,
                                                               fillColor: .white.opacity(0.8))
                                                        .overlay(
                                                            HStack(spacing: 10) {
                                                                Button(action: {
                                                                    audioProcessor.togglePlayback()
                                                                }) {
                                                                    Image(systemName: audioProcessor.isPlaying ? "pause.fill" : "play.fill")
                                                                        .foregroundColor(.blue)
                                                                        .font(.system(size: 18))
                                                                }
                                                                Text("\(audioProcessor.formatTime(audioProcessor.currentTime)) / \(audioProcessor.formatTime(audioProcessor.totalDuration))")
                                                                    .font(.system(size: 12))
                                                                    .foregroundColor(.blue)

                                                            }
                                                            .padding(1)
                                                        )
                                                        .padding(.trailing, 10)

                                                    }
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        Text(globalViewText)
                                            .foregroundColor(loadIsPressed ? Color.gray : Color.blue)
                                            .font(.system(size: 14))
                                            .onTapGesture{
                                                showOptions = true
                                                loadIsPressed = true
                                            }
                                            .confirmationDialog("Choose Audio Source",
                                                                isPresented: $showOptions){
                                                Button("Play Preloaded Audio") {
                                                    audioProcessor.loadSample() // Your method to play preloaded audio
                                                    loadIsPressed = false
                                                }
                                                Button("Use Apple Music") {
                                                    print("Play music from Apple Music") // Replace with your Apple Music integration
                                                    loadIsPressed = false
                                                }
                                                Button("Cancel", role: .cancel) {
                                                    print("Cancelled")
                                                    loadIsPressed = false
                                                }

                                            }
//                                            .onTapGesture {
//                                                loadIsPressed = true
//                                                globalViewText = "Loading sample"
//
//                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                                    loadIsPressed = false
//                                                    audioProcessor.loadSample()
//                                                }
//                                            }
                                    }
                                }
                            )
                            .onTapGesture {
                                if !audioProcessor.waveformData.isEmpty {
                                    audioProcessor.togglePlayback()
                                }
                            }
                        }

                        // Global setting
                        ZStack {
                            Text("Global Controls")
                                .foregroundColor(theme.grayText)
                                .font(.system(size: 12))
                                .padding(.bottom, geometry.size.height * 0.02)
                                .offset(y: -geometry.size.height * 0.1)
                            
                            BigBox(height: geometry.size.height * 0.2,
                                   width: geometry.size.width * 0.25,
                                   fillColor: theme.lightBlue)
                            .overlay(GlobalControlView(audioProcessor: audioProcessor, globalPitchValue: $globalPitchValue, globalTempoValue: $globalTempoValue))
                        }
                    }
                    .padding(.top, geometry.size.height * 0.075) // Adjust the value to control the amount of padding
                    
                    // Second row of BigBoxes
                    HStack(spacing: 60) {
                        HStack(spacing: 20) {
                            // Local Controls
                            ZStack {
                                Text("Local Controls")
                                    .foregroundColor(theme.grayText)
                                    .font(.system(size: 12))
                                    .padding(.bottom, geometry.size.height * 0.02)
                                    .offset(y: -geometry.size.height * 0.1)
                                
                                BigBox(height: geometry.size.height * 0.2,
                                       width: (geometry.size.width * leftPortionSize) * (3/3),
                                       fillColor: theme.lightBlue)
                            }
                            .overlay(
                                ZStack {
                                    Group{
                                        if audioProcessor.selectedPadID != nil {
                                            ZStack{
                                                LocalControlView(
                                                    audioProcessor: audioProcessor,
                                                    currentPage: $currentLocalEffectPage,
                                                    width: geometry.size.width * leftPortionSize,
                                                    height: geometry.size.height * 0.2 * 0.8,
                                                    centerX: (geometry.size.width * leftPortionSize) / 2 - 40)
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        
                                                        // Toggles on/off for current effect
                                                        Button(action: {
                                                            if var bypassStates = audioProcessor.padBypassStates[audioProcessor.selectedPadID!] {
                                                                bypassStates[currentLocalEffectPage].toggle()
                                                                
                                                                audioProcessor.padBypassStates[audioProcessor.selectedPadID!] = bypassStates
                                                                audioProcessor.updateBypassSettings(padID: audioProcessor.selectedPadID!)

                                                            }
                                                        })
                                                        {
                                                            ZStack(alignment: .topTrailing) {
                                                                Rectangle() // Hitbox
                                                                    .foregroundColor(.clear)
                                                                    .frame(width: hitboxSize, height: hitboxSize)
                                                                
                                                                Image(systemName: audioProcessor.padBypassStates[audioProcessor.selectedPadID!]![currentLocalEffectPage] ? "waveform.slash" : "waveform")
                                                                    .foregroundColor(audioProcessor.padBypassStates[audioProcessor.selectedPadID!]![currentLocalEffectPage] ? theme.grayText : .black)
                                                                    .padding(10)
                                                            }
                                                        }
                                                        
                                                    }
                                                    Spacer()
                                                }
                                            }
                                        }
                                        else {
                                            Text("Tap a pad")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                            )
                            
                            
                        }
                        
                        // Logo
                        ZStack {
                            Image("hawk")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * rightPortionSize,
                                       height: geometry.size.height * 0.2)
                                .clipped()
//                                .offset(y: geometry.size.height * -0.00005)

                            Text("VSM 800")
                                .font(.custom("Roboto-Light", size: 28))
                                .kerning(1.5) // Adjust letter spacing
                                .foregroundColor(.black.opacity(0.7))
                                .offset(y: -geometry.size.height * 0.085)
                            }
                    }
                    
                    // Third row
                    HStack(spacing: 60) {
                        // Pad Grid
                        PadGrid(audioProcessor: audioProcessor, fillColor: theme.bgColor)
                            .onChange(of: audioProcessor.selectedPadID) {
                            }
                            .frame(width: geometry.size.width * leftPortionSize, height: geometry.size.height * 0.4)

                        // Local Adjustments
                        ZStack {
                            Text("Local Adjustments")
                                .foregroundColor(theme.grayText)
                                .font(.system(size: 12))
                                .padding(.bottom, geometry.size.height * 0.02)
                                .offset(y: -geometry.size.height * 0.18)

                            BigBox(height: geometry.size.height * 0.36,
                                    width: geometry.size.width * rightPortionSize,
                                    fillColor: theme.lightBlue)
                            .overlay(
                                Group {
                                    if let selectedPadID = audioProcessor.selectedPadID,
                                       audioProcessor.getChopTime(for: selectedPadID) != nil {
                                        ZStack {
                                            PadAdjustmentView(audioProcessor: audioProcessor,
                                                              currentPage: $currentPadAdjPage)
                                            VStack {
                                                // Header
                                                HStack {
                                                    Button(action: {
                                                        audioProcessor.toggleFavorite(padID: selectedPadID)
                                                    })
                                                    {
                                                        ZStack(alignment: .topLeading){
                                                            Rectangle() // Background circle
                                                                .foregroundColor(.clear) // Make the circle clear
                                                                .frame(width: hitboxSize, height: hitboxSize) // Set the size of the circle
                                                            
                                                            Image(systemName: audioProcessor.isPadFavorite(padID: selectedPadID) ? "heart.fill" : "heart")
                                                                .foregroundColor(audioProcessor.isPadFavorite(padID: selectedPadID) ? .black: .gray)
                                                                .padding(10)

                                                        }
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Button(action: {
                                                        audioProcessor.pause()
                                                        showDeleteConfirmation = true
                                                    }) {
                                                        ZStack(alignment: .topTrailing) {
                                                            Rectangle() // Background circle
                                                                .foregroundColor(.clear) // Make the circle clear
                                                                .frame(width: hitboxSize, height: hitboxSize) // Set the size of the circle
                                                            
                                                            Image(systemName: "trash") // Front image
                                                                .foregroundColor(.gray) // Color of the image
                                                                .padding(10)
                                                        }
                                                    }
                                                    .disabled(audioProcessor.isPadFavorite(padID: selectedPadID))
                                                    
                                                }
                                                Spacer()
                                                HStack{
                                                    EffectsIndicator(numberOfPages: 4, selectedColor: theme.recColor, onEffects: audioProcessor.padBypassStates[audioProcessor.selectedPadID!]!)
                                                        .padding(10)
                                                    PageIndicator(numberOfPages: 2, selectedColor: .blue.opacity(0.8), currentPage: $currentPadAdjPage)
                                                        .padding(10)
                                                        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                                                }
                                            }
                                        }
                                        
                                    }
                                    
                                    else {
                                        Text("No pad selected")
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)

                                    }
                                }
                            )
                        }
                        .alert(isPresented: $showDeleteConfirmation) {
                            Alert(
                                title: Text("Delete Pad"),
                                message: Text("Are you sure you want to delete this pad?"),
                                primaryButton: .destructive(Text("Yes")) {
                                    if let selectedPadID = audioProcessor.selectedPadID {
                                        audioProcessor.removeChopTime(for: selectedPadID)
                                    }
                                },
                                secondaryButton:.cancel()
                            )
                        }
                    }
                    .padding(.bottom, geometry.size.height * 0.1)
                    
                }
                Spacer() // Right spacer
            }.background(Color.white)
        }
    }
}

@available(iOS 17.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
