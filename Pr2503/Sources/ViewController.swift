import UIKit
import SnapKit

class ViewController: UIViewController {
    private var isStarted = false
    private let globalQueue = DispatchQueue.global(qos: .background)
    private let mainQueue = DispatchQueue.main
    private var workItem: DispatchWorkItem?

    // MARK: - Outlets
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    private lazy var bruteForceButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(bruteForceButtonTapped), for: .touchUpInside)
        button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        button.setTitle("Brute Force", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var randomButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        button.addTarget(self, action: #selector(randomButtonTapped), for: .touchUpInside)
        button.setTitle("Get random password", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray6
        textField.placeholder = "Password"
        textField.textAlignment = .center
        textField.font = UIFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        textField.layer.cornerRadius = 8
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        label.text = "-"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
        setupView()
        setupHierarchy()
        setupLayout()
    }

    // MARK: - Setups

    private func setupView() {
        view.backgroundColor = .white
    }

    private func setupHierarchy() {
        view.addSubviews([
            passwordLabel,
            passwordTextField,
            randomButton,
            bruteForceButton,
            spinner
        ])
    }

    private func setupLayout() {
        passwordLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).dividedBy(1.3)
        }

        passwordTextField.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(90)
            make.top.equalTo(passwordLabel.snp.bottom).offset(40)
            make.height.equalTo(44)
        }

        randomButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
        }

        bruteForceButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(randomButton.snp.bottom).offset(157)
        }

        spinner.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(randomButton.snp.bottom).offset(60)
        }
    }

    // MARK: - Actions

    @objc private func bruteForceButtonTapped() {
        isStarted.toggle()
        let text = passwordTextField.text ?? ""

        if text != "" {
            if isStarted {
                spinner.startAnimating()
                bruteForceButton.setTitle("Stop", for: .normal)

                let newWorkItem = DispatchWorkItem { [weak self] in
                    self?.bruteForce(passwordToUnlock: text)
                }
                workItem = newWorkItem
                globalQueue.async(execute: newWorkItem)
            } else {
                workItem?.cancel()
                spinner.stopAnimating()
                bruteForceButton.setTitle("Brute Force", for: .normal)
            }
        } else {
            passwordLabel.text = "Введите пароль"
            isStarted = false
        }
    }

    @objc private func randomButtonTapped() {
        var password = ""
        passwordTextField.isSecureTextEntry = true

        for _ in 0..<Int.random(in: 3...4) {
            password.append(String(String().printable.randomElement() ?? Character("")))
        }
        passwordTextField.text = password
    }
}

// MARK: - Brute Force Methods

extension ViewController {
    private func bruteForce(passwordToUnlock: String) {
        let allowedCharacters: [String] = String().printable.map { String($0) }
        var password: String = ""

        while password != passwordToUnlock {
            if workItem?.isCancelled ?? false {
                break
            }
            password = generateBruteForce(password, fromArray: allowedCharacters)
            
            mainQueue.async { [weak self] in
                self?.passwordLabel.text = password
            }
        }

        mainQueue.async { [weak self] in
            if self?.workItem?.isCancelled ?? false {
                self?.passwordLabel.text = "Пароль \(passwordToUnlock) не взломан"
            } else {
                self?.isStarted = false
                self?.bruteForceButton.setTitle("Brute Force", for: .normal)
                self?.spinner.stopAnimating()
                self?.passwordLabel.text = "Пароль \(password) взломан"
                self?.passwordTextField.isSecureTextEntry = false
            }
        }
    }

    private func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }

    private func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index]) : Character("")
    }

    private func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
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
}
