import UIKit
import SnapKit

class ViewController: UIViewController {

    // MARK: - Outlets

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(onBut), for: .touchUpInside)
        button.setTitle("Button", for: .normal)
        return button
    }()
    
    var isBlack: Bool = false {
        didSet {
            if isBlack {
                view.backgroundColor = .black
            } else {
                view.backgroundColor = .white
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
        bruteForce(passwordToUnlock: "1!gr")
    }

    // MARK: - Setups

    private func setupView() {
        view.backgroundColor = .white
    }

    private func setupHierarchy() {
        view.addSubview(button)
    }

    private func setupLayout() {
        button.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
        }
    }

    // MARK: - Actions

    @objc private func onBut() {
        isBlack.toggle()
    }

    // MARK: - Methods

    func bruteForce(passwordToUnlock: String) {
        let allowedCharacters: [String] = String().printable.map { String($0) }
        var password: String = ""

        while password != passwordToUnlock {
            password = generateBruteForce(password, fromArray: allowedCharacters)
            print(password)
        }
        print(password)
    }
}

func indexOf(character: Character, _ array: [String]) -> Int {
    return array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    return index < array.count ? Character(array[index]) : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string

    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    } else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }
    return str
}
