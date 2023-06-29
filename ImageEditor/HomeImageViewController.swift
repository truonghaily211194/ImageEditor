//
//  HomeImageViewController.swift
//  ImageEditor
//
//  Created by Ly Truong H. VN.Danang on 23/06/2023.
//

import UIKit

class HomeImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var currentScale: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        let image1 = UIImage(named: "screen2.jpg")!
        imageView.image = image1
        scrollView.delegate = self
        setupGestureRecognizer()
        setupScrollView()
    }
    
    func setupGestureRecognizer() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        imageView.addGestureRecognizer(pinchGesture)
    }
    
    func setupScrollView() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.zoomScale = 1.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @objc func handlePinchGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            currentScale *= gestureRecognizer.scale
            gestureRecognizer.scale = 1.0
        }
    }
    
    @IBAction func cropAndSaveButtonTapped(_ sender: UIButton) {
        guard let croppedImage = cropImageWithZoom() else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(croppedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func cropImageWithZoom() -> UIImage? {
        let scale = 1.0 / (scrollView.contentScaleFactor * currentScale)
        let cropRect = CGRect(x: scrollView.contentOffset.x * scale,
                              y: scrollView.contentOffset.y * scale,
                              width: scrollView.bounds.size.width * scale,
                              height: scrollView.bounds.size.height * scale)

        guard let imageRef = imageView.image?.cgImage?.cropping(to: cropRect) else {
            return nil
        }

        let croppedImage = UIImage(cgImage: imageRef, scale: imageView.contentScaleFactor, orientation: imageView.image?.imageOrientation ?? .up)
        return croppedImage
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Save error: \(error.localizedDescription)")
        } else {
            print("Image saved successfully.")
        }
    }
}
