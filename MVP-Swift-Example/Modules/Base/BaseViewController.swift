import UIKit
import MBProgressHUD
import Toast_Swift

class BaseViewController: UIViewController {

	var isKeyboardObserving: Bool { false }
	var isNavigationBarVisible: Bool { false }
	var navigationBarColor: UIColor? { .appGreen  }
	override var preferredStatusBarStyle: UIStatusBarStyle { navigationBarColor != nil ? .lightContent : .default}
	
	var basePresenter: BasePresenterProtocol? { nil }
	
	var textFieldSequence: [UITextField] { [] }
	lazy var textFieldToolbar: UIToolbar = {
		let toolbar = UIToolbar()
		toolbar.barStyle = .default
		toolbar.items = [
			UIBarButtonItem(image: UIImage(named: "arrow_up"), style: .plain, target: self, action: #selector(toolbarPrevButtonPressed)),
			UIBarButtonItem(image: UIImage(named: "arrow_down"), style: .plain, target: self, action: #selector(toolbarNextButtonPressed)),
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(toolbarDoneButtonPressed))
		]
		toolbar.items?.forEach { $0.tintColor = .appGreen }
		toolbar.sizeToFit()
		return toolbar
	}()
	
	@Inject private var userdefaultsManager: UserDefaultsManager
	
    override func viewDidLoad() {
        super.viewDidLoad()
		configureUI()
		basePresenter?.viewDidLoad()
		textFieldSequence.forEach { $0.inputAccessoryView = textFieldToolbar }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		basePresenter?.viewWillAppear(animated)
		if isKeyboardObserving {
			beginKeyboardObserving()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		basePresenter?.viewDidAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		basePresenter?.viewWillDisappear(animated)
		if isKeyboardObserving {
			endKeyboardObserving()
		}
	}
	
	func configureUI() {

	}
	
	// MARK: - Wait indicator
	
	private var progressHUD: MBProgressHUD?
	
	func showLoadingIndicator() {
		showLoadingIndicator(withGraceTime: 0.5)
	}
	
	func showLoadingIndicator(withGraceTime graceTime: Double) {
		guard progressHUD == nil else { return }
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        view.addSubview(hud)
        hud.graceTime = graceTime
        hud.show(animated: true)
        progressHUD = hud
	}
	
	func hideLoadingIndicator() {
		progressHUD?.hide(animated: true)
		progressHUD = nil
	}
	
	// MARK: - Keyboard Toolbar
	@objc private func toolbarNextButtonPressed(_ sender: Any) {
		guard let index = textFieldSequence.firstIndex(where: { $0.isEditing }), textFieldSequence.count - 1 > index else { return }
		textFieldSequence[index + 1].becomeFirstResponder()
	}
	
	@objc private func toolbarPrevButtonPressed(_ sender: Any) {
		guard let index = textFieldSequence.firstIndex(where: { $0.isEditing }), index > 0 else { return }
		textFieldSequence[index - 1].becomeFirstResponder()
	}
	
	@objc private func toolbarDoneButtonPressed(_ sender: Any) {
		view.endEditing(true)
	}
	
}

extension BaseViewController {
	
    public func showToast(title: String? = nil, msg: String, position: ToastPosition = .top) {
        view.makeToast(msg, duration: 1.5, position: position, title: title)
    }
    
	func showMessage(_ message: String, title: String? = nil, handler: (() -> Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in handler?() }))
		present(alert, animated: true)
	}
	
	func showError(_ message: String, handler: (() -> Void)? = nil) {
		showMessage(message, title: "Помилка", handler: handler)
	}
	
}

extension BaseViewController: UIGestureRecognizerDelegate { }
