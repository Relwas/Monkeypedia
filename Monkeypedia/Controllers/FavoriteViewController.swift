import UIKit

@available(iOS 13.0, *)
class FavoriteViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var favoriteImages: [UIImage] {
        return UserDefaultsManager.shared.getFavoriteImages()
    }

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 24
        layout.minimumInteritemSpacing = 24
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    let emptyFavoritesLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorites yet."
        label.textAlignment = .center
        label.textColor = UIColor(named: "LabelColor1")
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        updateEmptyFavoritesLabel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "fon")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(named: "fon")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])

        view.addSubview(emptyFavoritesLabel)
        NSLayoutConstraint.activate([
            emptyFavoritesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFavoritesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        updateEmptyFavoritesLabel()
    }

    // MARK: - UICollectionViewDataSource

    private func updateEmptyFavoritesLabel() {
        emptyFavoritesLabel.isHidden = !favoriteImages.isEmpty
    }

    func addImageToFavorites(_ image: UIImage) {
        UserDefaultsManager.shared.saveImageToFavorites(image)
        collectionView.reloadData()
    }

    func removeImageFromFavorites(_ image: UIImage) {
        updateCollectionView()
    }

    func updateCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width)
        let cellHeight: CGFloat = 270
        return CGSize(width: cellWidth, height: cellHeight)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserDefaultsManager.shared.getFavoriteImages().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)

        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.image = UserDefaultsManager.shared.getFavoriteImages()[indexPath.item]

        cell.contentView.addSubview(imageView)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = favoriteImages[indexPath.item]

        let fullImageViewController = OneFullImageViewController()

        fullImageViewController.fullImage = selectedImage

        fullImageViewController.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(fullImageViewController, animated: true)
    }
}
