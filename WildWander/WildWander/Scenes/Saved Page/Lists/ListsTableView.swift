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
    var didTapOnList: ((_: Int, _: String, _: String?) -> Void)?
    
    //MARK: - Initializers
    init(
        viewModel: ListsTableViewModel,
        didTapOnCreateNewList: ( () -> Void)? = nil,
        didTapOnListWithId: ((_: Int, _: String, _: String?) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.didTapOnCreateNewList = didTapOnCreateNewList
        self.didTapOnList = didTapOnListWithId
        
        super.init(frame: .zero, style: .plain)
        
        rowHeight = UITableView.automaticDimension
        translatesAutoresizingMaskIntoConstraints = false
        estimatedRowHeight = 100
        dataSource = self
        delegate = self
        register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
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
            cell.updateCellWith(
                title: currentList.name ?? "",
                trailCount: currentList.savedTrailCount ?? 0,
                imageUrl: viewModel.generateURL(from: currentList.imageUrl ?? "")
            )
        }
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ListsTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            didTapOnCreateNewList?()
        } else {
            let list = viewModel.listOf(index: indexPath.row - 1)
            didTapOnList?(list.id, list.name ?? "name unavailable", list.description)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row != 0 {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            beginUpdates()
            viewModel.deleteList(index: indexPath.row - 1)
            deleteRows(at: [indexPath], with: .fade)
            endUpdates()
        }
    }
}
