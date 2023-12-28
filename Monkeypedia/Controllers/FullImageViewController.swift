import UIKit
import Photos

class FullImageBreedViewController: UIViewController {

    var fullImage: UIImage? {
        didSet {
            isImageInFavorites = UserDefaultsManager.shared.isImageInFavorites(fullImage)
        }
    }

    var isImageInFavorites: Bool = false {
        didSet {
            updateFavoriteButtonAppearance()
        }
    }

    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save to Gallery", for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(FullImageBreedViewController.self, action: #selector(saveImageToGallery), for: .touchUpInside)
        button.backgroundColor = UIColor.red
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.setTitle("Save to favorites", for: .normal)
        button.backgroundColor = UIColor.red
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleFavoriteButtonTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "Fon")

        let fullImageView = UIImageView(image: fullImage)
        fullImageView.contentMode = .scaleAspectFit
        fullImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullImageView)
        view.addSubview(saveButton)
        view.addSubview(favoriteButton)
        NSLayoutConstraint.activate([
            fullImageView.topAnchor.constraint(equalTo: view.topAnchor),
            fullImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 3),
            fullImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -3),
            fullImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),

            favoriteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -75),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            favoriteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            favoriteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        updateFavoriteButtonAppearance()
    }

    @objc func handleFavoriteButtonTap() {
        guard let image = fullImage else {
            print("fullImage is nil")
            return
        }

        if isImageInFavorites {
            removeFromFavorites(image)
        } else {
            addToFavorites(image)
        }
    }

    private func addToFavorites(_ image: UIImage) {
        guard !isImageInFavorites else {
            return
        }

        UserDefaultsManager.shared.saveImageToFavorites(image)
        isImageInFavorites = true
    }

    private func removeFromFavorites(_ image: UIImage) {
        guard let imageData = image.pngData() else {
            return
        }

        var favoritePaths = UserDefaultsManager.shared.getFavoritePaths()
        
        // Find the index of the image data in favoritePaths
        if let index = favoritePaths.firstIndex(where: { path in
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let pathImage = UIImage(data: data)
            else {
                return false
            }
            return pathImage.pngData() == imageData
        }) {
            do {
                try FileManager.default.removeItem(atPath: favoritePaths[index])
                favoritePaths.remove(at: index)
                UserDefaultsManager.shared.saveFavoritePaths(favoritePaths)
                
                isImageInFavorites = false
                
                // Dispatch UI update to the main thread
                DispatchQueue.main.async {
                    self.updateFavoriteButtonAppearance()
                }
                
                print("Image removed from favorites")
            } catch {
                print("Error removing image from file: \(error.localizedDescription)")
            }
        }
    }

    private func updateFavoriteButtonAppearance() {
        UIView.transition(with: favoriteButton, duration: 0, options: .transitionCrossDissolve, animations: {
            let title = self.isImageInFavorites ? "Remove from Favorites" : "Save to Favorites"
            self.favoriteButton.setTitle(title, for: .normal)
        }, completion: nil)
    }


    @objc func saveImageToGallery() {
        guard let imageToSave = fullImage else {
            print("fullImage is nil")
            return
        }
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: imageToSave)
        } completionHandler: { [weak self] success, error in
            if success {
                DispatchQueue.main.async {
                    self?.showSuccessAnimation()
                }
            } else if let error = error {
                print("Error saving image: \(error.localizedDescription)")
            }
        }
    }

    func showSuccessAnimation() {
        let successLabel = UILabel()
        successLabel.text = "Image Saved!"
        successLabel.textColor = UIColor(named: "LabelColor1")
        successLabel.font = UIFont(name: "AvenirNext-Heavy", size: 26)
        successLabel.textAlignment = .center
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(successLabel)

        NSLayoutConstraint.activate([
            successLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50)
        ])

        successLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)

        UIView.animate(withDuration: 0.2, animations: {
            successLabel.alpha = 1.0
            successLabel.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
                successLabel.alpha = 0.0
            }) { _ in
                successLabel.removeFromSuperview()
            }
        }
    }
}

extension UIImage {
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}
