import UIKit
import SPConfetti
import AVFoundation

@available(iOS 13.0, *)
class ResultViewController: UIViewController {
    private var audioPlayer: AVAudioPlayer?

    private let correctAnswers: Int
    var completion: (() -> Void)?
    var tryAgainCallback: (() -> Void)?

    init(correctAnswers: Int) {
        self.correctAnswers = correctAnswers
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startConfettiAnimation()
        playResultSound()
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor(named: "fon")
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        configureUI()
        setupAudioPlayer()
    }

    private func configureUI() {
        // Image
        let congratsImageView = UIImageView(image: UIImage(named: "resultImageCon"))
        congratsImageView.contentMode = .scaleAspectFill
        congratsImageView.layer.cornerRadius = 12
        congratsImageView.clipsToBounds = true
        congratsImageView.layer.shadowColor = UIColor.gray.cgColor
        congratsImageView.layer.shadowOpacity = 0.5
        congratsImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        congratsImageView.layer.shadowRadius = 4
        congratsImageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(congratsImageView)

        // Congratulations label
        let congratulationsLabel = UILabel()
        congratulationsLabel.text = "Super job on your outstanding score!"
        congratulationsLabel.textAlignment = .center
        congratulationsLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        congratulationsLabel.textColor = UIColor(named: "labelColor1")
        congratulationsLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(congratulationsLabel)

        // Result label
        let resultLabel = UILabel()
        resultLabel.text = "Your score: \n \n \(correctAnswers)"
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 3
        resultLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        resultLabel.textColor = UIColor(named: "labelColor1")
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let yourScoreFont = UIFont(name: "AvenirNext-Regular", size: 18)
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: yourScoreFont as Any
        ]
        let attributedString = NSMutableAttributedString(string: resultLabel.text ?? "", attributes: scoreAttributes)
        resultLabel.attributedText = attributedString
        let scoreFont = UIFont(name: "AvenirNext-Bold", size: 50)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: scoreFont as Any
        ]

        // Apply the larger font size to the score number
        if let range = resultLabel.text?.range(of: "\(correctAnswers)") {
            attributedString.addAttributes(numberAttributes, range: NSRange(range, in: resultLabel.text ?? ""))
            resultLabel.attributedText = attributedString
        }

        view.addSubview(resultLabel)

        // Black background view behind the button
        let blackBackgroundView = UIView()
        blackBackgroundView.layer.cornerRadius = 35
        blackBackgroundView.backgroundColor = .red
        blackBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blackBackgroundView)

        // Button
        let homeButton = UIButton(type: .custom)
        homeButton.setTitle("Go Home", for: .normal)
        homeButton.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        homeButton.setTitleColor(UIColor(named: "LabelColor1"), for: .normal)
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        homeButton.contentMode = .scaleAspectFit
        homeButton.backgroundColor = UIColor(named: "buttonColor1")
        homeButton.layer.cornerRadius = 35
        if let homeImagee = UIImage(systemName: "house.fill")?.withRenderingMode(.alwaysTemplate) {
            homeButton.setImage(homeImagee, for: .normal)
            homeButton.tintColor = .white
           }
        homeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(homeButton)

        // Constraints
        NSLayoutConstraint.activate([
            congratsImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            congratsImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            congratsImageView.widthAnchor.constraint(equalToConstant: 300),
            congratsImageView.heightAnchor.constraint(equalToConstant: 290),

            congratulationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            congratulationsLabel.topAnchor.constraint(equalTo: congratsImageView.bottomAnchor, constant: 0),

            resultLabel.topAnchor.constraint(equalTo: congratulationsLabel.bottomAnchor, constant: 20),
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            homeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            homeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            homeButton.widthAnchor.constraint(equalToConstant: 290),
            homeButton.heightAnchor.constraint(equalToConstant: 70),

            blackBackgroundView.leadingAnchor.constraint(equalTo: homeButton.leadingAnchor, constant: 3),
            blackBackgroundView.trailingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: -3),
            blackBackgroundView.topAnchor.constraint(equalTo: homeButton.topAnchor, constant: 3),
            blackBackgroundView.bottomAnchor.constraint(equalTo: homeButton.bottomAnchor, constant: -3),
        ])
    }

    //MARK: Private
    private func playResultSound() {
        if UserDefaults.standard.bool(forKey: "SoundSetting") {
            audioPlayer?.play()
        }
    }

    private func setupAudioPlayer() {
        if let soundURL = Bundle.main.url(forResource: "ResultSound", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading result sound file: \(error.localizedDescription)")
            }
        } else {
            print("Result Sound file not found.")
        }
    }

    private func startConfettiAnimation() {
        SPConfetti.startAnimating(.fullWidthToDown, particles: [.star])
    }
    private func stopConfettiAnimation() {
        SPConfetti.stopAnimating()
    }
    @objc private func homeButtonTapped() {
        stopConfettiAnimation()
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
    }
}
