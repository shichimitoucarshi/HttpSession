//
//  DetailViewModel.swift
//  HttpSessionSample
//
//  Created by keisuke yamagishi on 2020/09/28.
//  Copyright © 2020 keisuke yamagishi. All rights reserved.
//

import HttpSession

protocol DetailViewModelInput: AnyObject {
    func download()
    func cancel()
    func reDwonload()
    func stopDownload()
}

protocol DetailViewModelOutput: AnyObject {
    var progress: ((Int64, Int64, Float) -> Void)? { get set }
    var isDL: Bool { get }
    var text: String { get }
}

protocol DetailViewModelType: AnyObject {
    var input: DetailViewModelInput { get }
    var output: DetailViewModelOutput { get set }
}

final class DetailViewModel: DetailViewModelType {
    var data: Data?
    var isCancel = false
    let provider: ApiProvider = ApiProvider<DemoApi>()
    var input: DetailViewModelInput { return self }
    var output: DetailViewModelOutput { get { return self } set {} }
    var _progress: ((Int64, Int64, Float) -> Void)?
    var _isDL: Bool = false
    var _text: String = ""

    init(text: String, isDL: Bool) {
        _isDL = isDL
        _text = text
    }
}

extension DetailViewModel: DetailViewModelInput {
    func download() {
        httpDownload()
    }

    func cancel() {
        provider.cancel { _ in }
    }

    func reDwonload() {
        httpDownload()
    }

    func stopDownload() {
        provider
            .cancel { [weak self] data in
                self?.data = data
                print("data")
                self?.isCancel = true
            }
    }

    private func httpDownload() {
        provider.download(api: .download,
                          data: data,
                          progress: { [weak self] _, total, expectedToWrite in
                              guard let self = self else { return }
                              DispatchQueue.main.async {
                                  let progress = Float(total) / Float(expectedToWrite)
                                  self._progress?(total, expectedToWrite, progress)
                              }
                          }, download: { url in
                              print("location: \(String(describing: url))")
                          }) { _, _, _ in
        }
    }
}

extension DetailViewModel: DetailViewModelOutput {
    var progress: ((Int64, Int64, Float) -> Void)? {
        get {
            _progress
        }
        set {
            _progress = newValue
        }
    }

    var text: String {
        _text
    }

    var isDL: Bool {
        _isDL
    }
}
