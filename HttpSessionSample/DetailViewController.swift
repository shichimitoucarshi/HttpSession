//
//  DetailViewController.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/23.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import HttpSession
import UIKit

let detailViewControllerId: String = "DetailViewController"

class DetailViewController: UIViewController {
    @IBOutlet var responceText: UITextView!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var status: UILabel!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var startButton: UIButton!

    var isDL: Bool = false
    var text: String = ""
    var data: Data?
    var isCancel = false

    let provider: ApiProvider = ApiProvider<DemoApi>()

    override func viewDidLoad() {
        super.viewDidLoad()

        if isDL == true {
            responceText.isHidden = true
            progress.setProgress(0.0, animated: true)
            httpDownload()
        } else {
            progress.isHidden = true
            status.isHidden = true
            stopButton.isHidden = true
            startButton.isHidden = true
            responceText.text = ""
            responceText.text = text
        }
    }

    @IBAction func pushStop(_: Any) {
        provider
            .cancel { [weak self] data in
                self?.data = data
                print("data")
                self?.isCancel = true
            }
    }

    @IBAction func pushStart(_: Any) {
        httpDownload()
    }

    private func httpDownload() {
        provider.download(api: .download,
                          data: data,
                          progress: { [weak self] _, total, expectedToWrite in
                              let progress = Float(total) / Float(expectedToWrite)
                              print("progress \(progress)")
                              DispatchQueue.main.async {
                                  self?.status.text = "\(total)/\(expectedToWrite)"
                                  self?.progress.setProgress(progress, animated: true)
                              }
                          }, download: { url in
                              print("location: \(String(describing: url))")
                          }) { _, _, _ in
        }
    }

    deinit {
        provider.cancel { _ in
            print("Deinitializer")
        }
    }
}
