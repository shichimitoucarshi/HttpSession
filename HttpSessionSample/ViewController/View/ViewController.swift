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
    @IBOutlet var tableView: UITableView!
    var viewModel: ViewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func detailViewController(param: String = "",
                              result: String = "",
                              responce: String = "",
                              error: String = "",
                              isDL: Bool = false) {
        let identifer = DetailViewController.detailViewControllerId
        let detailViewController = (storyboard?
                                        .instantiateViewController(withIdentifier: identifer) as? DetailViewController)!
        let text = "param:\n\(param)\nresponce header:\n\(responce)\nresult:\n \n\(result)\n\(error)"
        detailViewController.viewModel = DetailViewModel(text: text,
                                                         isDL: isDL)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func detail(data: Data?,
                param: String = "",
                responce: HTTPURLResponse?,
                error: Error?) {
        DispatchQueue.main.async {
            if let unwrapData = data,
               let result = String(data: unwrapData, encoding: .utf8),
               let unwrapResponce = responce {
                self.detailViewController(param: param,
                                          result: result,
                                          responce: String(describing: unwrapResponce))
            } else if let unwrapResponce = responce {
                self.detailViewController(param: param,
                                          responce: String(describing: unwrapResponce))
            } else if let unwrapError = error {
                self.detailViewController(param: param,
                                          error: String(describing: unwrapError))
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return apis.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = apis[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.input.callApi(indexPath)

        viewModel.output.detail = { [unowned self] data, str, res, error in
            self.detail(data: data, param: str, responce: res, error: error)
        }

        viewModel.output.pushDetailViewController = { [unowned self] in
            self.detailViewController(isDL: true)
        }
    }
}
