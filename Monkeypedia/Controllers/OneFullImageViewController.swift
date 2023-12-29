import UIKit
import Photos

@available(iOS 13.0, *)
class OneFullImageViewController: UIViewController {
    
    // MARK: - Properties
    
    var fullImage: UIImage? {
        didSet {
            updateImageFavoritesStatus()
        }
    }
    
    var isImageInFavorites: Bool = false {
        didSet {
            updateFavoriteButtonAppearance()
        }
    }
    
    // MARK: - UI Elements
    
    private let backView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private let saveButtonBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        return view
    }()
    
    private let favoriteButtonBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        return view
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save to Gallery", for: .normal)
        button.addTarget(self, action: #selector(saveImageToGallery), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(named: "buttonColor1")
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        if let heartImage = UIImage(systemName: "square.and.arrow.down.fill")?.withRenderingMode(.alwaysTemplate) {
               button.setImage(heartImage, for: .normal)
               button.tintColor = .white
           }    
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        return button
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save to Favorites", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(named: "buttonColor1")
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(handleFavoriteButtonTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        if let heartImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate) {
               button.setImage(heartImage, for: .normal)
               button.tintColor = .red
           }

        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateImageFavoritesStatus()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(named: "fon")

              let fullImageView = UIImageView(image: fullImage)
              fullImageView.contentMode = .scaleAspectFill
              fullImageView.layer.cornerRadius = 20
              fullImageView.clipsToBounds = true
              fullImageView.translatesAutoresizingMaskIntoConstraints = false

              view.addSubview(backView)
              view.addSubview(saveButtonBackgroundView)
              view.addSubview(saveButton)
              view.addSubview(favoriteButtonBackgroundView)
              view.addSubview(favoriteButton)
              view.addSubview(fullImageView)
        
        NSLayoutConstraint.activate([
                backView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
                backView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                backView.heightAnchor.constraint(equalToConstant: 280),
                backView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                fullImageView.topAnchor.constraint(equalTo: backView.topAnchor, constant: -5),
                fullImageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 5),
                fullImageView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: 5),
                fullImageView.heightAnchor.constraint(equalToConstant: 280),

                saveButtonBackgroundView.bottomAnchor.constraint(equalTo: favoriteButtonBackgroundView.topAnchor, constant: -30),
                saveButtonBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                saveButtonBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                saveButtonBackgroundView.heightAnchor.constraint(equalToConstant: 50),

                saveButton.leadingAnchor.constraint(equalTo: saveButtonBackgroundView.leadingAnchor, constant: 5),
                saveButton.trailingAnchor.constraint(equalTo: saveButtonBackgroundView.trailingAnchor),
                saveButton.topAnchor.constraint(equalTo: saveButtonBackgroundView.topAnchor, constant: -5),
                saveButton.bottomAnchor.constraint(equalTo: saveButtonBackgroundView.bottomAnchor, constant: -5),

                favoriteButtonBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -75),
                favoriteButtonBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                favoriteButtonBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                favoriteButtonBackgroundView.heightAnchor.constraint(equalToConstant: 50),

                favoriteButton.leadingAnchor.constraint(equalTo: favoriteButtonBackgroundView.leadingAnchor, constant: 5),
                favoriteButton.trailingAnchor.constraint(equalTo: favoriteButtonBackgroundView.trailingAnchor),
                favoriteButton.topAnchor.constraint(equalTo: favoriteButtonBackgroundView.topAnchor, constant: -5),
                favoriteButton.bottomAnchor.constraint(equalTo: favoriteButtonBackgroundView.bottomAnchor, constant: -5),
            ])

            updateFavoriteButtonAppearance()
        
    }
    
    // MARK: - Image Favorites
    
    private func updateImageFavoritesStatus() {
        isImageInFavorites = UserDefaultsManager.shared.isImageInFavorites(fullImage)
    }
    
    private func addToFavorites(_ image: UIImage) {
        guard !isImageInFavorites else { return }
        UserDefaultsManager.shared.saveImageToFavorites(image)
        isImageInFavorites = true
    }
    
    private func removeFromFavorites(_ image: UIImage) {
        guard let imageData = image.pngData() else { return }

        var favoritePaths = UserDefaultsManager.shared.getFavoritePaths()

        if let index = favoritePaths.firstIndex(where: { path in
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let pathImage = UIImage(data: data) else {
                return false
            }
            return pathImage.pngData() == imageData
        }) {
            do {
                try FileManager.default.removeItem(atPath: favoritePaths[index])
                favoritePaths.remove(at: index)
                UserDefaultsManager.shared.saveFavoritePaths(favoritePaths)

                isImageInFavorites = false
                updateFavoriteButtonAppearance()

                print("Image removed from favorites")
            } catch {
                print("Error removing image from file: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - UI Updates
    
    private func updateFavoriteButtonAppearance() {
        let title = isImageInFavorites ? "Remove from Favorites" : "Save to Favorites"
        favoriteButton.setTitle(title, for: .normal)
    }

    private func updateFavoriteButtonAppearanceWithAnimation() {
        let title = isImageInFavorites ? "Remove from Favorites" : "Save to Favorites"

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {
            self.favoriteButton.setTitle(title, for: .normal)
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func handleFavoriteButtonTap() {
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
    
    @objc private func saveImageToGallery() {
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
    
    // MARK: - Animations
    
    private func showSuccessAnimation() {
        let successLabel = UILabel()
        successLabel.text = "Image Saved!"
        successLabel.textColor = UIColor(named: "LabelColor1")
        successLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 22)
        successLabel.textAlignment = .center
        successLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(successLabel)
        
        NSLayoutConstraint.activate([
            successLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50)
        ])
        
        successLabel.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        successLabel.alpha = 0.0
        
        UIView.animate(withDuration: 0.3, animations: {
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
    
    private func animateButtonPress(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            button.imageView?.transform = CGAffineTransform(rotationAngle: .pi / 4.0)
            button.backgroundColor = UIColor(named: "ButtonPressedColor")
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
                button.imageView?.transform = .identity
                button.backgroundColor = UIColor(named: "buttonColor1")
            }
        }
    }
}
// MARK: - UIImage Extension

extension UIImage {
    func fixOrientation() -> UIImage {
        guard imageOrientation != .up else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        if let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            UIGraphicsEndImageContext()
            return self
        }
    }
    
}
