import UIKit

@available(iOS 13.0, *)
class BreedsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var breedNames: [String] {
        guard let breedsPath = Bundle.main.path(forResource: "Breeds", ofType: nil) else {
            return []
        }
        do {
            return try FileManager.default.contentsOfDirectory(atPath: breedsPath)
        } catch {
            return []
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "fon")

        // Inside viewDidLoad
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0

        // Set up the collection view
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(named: "fon")
        collectionView.register(BreedCollectionViewCell.self, forCellWithReuseIdentifier: BreedCollectionViewCell.reuseIdentifier)
        view.addSubview(collectionView)

        // Set up constraints (assuming you are not using Auto Layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return breedNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedCollectionViewCell.reuseIdentifier, for: indexPath) as! BreedCollectionViewCell
        cell.configure(with: breedNames[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let padding: CGFloat = 0
        return UIEdgeInsets(top: 0, left: padding, bottom: padding, right: padding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let padding: CGFloat = 0

        if indexPath.item % 3 == 0 {
            return CGSize(width: collectionViewWidth - 2 * padding, height: 250)
        } else {
            let availableWidth = collectionViewWidth - 2 * padding
            let cellWidth = (availableWidth - padding) / 2
            let cellHeight = 150
            let isLastItem = indexPath.item == breedNames.count - 0
            return CGSize(width: cellWidth, height: isLastItem ? CGFloat(cellHeight + 50) : CGFloat(cellHeight))
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBreed = breedNames[indexPath.item]
        let breedDetailVC = BreedsFullViewController(breedName: selectedBreed)
        breedDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(breedDetailVC, animated: true)
    }
}

@available(iOS 13.0, *)
class BreedCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "cell"

    let imageView = UIImageView()
    let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // Configure imageView
        imageView.backgroundColor = .systemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)

        // Configure nameLabel
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        nameLabel.textColor = .white
        nameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        nameLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        imageView.addSubview(nameLabel)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.layer.shadowColor = UIColor.gray.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.addSubview(imageView)

        // Set up constraints using Auto Layout
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let nameLabelHeightConstraint = nameLabel.heightAnchor.constraint(equalToConstant: 40)
        nameLabelHeightConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: imageView.bottomAnchor)
        ])
    }

    func configure(with breedName: String) {
        if let image = getFirstImageForBreed(breedName) {
            imageView.image = image
        }
        nameLabel.text = breedName
    }

    func getFirstImageForBreed(_ breedName: String) -> UIImage? {
        guard let breedPath = Bundle.main.path(forResource: "Breeds/\(breedName)", ofType: nil),
              let imageFileName = try? FileManager.default.contentsOfDirectory(atPath: breedPath).first,
              let imagePath = Bundle.main.path(forResource: "Breeds/\(breedName)/\(imageFileName)", ofType: nil) else {
            return nil
        }
        return UIImage(contentsOfFile: imagePath)
    }
}
