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
    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    var http:Http!
    var isDL:Bool = false
    var text: String = ""
    var data:Data? = nil
    var isCancel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isDL == true {
            self.progress.setProgress(0.0, animated: true)
            self.http = Http(url: "https://shichimitoucarashi.com/mp4/Designing_For_iPad_Pro_ad_hd.mp4", method: .get)
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
        self.http.cancel { (data) in
            self.data = data
            print("data")
            self.isCancel = true
        }
    }
    
    @IBAction func pushStart(_ sender: Any) {
        self.httpDownload()
    }
    
    private func httpDownload (){
        self.http.download(resumeData:self.data,
                           progress: { (written, total, expectedToWrite) in
            let progress = Float(total) / Float(expectedToWrite)
            print ("progress \(progress)")
            DispatchQueue.main.async(execute: {
                self.progress.setProgress(progress, animated: true)
                
                self.status.text = "\(total)/\(expectedToWrite)"
            })
            
        }, download: { (location) in
            print ("location: \(String(describing: location))")
        }, completionHandler: { (data, responce, error) in
            
            if self.isCancel == false {
                self.status.text = "Completed"
            }else{
                self.isCancel = false
            }
        })
    }
    
}
