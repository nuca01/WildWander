//
//  TrailsView.swift
//  WildWander
//
//  Created by nuca on 13.07.24.
//

import UIKit

class TrailsView: UIViewController {
    //MARK: - Properties
    private var viewModel: TrailsViewViewModel
    
    lazy var trailsTableView: UITableView = {
        let tableview = UITableView()
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 500
        tableview.dataSource = self
        tableview.delegate = self
        tableview.tableHeaderView = headerLabel
        return tableview
    }()
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = " Trails: \(viewModel.trailCount)"
        label.textColor = .wildWanderGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    var didTapOnCell: ((_: Trail) -> Void)?
    
    //closure accepts another closure willSave(name, description, savedListId) -> Void and returns Void
    var didTapSave: ((@escaping (_: String?, _: String?, _: Int?) -> Void) -> Void)?
    
    var errorDidHappen: ((_: String, _: String, _: String?, _: String, _: (() -> Void)?) -> Void)?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTrailsTableView()
    }
    
    //MARK: - Initializers
    init(viewModel: TrailsViewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.trailsDidChange = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.trailsTableView.reloadData()
                self.headerLabel.text = " Trails: \(self.viewModel.trailCount)"
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    private func configureTrailsTableView() {
        view.addSubview(trailsTableView)
        
        constrainTrailsTableView()
        
        trailsTableView.register(TrailsCell.self, forCellReuseIdentifier: TrailsCell.identifier)
        
        trailsTableView.separatorStyle = .none
    }
    
    private func constrainTrailsTableView() {
        NSLayoutConstraint.activate([
            trailsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            trailsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trailsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trailsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
        ])
    }
}

extension TrailsView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.trailCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrailsCell.identifier) as! TrailsCell
        let currentTrail = viewModel.trailOf(index: indexPath.row)
        let urls = currentTrail.images?.map({ urlString in
            viewModel.generateURL(from: urlString)
        })
        
        cell.updateCellWith(
            imageUrls: urls ?? [],
            trailID: currentTrail.id!,
            trailTitle: currentTrail.routeIdentifier ?? "",
            address: currentTrail.address ?? "",
            rating: currentTrail.rating ?? 0.0,
            difficulty: currentTrail.difficulty ?? "",
            length: currentTrail.length ?? 0.0,
            isSaved: currentTrail.isSaved ?? false, 
            didTapSave: didTapSave, 
            errorDidHappen: errorDidHappen
        )
        return cell
    }
}

extension TrailsView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didTapOnCell?(viewModel.trailOf(index: indexPath.row))
    }
}
