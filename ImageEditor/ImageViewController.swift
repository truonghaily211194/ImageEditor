//
//  ImageViewController.swift
//  personal-spending
//
//  Created by Ly Truong H. VN.Danang on 22/06/2023.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayImageView: UIImageView!
    @IBOutlet weak var alphaSlider: UISlider!
//    @IBOutlet weak var pinchGestureRecognizer: UIPinchGestureRecognizer!
//    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var imageTestView: InteractiveImageView!
    
    var initialScale: CGFloat = 1.0
    var currentScale: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        imageTestView.isHidden = true

        // Đặt các thuộc tính khởi đầu cho overlayImageView
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        overlayImageView.addGestureRecognizer(pinchGestureRecognizer)
        overlayImageView.contentMode = .scaleAspectFit
        overlayImageView.isUserInteractionEnabled = true
        overlayImageView.alpha = CGFloat(alphaSlider.value)

        let image1 = UIImage(named: "screen2.jpg")!
        let image2 = UIImage(named: "screen4.jpg")!

        overlayImageView.image = image1
        imageView.image = image2

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        overlayImageView.addGestureRecognizer(panGestureRecognizer)
        overlayImageView.isUserInteractionEnabled = true
    }

    // Xử lý sự kiện khi kéo thanh trượt alpha
    @IBAction func alphaSliderValueChanged(_ sender: UISlider) {
        overlayImageView.alpha = CGFloat(sender.value)
    }

    // Xử lý sự kiện khi pinch gestures được thực hiện
    @objc func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
//        overlayImageView.transform = overlayImageView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
//        gesture.scale = 1

        if recognizer.state == .began {
            initialScale = currentScale
        } else if recognizer.state == .changed {
            currentScale = initialScale * recognizer.scale
//            recognizer.scale = 1
            updateImageViewScale()
        }

    }

    // Xử lý sự kiện khi pan gestures được thực hiện
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        overlayImageView.center = CGPoint(x: overlayImageView.center.x + translation.x, y: overlayImageView.center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.view)
    }

    func updateImageViewScale() {
        overlayImageView.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
    }

    func saveCroppedImage() -> UIImage {
        let scale = 1.0 / (overlayImageView.contentScaleFactor * currentScale)
        let cropRect = CGRect(x: overlayImageView.bounds.origin.x * scale,
            y: overlayImageView.bounds.origin.y * scale,
            width: overlayImageView.bounds.size.width * scale,
            height: overlayImageView.bounds.size.height * scale)

        guard let imageRef = overlayImageView.image?.cgImage?.cropping(to: cropRect) else {
            return overlayImageView.image!
        }

        let croppedImage = UIImage(cgImage: imageRef, scale: overlayImageView.contentScaleFactor, orientation: overlayImageView.image?.imageOrientation ?? .up)

//        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        return croppedImage
    }

    // Xử lý sự kiện khi nút "Combine" được nhấn
    @IBAction func combineButtonTapped(_ sender: UIButton) {
        let imageOver = saveCroppedImage()
        let combinedImage = combineImages(image: imageOver, overlayImage: overlayImageView.image)

        // Hiển thị hình ảnh kết hợp trên imageView
        imageView.image = combinedImage
    }

    // Hàm để ghép chồng hai hình ảnh
    func combineImages(image: UIImage?, overlayImage: UIImage?) -> UIImage? {
        guard let image = image, let overlayImage = overlayImage else { return nil }

        let canvasSize = CGSize(width: image.size.width, height: image.size.height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0.0)

        image.draw(in: CGRect(origin: .zero, size: canvasSize))
        overlayImage.draw(in: CGRect(origin: .zero, size: canvasSize), blendMode: .normal, alpha: overlayImageView.alpha)

        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return combinedImage
    }

    @IBAction func save(_ sender: Any) {
        let imageOver = saveCroppedImage()
        let combinedImage = combineImages(image: imageView.image, overlayImage: imageOver)
        guard let image = combinedImage else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(imageOver, self, #selector(saveDone), nil)
//        saveCroppedImage()
    }

    @objc func saveDone(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
        let alert = UIAlertController(title: nil, message: "Save To Album", preferredStyle: .alert)
        if let err = error {
            alert.addAction(UIAlertAction(title: err.localizedDescription, style: .destructive))
        } else {
            alert.addAction(UIAlertAction(title: "Done", style: .destructive))
        }
        self.present(alert, animated: true)
    }
}
