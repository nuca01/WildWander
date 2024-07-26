//
//  SearchPageViewController.swift
//  WildWander
//
//  Created by nuca on 16.07.24.
//

import UIKit
import SwiftUI

class SearchPageViewController: UIViewController {
    //MARK: - Properties
    private lazy var viewModel = SearchPageViewModel(didGetData: { [weak self] in
        DispatchQueue.main.async {
            self?.tableView.reloadData()
            self?.loaderView?.isHidden = true
        }
    })
    
    private lazy var searchBar: SearchBarView = {
        let searchBarView = SearchBarView()
        searchBarView.delegate = self
        return searchBarView
    }()
    
    private lazy var tableView = {
        let tableView = UITableView()
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .wildWanderExtraLightGray
        
        return tableView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [searchBar, tableView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var loaderView: UIView? = {
        let loaderView = UIHostingController(rootView: LoaderView()).view
        loaderView?.translatesAutoresizingMaskIntoConstraints = false
        loaderView?.backgroundColor = .clear
        return loaderView
    }()
    
    var sheetDidDisappear: () -> Void
    var didSelectLocation: (_: Location?) -> Void

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        view.backgroundColor = .wildWanderExtraLightGray
        constrainSearchBar()
        constrainStackView()
        constrainTableView()
        if let loaderView {
            view.addSubview(loaderView)
            constrainLoaderView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didSelectLocation(nil)
        sheetDidDisappear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
        loaderView?.isHidden = true
    }
    
    //MARK: - Initializer
    init(
        sheetDidDisappear: @escaping () -> Void,
        didSelectLocation: @escaping (_: Location?) -> Void
    ) {
        self.sheetDidDisappear = sheetDidDisappear
        self.didSelectLocation = didSelectLocation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    private func constrainSearchBar() {
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])
    }
    
    private func constrainStackView() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
    
    private func constrainTableView() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: stackView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
        ])
    }
    
    private func constrainLoaderView() {
        if let loaderView {
            NSLayoutConstraint.activate([
                loaderView.heightAnchor.constraint(equalToConstant: 20),
                loaderView.widthAnchor.constraint(equalToConstant: 20),
                loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
        }
    }
}

// MARK: - UITableViewDataSource
extension SearchPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.locationsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.locationFor(index: indexPath.row).displayName
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .wildWanderExtraLightGray
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectLocation(viewModel.locationFor(index: indexPath.row))
    }
}

extension SearchPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        viewModel.search(with: textField.text ?? "")
        loaderView?.isHidden = false
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.clearData()
        return true
    }
}
