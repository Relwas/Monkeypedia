import UIKit

class BreedsFullViewController: UIViewController {
    // MARK: - Properties

    private let breedName: String
    private var collectionView: UICollectionView!
    private var breedImages: [UIImage] = []

    // MARK: - Initialization

    init(breedName: String) {
        self.breedName = breedName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchBreedImages()
        setupConstraints()
    }

    // MARK: - Private Methods

    private func setupUI() {
        view.backgroundColor = UIColor(named: "fon")
        title = breedName

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 10

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BreedDetailImageCell.self, forCellWithReuseIdentifier: BreedDetailImageCell.reuseIdentifier)
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
    }

    private func fetchBreedImages() {
        breedImages = getImagesForBreed(breedName)
    }

    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func getImagesForBreed(_ breedName: String) -> [UIImage] {
        var images: [UIImage] = []

        guard let breedPath = Bundle.main.path(forResource: "Breeds/\(breedName)", ofType: nil),
              let imageFileNames = try? FileManager.default.contentsOfDirectory(atPath: breedPath) else {
            print("Error: Could not find images for breed \(breedName)")
            return images
        }

        for imageName in imageFileNames {
            if let imagePath = Bundle.main.path(forResource: "Breeds/\(breedName)/\(imageName)", ofType: nil),
               let image = UIImage(contentsOfFile: imagePath) {
                images.append(image)
            } else {
                print("Error: Could not load image \(imageName) for breed \(breedName)")
            }
        }
        return images
    }
}
// MARK: - UICollectionViewDataSource

extension BreedsFullViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return breedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedDetailImageCell.reuseIdentifier, for: indexPath) as! BreedDetailImageCell
        cell.configure(with: breedImages[indexPath.item], delegate: self)
        return cell
    }
}
// MARK: - UICollectionViewDelegateFlowLayout

extension BreedsFullViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.frame.width
        let cellWidth = collectionViewWidth - 22
        let cellHeight: CGFloat = 330
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - BreedDetailImageCellDelegate

@available(iOS 13.0, *)
extension BreedsFullViewController: BreedDetailImageCellDelegate {
    func handleImageTap(_ cell: BreedDetailImageCell) {
        guard let tappedIndexPath = collectionView.indexPath(for: cell) else { return }
        let fullImageBreedVC = OneFullImageViewController()
        fullImageBreedVC.fullImage = breedImages[tappedIndexPath.item]
        navigationController?.pushViewController(fullImageBreedVC, animated: true)
    }
}

// MARK: - BreedDetailImageCell

class BreedDetailImageCell: UICollectionViewCell {
    static let reuseIdentifier = "BreedDetailImageCell"

    private let imageView = UIImageView()
    private let shadowView = UIView()
    private let heartButton = UIButton(type: .custom)
    private var isFavorite = false
    weak var delegate: BreedDetailImageCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func configure(with image: UIImage, delegate: BreedDetailImageCellDelegate) {
        imageView.image = image
        self.delegate = delegate
    }

    private func setupViews() {
        shadowView.clipsToBounds = false
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true

        contentView.addSubview(shadowView)
        shadowView.addSubview(imageView)

        shadowView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: contentView.topAnchor),
            shadowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: shadowView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }

    @objc private func handleImageTap() {
        delegate?.handleImageTap(self)
    }
}

// MARK: - BreedDetailImageCellDelegate

protocol BreedDetailImageCellDelegate: AnyObject {
    func handleImageTap(_ cell: BreedDetailImageCell)
}
