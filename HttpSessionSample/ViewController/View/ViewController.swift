//
//  ViewController.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/22.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import HttpSession
import UIKit

final class ViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var progressView: UIProgressView!

    private var viewModel: ViewModelType = ViewModel()

    private func detailViewController(text: String = "",
                                      isDL: Bool = false)
    {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        guard let detailViewController = storyboard.instantiateInitialViewController() as? DetailViewController else { return }
        detailViewController.viewModel = DetailViewModel(text: text,
                                                         isDL: isDL)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        apis.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = apis[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        progressView.progress = 0.0
        viewModel
            .output
            .detail { [unowned self] result in
                detailViewController(text: result)
            }

        viewModel
            .output
            .transition { [unowned self] in
                detailViewController(isDL: true)
            }

        viewModel
            .output
            .progress { [unowned self] percentage in
                progressView.progress = percentage
                print("\(Int(percentage * 100))%")
            }

        viewModel.input.callApi(indexPath)
    }
}
