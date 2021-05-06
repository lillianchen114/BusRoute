//
//  PELoadingButton.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/13/21.
//

import UIKit

enum ButtonState {
    case normal
    case loading
}

// A customized UIButton that would show a spinner when tapped
class PELoadingButton: UIButton {
    
    static let loadingButtonSize: CGFloat = 50.0
    
    // A private property that record current state, when changed, it will hide/show the loading indicator accordingly.
    // When the button is in loading state it will not allow user interaction
    private var currentState: ButtonState = .normal {
        didSet {
            switch currentState {
            case .normal:
                self.isEnabled = true
                activityIndicator.animateShowing(show: false)
                activityIndicator.stopAnimating()
            case .loading:
                self.isEnabled = false
                activityIndicator.animateShowing(show: true)
                activityIndicator.startAnimating()
            }
        }
    }
    
    // Activity indicator view
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.clipsToBounds = true
        return activityIndicator
    }()
    
    // Do some additional setup in the initialize method, the button's image will be hidden after it is tapped
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .systemBackground
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: Self.loadingButtonSize * 0.5, weight: .regular)
        self.setImage(UIImage(systemName: "bus.fill", withConfiguration: imageConfiguration), for: .normal)
        self.setImage(UIImage(), for: .disabled)
        addSubview(activityIndicator)
        activityIndicator.isHidden = true
        activityIndicator.alpha = 0
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Will only transform to loading state if current state is normal
    func userTapped() {
        if currentState == .normal {
            currentState = .loading
        }
    }
    
    // Public method to stop loading
    func finishedLoading() {
        if currentState == .loading {
            currentState = .normal
        }
    }
    
    // Use auto layout constraints to layout the button
    private func setupConstraints() {
        var layoutConstraints = [NSLayoutConstraint]()
        layoutConstraints.append(activityIndicator.heightAnchor.constraint(equalToConstant: Self.loadingButtonSize * 0.5))
        layoutConstraints.append(activityIndicator.widthAnchor.constraint(equalToConstant: Self.loadingButtonSize * 0.5))
        layoutConstraints.append(activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor))
        layoutConstraints.append(activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor))
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
}
