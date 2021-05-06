//
//  BusRouteTableViewController.swift
//  ProgrammingExercis
//
//  Created by Yiran Chen on 1/13/21.
//

import UIKit

// Delegate protocol declaration, it will notify main view controller that user selected a route
protocol BusRouteTableViewControllerDelegate: class {
    func didSelectBusRouteAtIndex(index: Int)
}

// This view controller shows all the available bus routes between the start and end location
class BusRouteTableViewController: UITableViewController {
    
    // The bus route data source
    private let busRoutes: [BusRouteModel]
    
    // Reuse identifier of the bus route cell
    static private let cellReuseId = "busRouteCell"
    
    // The delegate of the bus route view controller, use weak hear to avoid retain cycles
    weak var delegate: BusRouteTableViewControllerDelegate?
    
    // Custom initializer with burRoutes array as parameter
    init(busRoutes: [BusRouteModel]) {
        self.busRoutes = busRoutes
        super.init(nibName: nil, bundle: nil)
        title = "Available Routes"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Additional setup after view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        // Display a blank page for empty cells
        tableView.tableFooterView = UIView()
        // Register the default table view cell with reuse id
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellReuseId)
        // Let the system determine the heigh of cell (because different routes have different steps and thus the insturction could be different length)
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - Table view data source
    
    // There is only one section in this table
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    // The number of rows is determined by the number of routes between the two locations
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return busRoutes.count
    }
    
    /* For each cell we will display the route's step:
     Step1: Walk 200m toward 1st street
     Step2: Take bus 129 towards 2nd street
     ...
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseId, for: indexPath)
        cell.textLabel?.text = busRoutes[indexPath.row].pathInstructions()
        cell.textLabel?.numberOfLines = 0
        return cell
    }
        
    // When user taps on a cell, it means user have choose this route and we will notify our delegate about this selection and dimiss our selves
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let delegate = self.delegate {
            delegate.didSelectBusRouteAtIndex(index: indexPath.row)
        }
        dismiss(animated: true)
    }

}
