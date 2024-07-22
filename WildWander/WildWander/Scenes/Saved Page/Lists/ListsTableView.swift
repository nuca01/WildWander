//
//  ListsTableView.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import UIKit

class ListsTableView: UITableView {
    //MARK: - Properties
    var viewModel: ListsTableViewModel
    var didTapOnCreateNewList: (() -> Void)?
    var didTapOnListWithId: ((_: Int) -> Void)?
    
    //MARK: - Initializers
    init(
        viewModel: ListsTableViewModel,
        didTapOnCreateNewList: ( () -> Void)? = nil,
        didTapOnListWithId: ( (_: Int) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.didTapOnCreateNewList = didTapOnCreateNewList
        self.didTapOnListWithId = didTapOnListWithId
        
        super.init(frame: .zero, style: .plain)
        
        rowHeight = UITableView.automaticDimension
        translatesAutoresizingMaskIntoConstraints = false
        estimatedRowHeight = 100
        dataSource = self
        delegate = self
        register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
        
        viewModel.listDidChange = { [weak self] in
            DispatchQueue.main.async {
                self?.reloadData()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UITableViewDataSource
extension ListsTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.listsCount + 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier) as! ListCell
        if indexPath.row == 0 {
            cell.updateCellAsCreateAList()
        } else {
            let currentList = viewModel.listOf(index: indexPath.row - 1)
            cell.updateCellWith(title: currentList.name ?? "", trailCount: currentList.savedTrailCount ?? 0)
        }
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ListsTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            didTapOnCreateNewList?()
        } else {
            let listId = viewModel.listOf(index: indexPath.row - 1).id
            didTapOnListWithId?(listId)
        }
    }
}
