//
//  TrailsView.swift
//  WildWander
//
//  Created by nuca on 13.07.24.
//

import UIKit
import SwiftUI

class TrailsView: UIViewController {
    //MARK: - Properties
    private var viewModel: TrailsViewViewModel
    
    lazy var trailsTableView: UITableView = {
        let tableview = UITableView()
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = UITableView.automaticDimension
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
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    private var loaderView: UIView? = {
        let loaderView = UIHostingController(rootView: LoaderView()).view
        loaderView?.translatesAutoresizingMaskIntoConstraints = false
        loaderView?.backgroundColor = .clear
        return loaderView
    }()
    
    private var topAnchorConstantOfTableView: CGFloat
    
    private var headerLabelLeadingConstraint: NSLayoutConstraint?
    
    var didTapOnCell: ((_: Trail) -> Void)?
    
    //closure accepts another closure willSave(name, description, savedListId) -> Void and returns Void
    var didTapSave: ((@escaping (_: String?, _: String?, _: Int?) -> Void) -> Void)?
    
    var errorDidHappen: ((_: String, _: String, _: String?, _: String, _: (() -> Void)?) -> Void)?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureHeaderLabel()
        configureTrailsTableView()
        if let loaderView {
            view.addSubview(loaderView)
            constrainLoaderView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loaderView?.isHidden = false
    }
    
    //MARK: - Initializers
    init(viewModel: TrailsViewViewModel) {
        self.viewModel = viewModel
        self.topAnchorConstantOfTableView = -40
        
        super.init(nibName: nil, bundle: nil)
        
        viewModel.trailsDidChange = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.trailsTableView.reloadData()
                self.loaderView?.isHidden = true
                self.headerLabel.text = " Trails: \(self.viewModel.trailCount)"
            }
        }
    }
    
    init(viewModel: TrailsViewViewModel, name: String, description: String?) {
        self.viewModel = viewModel
        self.topAnchorConstantOfTableView = 0
        
        super.init(nibName: nil, bundle: nil)
        
        viewModel.trailsDidChange = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.trailsTableView.reloadData()
                self.loaderView?.isHidden = true
            }
        }
        headerLabelLeadingConstraint = headerLabel.leadingAnchor.constraint(equalTo: trailsTableView.leadingAnchor, constant: 20)
        
        changeHeaderLabel(name: name, description: description)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    private func configureHeaderLabel() {
        if let headerLabelLeadingConstraint {
            NSLayoutConstraint.activate([
                headerLabelLeadingConstraint,
                headerLabel.widthAnchor.constraint(equalToConstant: view.bounds.width - 40)
            ])
        }
    }
    private func configureTrailsTableView() {
        view.addSubview(trailsTableView)
        
        constrainTrailsTableView()
        
        trailsTableView.register(TrailsCell.self, forCellReuseIdentifier: TrailsCell.identifier)
        
        trailsTableView.separatorStyle = .none
    }
    
    private func constrainTrailsTableView() {
        NSLayoutConstraint.activate([
            trailsTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: topAnchorConstantOfTableView),
            trailsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trailsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            trailsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
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
    
    func changeHeaderLabel(name: String, description: String?) {
        
        let combinedAttributedString = NSMutableAttributedString()
        
        add(name: name, to: combinedAttributedString)
        
        if let description {
           add(description, to: combinedAttributedString)
        }
        
        combinedAttributedString.append(NSAttributedString(string: "\n"))
        
        headerLabel.numberOfLines = 0
        headerLabel.attributedText = combinedAttributedString
    }
    
    func add(name: String, to combinedAttributedString: NSMutableAttributedString) {
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        
        let attributedName = NSAttributedString(string: name, attributes: nameAttributes)
        combinedAttributedString.append(attributedName)
    }
    
    func add(_ description: String, to combinedAttributedString: NSMutableAttributedString) {
        let descriptionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.gray
        ]
        let attributedDescription = NSAttributedString(string: "\n\(description)", attributes: descriptionAttributes)
        combinedAttributedString.append(attributedDescription)
    }
    
    private func updateHeaderLabelFrame() {
        headerLabel.sizeToFit()
        headerLabel.layoutIfNeeded()
        let headerSize = headerLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        headerLabel.frame = CGRect(origin: .zero, size: headerSize)
        trailsTableView.tableHeaderView = headerLabel
    }
    
    func trailsWillChange() {
        loaderView?.isHidden = false
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
        let currentTrail = viewModel.trailOf(index: indexPath.row)
        TrailsCell.resizeCorrectlyWith = (currentTrail.routeIdentifier ?? "", currentTrail.address ?? "")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TrailsCell.identifier) as! TrailsCell
        
        let urls = currentTrail.images?.map({ urlString in
            viewModel.generateURL(from: urlString)
        })
        
        cell.updateCellWith(
            imageUrls: urls ?? [],
            trailID: currentTrail.id!,
            rating: currentTrail.rating ?? 0.0,
            difficulty: currentTrail.difficulty ?? "",
            length: currentTrail.length ?? 0.0,
            isSaved: currentTrail.isSaved ?? false, 
            didTapSave: didTapSave, 
            errorDidHappen: errorDidHappen
        )
        return cell
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return UITableView.automaticDimension
    }
}

extension TrailsView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didTapOnCell?(viewModel.trailOf(index: indexPath.row))
    }
}
