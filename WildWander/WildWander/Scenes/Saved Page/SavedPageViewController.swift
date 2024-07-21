//
//  SavedPageViewController.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import UIKit

class SavedPageViewController: UIViewController {
    let listsTableViewModel = ListsTableViewModel()
    private lazy var listsTableView: ListsTableView = {
        let listsTableView = ListsTableView(viewModel: listsTableViewModel)
        return listsTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listsTableView)
        view.backgroundColor = .white
        NSLayoutConstraint.activate([
            listsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            listsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            listsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            listsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        listsTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listsTableViewModel.getSavedLists()
    }

}
