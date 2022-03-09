//
//  DetailViewController.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/23.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import HttpSession
import UIKit

final class DetailViewController: UIViewController {
    @IBOutlet var responceText: UITextView!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var status: UILabel!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var startButton: UIButton!
    var viewModel: DetailViewModelType!

    override func loadView() {
        super.loadView()

        if viewModel.output.isDL {
            responceText.isHidden = true
            progress.setProgress(0.0, animated: true)
            viewModel.input.download()
            viewModel.output.progress { [weak self] total, expectedToWrite, progress in
                guard let self = self else { return }
                self.status.text = "\(total)byte/\(expectedToWrite)byte"
                self.progress.setProgress(progress, animated: true)
            }
        } else {
            progress.isHidden = true
            status.isHidden = true
            stopButton.isHidden = true
            startButton.isHidden = true
            responceText.text = ""
            responceText.text = viewModel.output.text
        }
    }

    @IBAction func pushStop(_: Any) {
        viewModel.input.stopDownload()
    }

    @IBAction func pushStart(_: Any) {
        viewModel.input.reDwonload()
    }

    deinit {
        viewModel.input.cancel()
    }
}
