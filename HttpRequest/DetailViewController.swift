//
//  DetailViewController.swift
//  HttpRequest
//
//  Created by Shichimitoucarashi on 2018/04/23.
//  Copyright © 2018年 keisuke yamagishi. All rights reserved.
//

import UIKit

let detailViewControllerId: String = "DetailViewController"

class DetailViewController: UIViewController {
    
    @IBOutlet weak var responceText: UITextView!
    var text: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.responceText.text = self.text
    }
}
