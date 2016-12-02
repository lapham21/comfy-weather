//
//  PreviousOutfitsViewController.swift
//  ComfyWeather
//
//  Created by Nolan Lapham on 10/18/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit

final class PreviousOutfitsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: Enums and Variables

    private var viewModel = PreviousOutfitsViewModel()

    //MARK: Outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //MARK: View Controller LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(of: PreviousOutfitTableViewCell.self)
        tableView.registerNib(of: NoPreviousOutfitsTableViewCell.self)

        tableView.tableFooterView = UIView()

        activityIndicator.startAnimating()

        viewModel.getPreviousOutfits() { [weak self] in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                self?.tableView.reloadData()
                self?.tableView.isHidden = false
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setupForPreviousOutfitsStack()
        navigationItem.title = "PREVIOUS OUTFITS"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "exitMenuWhite"), style: .plain,
                                                            target: self, action: #selector(exitButtonTapped))
    }

    //MARK: Navigation Bar Functions

    @objc private func exitButtonTapped() {
        dismiss(animated: true)
    }

    //MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: viewModel.cellType), for: indexPath)

        if viewModel.cellType == PreviousOutfitTableViewCell.self {
            guard let previousOutfitCell = cell as? PreviousOutfitTableViewCell else { return cell }
            previousOutfitCell.configure(with: viewModel.previousOutfitViewModel(for: indexPath))
            
            return previousOutfitCell
        } else {
            guard let noPreviousOutfitCell = cell as? NoPreviousOutfitsTableViewCell else { return cell }
            noPreviousOutfitCell.configure(with: viewModel)
            
            return noPreviousOutfitCell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: viewModel.cellType))
        guard let previousOutfitCell = cell as? PreviousOutfitTableViewCell else { return 580 }

        return previousOutfitCell.bounds.size.height
    }

    // Functions to add sections and in turn spacing between cells

    func numberOfSections(in tableView: UITableView) -> Int {
        if viewModel.cellType == PreviousOutfitTableViewCell.self {
            return viewModel.previousOutfits.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: viewModel.cellType))
        guard let previousOutfitCell = cell as? PreviousOutfitTableViewCell else { return 15 }

        return previousOutfitCell.bounds.size.height * 0.02
    }
}
