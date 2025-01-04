import SwiftUI
import MediaPlayer

struct MediaPlayerView: UIViewControllerRepresentable {
    @ObservedObject var audioProcessor: AudioProcessor
    var onFail: (() -> Void)  // Callback to notify when an error occurs

    // Create the MPMediaPickerController
    func makeUIViewController(context: Context) -> MPMediaPickerController {
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.delegate = context.coordinator
        picker.prompt = "Choose a song"
        picker.allowsPickingMultipleItems = false

        // Request authorization before presenting the picker
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    print("Media library access not granted, loading default drum loop.")
                    onFail()  // Notify ContentView to load the default drum loop
                }
            }
        }
        
        return picker
    }

    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, @preconcurrency MPMediaPickerControllerDelegate {
        var parent: MediaPlayerView

        init(_ parent: MediaPlayerView) {
            self.parent = parent
        }

        @MainActor func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            mediaPicker.dismiss(animated: true, completion: nil)

            guard let mediaItem = mediaItemCollection.items.first,
                  let url = mediaItem.assetURL else {
                print("Error: Could not load song, loading default drum loop.")
                parent.onFail()  // Notify ContentView to load the default drum loop
                return
            }
            
            parent.audioProcessor.loadAudio(url: url)  // Load the selected audio file
        }

        @MainActor func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            print("Media picker cancelled by user.")
            mediaPicker.dismiss(animated: true, completion: nil)
        }
    }
}
