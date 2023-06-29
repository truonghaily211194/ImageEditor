//
//  EditorImageViewController.swift
//  ImageEditor
//
//  Created by Ly Truong H. VN.Danang on 29/06/2023.
//

import UIKit
import ZLImageEditor

class EditorImageViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var alphaLabel: UILabel!
    @IBOutlet weak var alphaSlider: UISlider!
    
    var resultImageEditModel: ZLEditImageModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        let image1 = UIImage(named: "screen2.jpg")!
        let image2 = UIImage(named: "screen4.jpg")!

        mainImageView.image = image1
        newImageView.image = image2
        
        ZLImageEditorConfiguration.default()
            .fontChooserContainerView(FontChooserContainerView())
            .editImageTools([.draw, .clip, .imageSticker, .textSticker, .mosaic, .filter, .adjust])
            .adjustTools([.brightness, .contrast, .saturation])
            .canRedo(true)
    }

    @IBAction func changeValueAlpha(_ sender: UISlider) {
        newImageView.alpha = CGFloat(sender.value)
    }

    @IBAction func addImage(_ sender: Any) {
        combineImage()
        editImage(previewImageView.image!, editModel: resultImageEditModel)
    }

    @IBAction func saveImageToAlbum(_ sender: Any) {
        alertAction()
    }
    
    func editImage(_ image: UIImage, editModel: ZLEditImageModel?) {
    
        ZLEditImageViewController.showEditImageVC(parentVC: self, image: image, editModel: editModel) { [weak self] resImage, editModel in
            self?.previewImageView.image = resImage
            self?.resultImageEditModel = editModel
        }
    }

    func alertAction() {
        let alertController = UIAlertController(title: "Chọn ảnh", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Chụp ảnh", style: .default) { (_) in
            self.choosePhoto(sourceType: .camera)
        }

        let libraryAction = UIAlertAction(title: "Chọn từ thư viện ảnh", style: .default) { (_) in
            self.choosePhoto(sourceType: .photoLibrary)
        }

        let cancelAction = UIAlertAction(title: "Huỷ", style: .cancel, handler: nil)

        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func choosePhoto(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
//        showDetailViewController(imagePickerController, sender: nil)
        present(imagePickerController, animated: true, completion: nil)
    }

    func combineImage() {
        let combinedImage = combineImages(image1: mainImageView.image, image2: newImageView.image)

        // Hiển thị hình ảnh kết hợp trên imageView
        previewImageView.image = combinedImage
        mainImageView.image = combinedImage
    }
    
    func combineImages(image1: UIImage?, image2: UIImage?) -> UIImage? {
        guard let image1 = image1, let image2 = image2 else { return nil }
        let newSize = image1.size // Kích thước mới là kích thước của hình ảnh thứ nhất
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        // Vẽ hình ảnh thứ nhất
        image1.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        // Tính toán kích thước mới và vị trí của hình ảnh thứ hai
        let aspectRatio1 = image1.size.width / image1.size.height
        let aspectRatio2 = image2.size.width / image2.size.height
        let targetRect: CGRect
        
        if aspectRatio1 > aspectRatio2 {
            let targetWidth = newSize.width
            let targetHeight = newSize.width / aspectRatio2
            let yOffset = (newSize.height - targetHeight) / 2
            targetRect = CGRect(x: 0, y: yOffset, width: targetWidth, height: targetHeight)
        } else {
            let targetWidth = newSize.height * aspectRatio2
            let targetHeight = newSize.height
            let xOffset = (newSize.width - targetWidth) / 2
            targetRect = CGRect(x: xOffset, y: 0, width: targetWidth, height: targetHeight)
        }
        
        // Vẽ hình ảnh thứ hai với content mode là aspectFill
        image2.draw(in: targetRect, blendMode: .normal, alpha: newImageView.alpha)
        
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
}

extension EditorImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Xử lý ảnh đã chọn hoặc chụp tại đây
            newImageView.image = pickedImage
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
