import UIKit
import AVFoundation

struct QuizQuestion {
    let imageURL: String
    let correctAnswer: String
    let incorrectAnswers: [String]
}

@available(iOS 13.0, *)
class QuizViewController: UIViewController {
    private var correctSoundPlayer: AVAudioPlayer?
    private var incorrectSoundPlayer: AVAudioPlayer?
    private var correctAnswersCount = 0
    private var quizQuestions: [QuizQuestion] = []
    private var currentQuestionIndex = 0
    private var musicPlayer: AVAudioPlayer?
    
    private let questionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "What kind of breed is this?"
        label.textColor = UIColor(named: "labelColor1")
        label.font = UIFont(name: "DevanagariSangamMN-Bold", size: 21.0)
        label.textAlignment = .center
        return label
    }()
    
    private let answerButton1 = UIButton()
    private let answerButton2 = UIButton()
    private let answerButton3 = UIButton()
    private let answerButton4 = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "fon")
        setupViews()
        loadQuizQuestions()
        showCurrentQuestion()
        
        loadSound(named: "correctSound", into: &correctSoundPlayer)
        loadSound(named: "incorrectSound", into: &incorrectSoundPlayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateVibrationSetting), name: Notification.Name("VibrationSettingChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSoundSetting), name: Notification.Name("SoundSettingChanged"), object: nil)
    }
    
    private func setupViews() {
        view.addSubview(questionImageView)
        view.addSubview(questionLabel)

        let stackView1 = createButtonStackView(with: [answerButton1, answerButton2])
        let stackView2 = createButtonStackView(with: [answerButton3, answerButton4])

        let buttonHeightConstant: CGFloat = view.bounds.height * 0.1 - 30

        NSLayoutConstraint.activate([
            questionImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.2 - 30),
            questionImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questionImageView.heightAnchor.constraint(equalToConstant: 250),
            questionLabel.topAnchor.constraint(equalTo: questionImageView.bottomAnchor, constant: 28),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        // Add stack views after activating constraints for imageView and questionLabel
        view.addSubview(stackView1)
        view.addSubview(stackView2)
        stackView1.translatesAutoresizingMaskIntoConstraints = false
        stackView2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView1.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            stackView1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView1.heightAnchor.constraint(equalToConstant: buttonHeightConstant * 2 + 10),
            stackView2.topAnchor.constraint(equalTo: stackView1.bottomAnchor, constant: 10),
            stackView2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView2.heightAnchor.constraint(equalToConstant: buttonHeightConstant * 2 + 10),
        ])
    }

    private func createButtonStackView(with buttons: [UIButton]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for button in buttons {
            button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 17.0)
            button.tintColor = UIColor.white
            button.layer.cornerRadius = 25
            button.backgroundColor = UIColor(named: "buttonColor1")
            button.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
        }

        return stackView
    }

    func createBlackBackgroundView() -> UIView {
        let blackView = UIView()
        blackView.translatesAutoresizingMaskIntoConstraints = false
        blackView.backgroundColor = .black
        blackView.layer.cornerRadius = 20
        blackView.layer.masksToBounds = true
        return blackView
    }
    
    private func loadSound(named fileName: String, into player: inout AVAudioPlayer?) {
        if let soundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: soundURL)
                player?.prepareToPlay()
            } catch let error {
                print("Error loading \(fileName) sound: \(error.localizedDescription)")
            }
        } else {
            print("Could not find \(fileName) sound file.")
        }
    }
    
    private func loadQuizQuestions() {
        if let breedsURL = Bundle.main.url(forResource: "Breeds", withExtension: nil),
           let breedNames = try? FileManager.default.contentsOfDirectory(atPath: breedsURL.path) {
            
            var questionCount = 0
            
            for breedName in breedNames {
                let correctAnswer = breedName
                let incorrectAnswers = breedNames.filter { $0 != correctAnswer }
                
                let shuffledIncorrectAnswers = incorrectAnswers.shuffled().prefix(3)
                
                if let imageNames = try? FileManager.default.contentsOfDirectory(atPath: "\(breedsURL.path)/\(breedName)") {
                    if let randomImageName = imageNames.shuffled().first {
                        let quizQuestion = QuizQuestion(
                            imageURL: "\(breedsURL.path)/\(breedName)/\(randomImageName)",
                            correctAnswer: correctAnswer,
                            incorrectAnswers: Array(shuffledIncorrectAnswers)
                        )
                        
                        quizQuestions.append(quizQuestion)
                        questionCount += 1
                        
                        if questionCount >= 15 {
                            break
                        }
                    }
                }
            }
        }
    }
    
    private func showCurrentQuestion() {
        guard currentQuestionIndex < quizQuestions.count else {
            return
        }

        let currentQuestion = quizQuestions[currentQuestionIndex]

        questionImageView.image = UIImage(named: currentQuestion.imageURL)
        questionLabel.text = "What kind of breed is this?"

        let shuffledAnswers = (currentQuestion.incorrectAnswers + [currentQuestion.correctAnswer]).shuffled()

        for (button, title) in zip([answerButton1, answerButton2, answerButton3, answerButton4], shuffledAnswers) {
            button.setTitle(title, for: .normal)
        }
    }
    
    private func moveToNextQuestion() {
        guard currentQuestionIndex < quizQuestions.count else {
            endQuiz()
            return
        }
        
        currentQuestionIndex += 1
        if currentQuestionIndex < quizQuestions.count {
            showCurrentQuestion()
        } else {
            endQuiz()
        }
    }
    
    private func endQuiz() {
        showResultController(correctAnswersCount: correctAnswersCount)
    }
    
    private func showResultController(correctAnswersCount: Int) {
        let resultController = ResultViewController(correctAnswers: correctAnswersCount)
        resultController.tryAgainCallback = { [weak self] in
            self?.startNewQuiz()
        }
        resultController.modalPresentationStyle = .fullScreen
        present(resultController, animated: true)
    }
    
    private func playMusic(musicName: String) {
        if UserDefaults.standard.bool(forKey: "SoundSetting"), let musicURL = Bundle.main.url(forResource: musicName, withExtension: "mp3") {
            do {
                musicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                musicPlayer?.prepareToPlay()
                musicPlayer?.play()
            } catch let error {
                print("Error playing music: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func updateSoundSetting() {
        if let isSoundEnabled = UserDefaults.standard.value(forKey: "SoundSetting") as? Bool {
            if isSoundEnabled {
                playMusic(musicName: "your_music_file_name")
            } else {
                stopMusic()
            }
        }
    }
    
    private func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }
    
    internal func startNewQuiz() {
        correctAnswersCount = 0
        currentQuestionIndex = 0
        quizQuestions.removeAll()
        loadQuizQuestions()
        showCurrentQuestion()
    }
    
    @objc func updateVibrationSetting(_ notification: Notification) {
        if let isVibrationEnabled = notification.userInfo?["isVibrationEnabled"] as? Bool {
            VibrationManager.shared.isVibrationEnabled = isVibrationEnabled
        }
    }
    
    @objc private func answerButtonTapped(_ sender: UIButton) {
        guard currentQuestionIndex < quizQuestions.count else {
            return
        }
        
        let isCorrectAnswer = sender.title(for: .normal) == quizQuestions[currentQuestionIndex].correctAnswer
        if isCorrectAnswer {
            correctAnswersCount += 1
            if UserDefaults.standard.bool(forKey: "SoundSetting") {
                correctSoundPlayer?.play()
            }
            sender.backgroundColor = .green
        } else {
            if UserDefaults.standard.bool(forKey: "SoundSetting") {
                incorrectSoundPlayer?.play()
            }
            sender.backgroundColor = .red
        }
        if VibrationManager.shared.isVibrationEnabled {
            isCorrectAnswer ? VibrationManager.shared.vibrateSuccess() : VibrationManager.shared.vibrateError()
        }
        for button in [answerButton1, answerButton2, answerButton3, answerButton4] {
            button.isUserInteractionEnabled = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.moveToNextQuestion()
            self.resetButtonColors()
            for button in [self.answerButton1, self.answerButton2, self.answerButton3, self.answerButton4] {
                button.isUserInteractionEnabled = true
            }
        }
    }
    
    private func resetButtonColors() {
        for button in [answerButton1, answerButton2, answerButton3, answerButton4] {
            button.backgroundColor = UIColor(named: "buttonColor1")
        }
    }
}

class VibrationManager {
    static let shared = VibrationManager()

    private let vibrationKey = "VibrationSetting"

    var isVibrationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isVibrationEnabled, forKey: vibrationKey)
            UserDefaults.standard.synchronize()
        }
    }

    private init() {
        self.isVibrationEnabled = UserDefaults.standard.bool(forKey: vibrationKey)
    }

    func getCurrentVibrationSetting() -> Bool {
        return isVibrationEnabled
    }

    func updateVibrationSetting(isEnabled: Bool) {
        isVibrationEnabled = isEnabled
    }

    func vibrateSuccess() {
        if isVibrationEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    func vibrateError() {
        if isVibrationEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}
