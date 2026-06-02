import SwiftUI
import UIKit

struct PhotoCaptureView: UIViewControllerRepresentable {

    let onPhotoCaptured: (UIImage) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPhotoCaptured: onPhotoCaptured, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()

        let source: UIImagePickerController.SourceType =
            UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.sourceType = source

        if source == .camera {
            picker.cameraCaptureMode = .photo
            picker.showsCameraControls = true
        }

        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // MARK: - Coordinator

    final class Coordinator: NSObject,
                             UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate {

        let onPhotoCaptured: (UIImage) -> Void
        let onCancel: () -> Void

        init(onPhotoCaptured: @escaping (UIImage) -> Void,
             onCancel: @escaping () -> Void) {
            self.onPhotoCaptured = onPhotoCaptured
            self.onCancel = onCancel
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
            // Call the closure FIRST — this triggers a SwiftUI state change
            // which causes MealLogView to swap out PhotoCaptureView entirely.
            // SwiftUI's own transition replaces the view; we don't need UIKit
            // to also run a dismiss animation on a controller it no longer owns.
            if let image {
                onPhotoCaptured(image)
            } else {
                onCancel()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Same reasoning — let SwiftUI handle the transition.
            onCancel()
        }
    }
}
