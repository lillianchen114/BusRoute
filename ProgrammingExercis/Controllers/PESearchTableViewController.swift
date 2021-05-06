//
//  PESearchTableViewController.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/11/21.
//

import UIKit

// Delegate protocol declaration, it will notify main view controller that user selected a location
protocol PESearchTableViewControllerDelegate: class {
    func didSelectSearchResult(result: SearchResult)
}

// Search result view controller that contains a table and displays the location name on each cell
class PESearchTableViewController: UITableViewController {
    
    // Properties
    
    // Data source for the search result table view
    private var searchResult = [SearchResult]()
    
    // Cell reuse idenfifier
    private let cellId = "searchCell"
    
    // use weak keyword for delegate to avoid retain cycle
    weak var delegate: PESearchTableViewControllerDelegate?
    
    // View setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register default table view cell for our table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        // Display a blank view when there is no data
        tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // When we get new search result, we will reload out table view to show the new search results
    func updateWithSearchResults(results: [SearchResult]) {
        searchResult = results
        tableView.reloadData()
    }

    // MARK: - Table view data source
    //We only have one section in search result table
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    // number of rows in table is determined by the count of locations in our search result
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResult.count
    }

    // configure the cell for each row, it will display the name of the location at a given index in our data source array
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = searchResult[indexPath.row].name
        return cell
    }
    
    // Table view delegate
    // Called when a cell is selected by user meaning user have chosen the selected location
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let delegate = self.delegate {
            delegate.didSelectSearchResult(result: searchResult[indexPath.row])
        }
    }

}
