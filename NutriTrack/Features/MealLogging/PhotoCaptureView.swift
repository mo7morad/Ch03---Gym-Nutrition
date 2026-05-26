import SwiftUI
import UIKit

// PhotoCaptureView wraps UIImagePickerController so SwiftUI can use the camera.
//
// New concept — UIViewControllerRepresentable:
// SwiftUI is built on top of UIKit. Some hardware features (like the camera) are
// only available through UIKit APIs. UIViewControllerRepresentable is the official
// "bridge" that lets you wrap a UIViewController and use it as a SwiftUI View.
//
// The bridge has three parts:
//   1. makeUIViewController — creates the UIKit controller once
//   2. updateUIViewController — called when SwiftUI re-renders (we have nothing to update)
//   3. Coordinator — a helper class that acts as the UIKit delegate, then calls
//      Swift closures to hand results back to SwiftUI
struct PhotoCaptureView: UIViewControllerRepresentable {

    let onPhotoCaptured: (UIImage) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPhotoCaptured: onPhotoCaptured, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        // On a real device: open the camera.
        // On the Simulator: camera hardware doesn't exist, so fall back to photo library.
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera)
            ? .camera
            : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update — the picker manages its own internal state.
    }

    // MARK: - Coordinator
    // The Coordinator is an NSObject subclass (required by UIKit delegate protocols).
    // It receives UIKit delegate callbacks and translates them into Swift closures.
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        let onPhotoCaptured: (UIImage) -> Void
        let onCancel: () -> Void

        init(onPhotoCaptured: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onPhotoCaptured = onPhotoCaptured
            self.onCancel = onCancel
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onPhotoCaptured(image)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }
    }
}
