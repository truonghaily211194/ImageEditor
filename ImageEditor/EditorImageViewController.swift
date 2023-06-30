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
    
    var hasImage = false
    let image1 = UIImage(named: "below.png")!
    let image2 = UIImage(named: "above.png")!
    let image3 = UIImage(named: "combine_images.png")!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Image Editor"
        // Đặt màu cho tiêu đề của thanh điều hướng
        let titleAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.systemBlue, // Màu của tiêu đề
            .font: UIFont.boldSystemFont(ofSize: 18) // Font chữ của tiêu đề
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes

//        if #available(iOS 15.0, *) {
//            let appearance = UINavigationBarAppearance()
//            appearance.configureWithDefaultBackground()
//            appearance.shadowColor = .clear
//            appearance.backgroundColor = UIColor.init(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
//            navigationController?.navigationBar.standardAppearance = appearance
//            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
//        } else {
//            navigationController?.navigationBar.barTintColor = UIColor.init(red: 0.961, green: 0.961, blue: 0.961, alpha: 1)
//        }

        mainImageView.image = image2
        newImageView.image = image2
        newImageView.alpha = 0.5
        previewImageView.image = image3

        addTapGesturePreviewImage()
        createBarButton()

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
        alertAction()
    }

    @IBAction func preview(_ sender: Any) {
        combineImage()
//        previewImageView.image = newImageView.image
    }

    @IBAction func saveImageToAlbum(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(previewImageView.image ?? UIImage(named: "screen2.jpg")!, self, #selector(saveDone), nil)
    }

    @IBAction func switchImage(_ sender: UISwitch) {
        alphaLabel.text = sender.isOn ? "above" : "below"
    }
    
    func addTapGesturePreviewImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        previewImageView.isUserInteractionEnabled = true
        previewImageView.addGestureRecognizer(tapGesture)
    }

    func createBarButton() {
        // Tạo nút rightBarButton với tiêu đề "Edit"
        let rightBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = rightBarButton

        // Tạo nút leftBarButton với biểu tượng "Reset"
        let resetButton = UIBarButtonItem(image: UIImage(named: "reset_icon"), style: .plain, target: self, action: #selector(resetButtonTapped))
        navigationItem.leftBarButtonItem = resetButton
    }

    func editImage(_ image: UIImage, editModel: ZLEditImageModel?) {
        ZLEditImageViewController.showEditImageVC(parentVC: self, image: image, editModel: nil) { [weak self] resImage, editModel in
            DispatchQueue.main.async {
                self?.previewImageView.image = resImage
                self?.resultImageEditModel = editModel
            }
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
        if let imageData = combinedImage?.pngData() {
            let combinedImageDataWithHighQuality = UIImage(data: imageData)
            // Lưu combinedImageDataWithHighQuality hoặc sử dụng nó cho mục đích khác
    
            // Hiển thị hình ảnh kết hợp trên imageView
            previewImageView.image = combinedImageDataWithHighQuality
            mainImageView.image = combinedImageDataWithHighQuality
        }
        
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

    @objc func saveDone(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
        let alert = UIAlertController(title: nil, message: "Save To Album", preferredStyle: .alert)
        if let err = error {
            alert.addAction(UIAlertAction(title: err.localizedDescription, style: .destructive))
        } else {
            alert.addAction(UIAlertAction(title: "Done", style: .destructive))
        }
        self.present(alert, animated: true)
    }

    @objc func imageTapped() {
        editImage(previewImageView.image!, editModel: resultImageEditModel)
    }

    @objc func editButtonTapped() {
        editImage(previewImageView.image!, editModel: resultImageEditModel)
    }

    @objc func resetButtonTapped() {
        hasImage = false
        mainImageView.image = image2
        newImageView.image = image2
        newImageView.alpha = 0.5
        previewImageView.image = image3
    }
}

extension EditorImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Xử lý ảnh đã chọn hoặc chụp tại đây
            if hasImage {
                newImageView.image = pickedImage
            } else {
                mainImageView.image = pickedImage
                hasImage = true
            }
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
