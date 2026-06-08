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
        picker.sourceType = .camera
        picker.cameraDevice = .rear
        picker.allowsEditing = false
        picker.cameraCaptureMode = .photo
        picker.showsCameraControls = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

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
            if let image {
                onPhotoCaptured(image)
            } else {
                onCancel()
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }
    }
}
