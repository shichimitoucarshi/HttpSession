//
//  DetailViewController.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/23.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import UIKit
import HttpSession

let detailViewControllerId: String = "DetailViewController"

class DetailViewController: UIViewController {

    @IBOutlet weak var responceText: UITextView!

    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!

    var isDL: Bool = false
    var text: String = ""
    var data: Data?
    var isCancel = false

    let provider: ApiProvider = ApiProvider<DemoApi>()

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.isDL == true {
            self.progress.setProgress(0.0, animated: true)
            self.httpDownload()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let flg = self.isDL ? true : false
        self.responceText.isHidden = flg
        if flg != true {
            self.progress.isHidden = true
            self.status.isHidden = true
            self.stopButton.isHidden = true
            self.startButton.isHidden = true
            self.responceText.text = text
        }
    }

    @IBAction func pushStop(_ sender: Any) {
        self.provider
            .http!
            .cancel { (data) in
                self.data = data
                print("data")
                self.isCancel = true
        }
    }

    @IBAction func pushStart(_ sender: Any) {
        self.httpDownload()
    }

    private func httpDownload () {
        provider.download(api: .download,
                          data: self.data,
                          progress: { (_, total, expectedToWrite) in
                            let progress = Float(total) / Float(expectedToWrite)
                            print ("progress \(progress)")
                            DispatchQueue.main.async {
                                self.status.text = "\(total)/\(expectedToWrite)"
                                self.progress.setProgress(progress, animated: true)
                            }
        }, download: { (url) in
            print ("location: \(String(describing: url))")
        }) { (_, _, _) in

        }
    }
}
