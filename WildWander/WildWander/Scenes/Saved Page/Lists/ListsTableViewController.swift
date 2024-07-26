//
//  ListsTableViewController.swift
//  WildWander
//
//  Created by nuca on 26.07.24.
//

import UIKit

class ListsTableViewController: UITableViewController {
    var didDismiss: (() -> Void)?
    
    init (listsTableView: ListsTableView) {
        super.init(nibName: nil, bundle: nil)
        tableView = listsTableView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didDismiss?()
    }
}
