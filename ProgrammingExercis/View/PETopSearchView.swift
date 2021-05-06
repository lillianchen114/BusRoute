//
//  PETopSearchView.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/11/21.
//

import UIKit

enum LocationType {
    case from
    case to
}

// Delegate declaration
protocol PETopSearchViewDelegate: class {
    func startSearchWithText(keywords: String)
    func dismissSearchResult()
}

// Custom View built for allow user to choose start and end location
class PETopSearchView: UIView {
    
    // Constants for laying out subviews
    static private let searchbarHeight: CGFloat = 32.0
    static private let searchbarFont: CGFloat = 16.0
    static private let labelWidth: CGFloat = 42.0
    static private let labelHeight: CGFloat = 20.0
    static private let searchbarRightSidePadding: CGFloat = 20.0
    static let searchViewHeight: CGFloat = 88.0
    
    // Property used to track the current selection of start or end location
    private(set) var currentSelection: LocationType?
    // searchDelegate property, use weak to avoid retain cycle
    weak var searchDelegate: PETopSearchViewDelegate?
    
    // Starting location search bar
    private var fromSearchbar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.placeholder = "Search a Staring Location"
        searchbar.searchTextField.font = .systemFont(ofSize: PETopSearchView.searchbarFont)
        searchbar.searchTextField.backgroundColor = .systemBackground
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        searchbar.searchTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        searchbar.layer.cornerRadius = PETopSearchView.searchViewHeight / 2.0
        searchbar.layer.masksToBounds = false
        return searchbar
    }()
    
    // End location search bar
    private var toSearchbar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.placeholder = "Search a Destination"
        searchbar.searchTextField.font = .systemFont(ofSize: PETopSearchView.searchbarFont)
        searchbar.searchTextField.backgroundColor = .systemBackground
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        searchbar.searchTextField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        searchbar.layer.cornerRadius = PETopSearchView.searchViewHeight / 2.0
        searchbar.layer.masksToBounds = false
        return searchbar
    }()
    
    // Label indicating the 'from' location
    private var fromLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: PETopSearchView.searchbarFont)
        label.text = "From"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Label indicating the 'to' location
    private var toLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: PETopSearchView.searchbarFont)
        label.text = "To"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Override the default initializer to do some additional setup (adding the subviews and layout them using autolayout)
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = UIColor.systemBackground
        fromSearchbar.delegate = self
        toSearchbar.delegate = self
        addSubview(fromLabel)
        addSubview(toLabel)
        addSubview(fromSearchbar)
        addSubview(toSearchbar)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Public method that would replace the current selected location with new location
    func updateLocationName(name: String, selection: LocationType?) {
        var locationType = selection
        if locationType == nil {
            locationType = currentSelection
        }
        if let selection = locationType {
            switch selection {
            case .from:
                fromSearchbar.text = name
            case .to:
                toSearchbar.text = name
            }
        }
    }
    
    // Public method that would hide the keyboard and end editing on the current selected search bar
    func stopEditing() {
        if let selection = currentSelection {
            switch selection {
            case .from:
                fromSearchbar.endEditing(true)
            case .to:
                toSearchbar.endEditing(true)
            }
            currentSelection = nil
        }
    }
    
    // Layout subviews using autolayout constraints
    private func setupConstraints() {
        var layoutConstraints = [NSLayoutConstraint]()
        // Labels
        layoutConstraints.append(fromLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 2.0))
        layoutConstraints.append(fromLabel.widthAnchor.constraint(equalToConstant: Self.labelWidth))
        layoutConstraints.append(fromLabel.heightAnchor.constraint(equalToConstant: Self.labelHeight))
        layoutConstraints.append(fromLabel.centerYAnchor.constraint(equalTo: fromSearchbar.centerYAnchor))
        
        layoutConstraints.append(toLabel.leadingAnchor.constraint(equalTo: fromLabel.leadingAnchor))
        layoutConstraints.append(toLabel.widthAnchor.constraint(equalToConstant: Self.labelWidth))
        layoutConstraints.append(toLabel.heightAnchor.constraint(equalToConstant: Self.labelHeight))
        layoutConstraints.append(toLabel.centerYAnchor.constraint(equalTo: toSearchbar.centerYAnchor))
        // Search bars
        
        layoutConstraints.append(fromSearchbar.topAnchor.constraint(equalTo: self.topAnchor, constant: UIView.defaultSystemSpacing + UIApplication.shared.topPadding))
        layoutConstraints.append(fromSearchbar.leadingAnchor.constraint(equalTo: fromLabel.trailingAnchor, constant: UIView.defaultSystemSpacing))
        layoutConstraints.append(fromSearchbar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Self.searchbarRightSidePadding))
        layoutConstraints.append(fromSearchbar.heightAnchor.constraint(equalToConstant: Self.searchbarHeight))
        
        layoutConstraints.append(toSearchbar.topAnchor.constraint(equalTo: fromSearchbar.bottomAnchor, constant: UIView.defaultSystemSpacing))
        layoutConstraints.append(toSearchbar.leadingAnchor.constraint(equalTo: toLabel.trailingAnchor, constant: UIView.defaultSystemSpacing))
        layoutConstraints.append(toSearchbar.trailingAnchor.constraint(equalTo: fromSearchbar.trailingAnchor))
        layoutConstraints.append(toSearchbar.heightAnchor.constraint(equalToConstant: Self.searchbarHeight))
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
}

// Extension of top search view that implements the UISearchBar delegate
extension PETopSearchView: UISearchBarDelegate {
    
    // Whenever user starts editing the search bar, we will update the current selected search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar === fromSearchbar {
            currentSelection = .from
        } else {
            currentSelection = .to
        }
    }
    
    // This method is called whenever the text is changed on the search bar and call the delegate of PETopSearchView with the new text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let delegate = searchDelegate else { return }
        if searchText.count == 0 {
            delegate.dismissSearchResult()
        } else {
            delegate.startSearchWithText(keywords: searchText)
        }
    }
}
