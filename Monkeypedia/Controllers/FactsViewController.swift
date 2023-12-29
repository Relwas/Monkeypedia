import UIKit
import FLAnimatedImage

class FactsViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "fon")
        setupScrollView()
    }
    
    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor(named: "fon")
        view.addSubview(scrollView)
        
        let margin: CGFloat = 10
        setupTitleLabel(withMargin: margin)
        setupMonkeyImageView(withMargin: margin)
        setupLargeTextLabel(withMargin: margin)
        setupGifImageView(withMargin: margin)
    }
    
    private func setupTitleLabel(withMargin margin: CGFloat) {
        let titleLabel = UILabel(frame: CGRect(x: margin + 10, y: margin, width: view.bounds.width - 2 * margin, height: 40))
        titleLabel.text = "Monkey facts"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        scrollView.addSubview(titleLabel)
    }
    
    private func setupMonkeyImageView(withMargin margin: CGFloat) {
        let monkeyImageView = UIImageView(frame: CGRect(x: margin, y: scrollView.subviews.last?.frame.maxY ?? margin, width: view.bounds.width - 2 * margin, height: 270))
        monkeyImageView.image = UIImage(named: "monkeyFact")
        monkeyImageView.layer.cornerRadius = 10
        monkeyImageView.contentMode = .scaleAspectFill
        monkeyImageView.clipsToBounds = true
        scrollView.addSubview(monkeyImageView)
    }
    
    private func setupLargeTextLabel(withMargin margin: CGFloat) {
        let largeTextLabel = UILabel()
        largeTextLabel.numberOfLines = 0
        largeTextLabel.textAlignment = .justified
        largeTextLabel.lineBreakMode = .byWordWrapping
        largeTextLabel.text = Constants.largeText
        largeTextLabel.font = UIFont(name: "Avenir-Book", size: 19)
        let size = largeTextLabel.sizeThatFits(CGSize(width: view.bounds.width - 2 * margin, height: CGFloat.greatestFiniteMagnitude))
        largeTextLabel.frame = CGRect(x: margin, y: scrollView.subviews.last?.frame.maxY ?? margin, width: view.bounds.width - 2 * margin, height: size.height)
        scrollView.addSubview(largeTextLabel)
    }
    
    private func setupGifImageView(withMargin margin: CGFloat) {
        if let gifURL = Bundle.main.url(forResource: "MonkeyGif", withExtension: "gif"),
           let gifData = try? Data(contentsOf: gifURL) {
            
            let gifImageView = FLAnimatedImageView(frame: CGRect(x: margin, y: scrollView.subviews.last?.frame.maxY ?? margin, width: view.bounds.width - 2 * margin, height: 270))
            gifImageView.animatedImage = FLAnimatedImage(animatedGIFData: gifData)
            gifImageView.layer.cornerRadius = 10
            gifImageView.clipsToBounds = true
            scrollView.addSubview(gifImageView)
            
            setupAdditionalTextLabel(withMargin: margin, below: gifImageView)
        }
    }
    
    private func setupAdditionalTextLabel(withMargin margin: CGFloat, below view: UIView) {
        let additionalTextLabel = UILabel()
        additionalTextLabel.numberOfLines = 0
        additionalTextLabel.textAlignment = .justified
        additionalTextLabel.lineBreakMode = .byWordWrapping
        additionalTextLabel.text = Constants.additionalText
        additionalTextLabel.font = UIFont(name: "Avenir-Book", size: 17)
        let size = additionalTextLabel.sizeThatFits(CGSize(width: view.bounds.width - 2 * margin, height: CGFloat.greatestFiniteMagnitude))
        additionalTextLabel.frame = CGRect(x: margin, y: view.frame.maxY + margin * 2, width: view.bounds.width - 2 * margin, height: size.height + 50)
        scrollView.addSubview(additionalTextLabel)
        scrollView.contentSize = CGSize(width: view.bounds.width, height: additionalTextLabel.frame.maxY + margin * 2 + 40)
    }
}


private struct Constants {
    static let largeText = """
            
              Monkeys are intelligent, social animals. They are members of the primate group of mammals, which includes apes and humans. There are approximately 200 different species of monkeys. Scientists classify them as old world monkeys or new world monkeys. Baboons, drills, mandrills, macaques, guenons, langurs, and colobus monkeys are examples of old world monkeys. Keep reading to learn more facts about monkeys. Monkeys frequently have smiles on their faces, leaving onlookers to wonder what they are up to. Like humans, monkeys have a distinct set of fingerprints of their own. This is really intriguing and provides more evidence that all primates, including ours, are closely connected to one another.
              Monkey, any one of the Old World monkeys or the New World monkeys, two subspecies of tropical anthropoid primates. The majority of species are diurnal and tropical or subtropical. The majority of species leap from tree to tree utilising all four limbs. They can stand and sit straight. Instead of swinging arm in arm like the apes, most species run along branches. Monkeys are highly social omnivores that live in groups of up to several hundred people under the leadership of an elderly male.
            
            Monkey Facts:
            
             *Monkey is a familiar name for a group of primate mammals
             *They live both on the ground and in the trees
             *Most monkeys have tails
             *Apes are not monkeys
             *Groups of monkeys are known as a mission, tribe, or troop
             *They have to stay away from animals like big snake, crocodiles, and leopards.
            
            """
    static let additionalText = """
    Fun facts about Monkeys:

    *Just like young children, monkeys have a high IQ
*Illnesses can be spread to people by monkeys
    *The owl monkey's more enduring moniker is the "night monkey"
    *Monkeys and apes are not the same but are related
*To interact with one another, monkeys engage in grooming rituals
    *Monkeys as pets are popular exotic animals
    *All monkeys have opposable thumbs
    *The common cold does not affect monkeys.
"""
}
