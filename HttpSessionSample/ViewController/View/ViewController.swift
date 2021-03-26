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
    @IBOutlet weak var progressView: UIProgressView!
    var viewModel: ViewModelType = ViewModel()

    func detailViewController(param: String = "",
                              result: String = "",
                              responce: String = "",
                              error: String = "",
                              isDL: Bool = false)
    {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        guard let detailViewController = storyboard.instantiateInitialViewController() as? DetailViewController else { return }
        let text = "param:\n\(param)\nresponce header:\n\(responce)\nresult:\n \n\(result)\n\(error)"
        detailViewController.viewModel = DetailViewModel(text: text,
                                                         isDL: isDL)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func detail(data: Data?,
                param: String = "",
                responce: HTTPURLResponse?,
                error: Error?)
    {
        DispatchQueue.main.async {
            if let unwrapData = data,
               let result = String(data: unwrapData, encoding: .utf8),
               let unwrapResponce = responce
            {
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
        viewModel.output.detail { [unowned self] data, str, res, error in
            self.detail(data: data, param: str, responce: res, error: error)
        }

        viewModel.output.transition { [unowned self] in
            self.detailViewController(isDL: true)
        }
        
        viewModel.output.progress { percentage in
            self.progressView.progress = percentage
            print("\(Int(percentage * 100))%")
        }
        
        viewModel.input.callApi(indexPath)
    }
}
