import UIKit

@available(iOS 13.0, *)
class GameViewController: UIViewController {
    
    private let verticalStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "fon")
        title = "Games"

        configureVerticalStackView()

        let quizButton = createGameButton(title: "Quiz", backgroundColor: UIColor(named: "buttonColor1")!, action: #selector(quizButtonTapped))
        let puzzleButton = createGameButton(title: "Puzzle", backgroundColor: UIColor(named: "buttonColor1")!, action: #selector(puzzleButtonTapped))

        verticalStackView.addArrangedSubview(quizButton)
        verticalStackView.addArrangedSubview(puzzleButton)

        view.addSubview(verticalStackView)

        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            verticalStackView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }

    @objc
    private func puzzleButtonTapped() {
        let puzzleVC = PuzzleViewController()
        puzzleVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(puzzleVC, animated: true)
    }

    @objc
    private func quizButtonTapped() {
        let quizVC = QuizViewController()
        quizVC.modalPresentationStyle = .fullScreen
        present(quizVC, animated: true)
    }

    private func createGameButton(title: String, backgroundColor: UIColor, action: Selector?) -> UIView {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 28)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor

        button.layer.cornerRadius =  85
        button.layer.masksToBounds = true

        button.addTarget(self, action: action!, for: .touchUpInside)

        let backgroundView = UIView()
        backgroundView.backgroundColor = .lightGray
        backgroundView.layer.cornerRadius = 85
        backgroundView.layer.masksToBounds = true
        backgroundView.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 5),
            button.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: 5),
            button.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: -5),
            button.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -5)
        ])

        return backgroundView
    }

    private func configureVerticalStackView() {
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 20
        verticalStackView.distribution = .fillEqually
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    }
}
