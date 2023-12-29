import UIKit

@available(iOS 13.0, *)
class PuzzleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //MARK: Public Properties
    private var timer: Timer?
    private var timeRemaining: Int = 40 // seconds
    private var timerLabel: UILabel!
    let gridSize = 4
    var puzzlePieces: [UIImage] = []
    var collectionView: UICollectionView!
    var selectedPieceIndex: IndexPath?
    var emptyPieceIndex: IndexPath?

    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "fon")

        for i in 1...(gridSize * gridSize) {
            let imageName = "Image\(i)"
            if let image = UIImage(named: imageName, in: Bundle.main, with: nil) {
                puzzlePieces.append(image)
            }
        }

        shufflePuzzlePieces()

        let cellSize = (view.bounds.width - 30 - CGFloat(gridSize - 1) * 5) / CGFloat(gridSize)

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: cellSize, height: cellSize)

        let puzzleBackground = UIView()
        puzzleBackground.backgroundColor = UIColor(named: "buttonColor1")
        puzzleBackground.layer.cornerRadius = 15
        puzzleBackground.clipsToBounds = true
        view.addSubview(puzzleBackground)

        // Create a collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PuzzleCell.self, forCellWithReuseIdentifier: PuzzleCell.identifier)
        collectionView.backgroundColor = .clear
        puzzleBackground.addSubview(collectionView)

        let totalGridHeight = CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * 5
        let backgroundHeight = totalGridHeight + 15

        timerLabel = UILabel()
        timerLabel.textColor = UIColor(named: "labelColor1")
        timerLabel.font = UIFont(name: "DevanagariSangamMN-Bold", size: 22)
        timerLabel.textAlignment = .center
        timerLabel.text = "Time: \(timeRemaining) s"
        view.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        puzzleBackground.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            puzzleBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            puzzleBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            puzzleBackground.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            puzzleBackground.heightAnchor.constraint(equalToConstant: backgroundHeight),
            timerLabel.bottomAnchor.constraint(equalTo: puzzleBackground.topAnchor, constant: -20),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.centerXAnchor.constraint(equalTo: puzzleBackground.centerXAnchor),
            collectionView.centerYAnchor.constraint(equalTo: puzzleBackground.centerYAnchor),
            collectionView.widthAnchor.constraint(equalTo: puzzleBackground.widthAnchor, constant: -15),
            collectionView.heightAnchor.constraint(equalTo: puzzleBackground.heightAnchor, constant: -15)
        ])

        collectionView.layer.cornerRadius = 10
        collectionView.layer.masksToBounds = true
        startTimer()
    }

    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridSize * gridSize
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PuzzleCell.identifier, for: indexPath) as! PuzzleCell
        cell.imageView.image = puzzlePieces[indexPath.item]
        return cell
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc private func updateTimer() {
        timeRemaining -= 1
        timerLabel.text = "Time: \(timeRemaining) s"

        if timeRemaining <= 0 {
            timer?.invalidate()
            timer = nil
            if !isPuzzleSolved() {
                showTimeUpAlert()
            }
        }
    }

    func showTimeUpAlert() {
        let alert = UIAlertController(title: "Time's Up!", message: "Your time is over. Would you like to try again?", preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { [self] _ in
            resetGame()
        }
        alert.addAction(tryAgainAction)
        present(alert, animated: true, completion: nil)
    }

    func resetGame() {
        shufflePuzzlePieces()
        collectionView.reloadData()
        resetVisualChanges()

        timeRemaining = 40
        timerLabel.text = "Time: \(timeRemaining) s"

        timer?.invalidate()
        timer = nil

        if !isPuzzleSolved() {
            startTimer()
        }
    }

    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handlePuzzlePieceTap(at: indexPath)
    }

    //MARK: Public Methods
    func resetVisualChanges() {
        collectionView.visibleCells.forEach { cell in
            if let puzzleCell = cell as? PuzzleCell {
                UIView.animate(withDuration: 0.3) {
                    puzzleCell.imageView.alpha = 1.0
                }
            }
        }

        collectionView.visibleCells.forEach { cell in
            if let puzzleCell = cell as? PuzzleCell {
                UIView.animate(withDuration: 0.3) {
                    puzzleCell.imageView.alpha = 1.0
                    puzzleCell.imageView.transform = CGAffineTransform.identity
                }
            }
        }
    }

    private func startTimerWithoutUpdate() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    func handlePuzzlePieceTap(at indexPath: IndexPath) {
        if let selectedPieceIndex = selectedPieceIndex {
            swapPuzzlePieces(from: selectedPieceIndex, to: indexPath)
            self.selectedPieceIndex = nil

            if isPuzzleSolved() {
                timer?.invalidate()
                showRestartAlert()
            }
        } else {
            selectedPieceIndex = indexPath

            if let cell = collectionView.cellForItem(at: indexPath) as? PuzzleCell {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.imageView.alpha = 0.9
                    cell.imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            }
        }
    }

    func shufflePuzzlePieces() {
        var shuffledPieces = puzzlePieces
        for i in stride(from: shuffledPieces.count - 1, to: 0, by: -1) {
            let j = Int(arc4random_uniform(UInt32(i + 1)))
            shuffledPieces.swapAt(i, j)
        }
        puzzlePieces = shuffledPieces
    }

    func isPuzzleSolved() -> Bool {
        let correctOrder = (1...(gridSize * gridSize)).map { UIImage(named: "Image\($0)")! }
        return puzzlePieces.elementsEqual(correctOrder, by: { $0.isEqual($1) })
    }

    func showRestartAlert() {
        let alert = UIAlertController(title: "Well done!", message: "You have solved the puzzle, It's amazing!", preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Play again", style: .default) { [self] _ in
            self.shufflePuzzlePieces()
            self.collectionView.reloadData()
            self.resetVisualChanges()
            self.resetTimer()
        }
        alert.addAction(restartAction)
        present(alert, animated: true, completion: nil)
    }

    func resetTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 40
        timerLabel.text = "Time: \(timeRemaining) s"

        if !isPuzzleSolved() {
            startTimerWithoutUpdate()
        }
    }

    func swapPuzzlePieces(from index1: IndexPath, to index2: IndexPath) {
        puzzlePieces.swapAt(index1.item, index2.item)
        resetVisualChanges()
        collectionView.reloadItems(at: [index1, index2])
    }
}

class PuzzleCell: UICollectionViewCell {
    static let identifier = "PuzzleCell"
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageView()
    }

    private func setupImageView() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
