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
    func progress(_ progress: ((Int64, Int64, Float) -> Void)?)
    var isDL: Bool { get }
    var text: String { get }
}

protocol DetailViewModelType: AnyObject {
    var input: DetailViewModelInput { get }
    var output: DetailViewModelOutput { get }
}

final class DetailViewModel: DetailViewModelType {
    var data: Data?
    var isCancel = false
    let provider = ApiProvider<DemoApi>()
    var input: DetailViewModelInput { self }
    var output: DetailViewModelOutput { self }
    var progressClosure: ((Int64, Int64, Float) -> Void)?
    var isDownload: Bool = false
    var internalText: String = ""

    init(text: String, isDL: Bool) {
        isDownload = isDL
        internalText = text
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
                guard let self = self else { return }
                self.data = data
                isCancel = true
            }
    }

    private func httpDownload() {
        provider.download(api: .download,
                          data: data,
                          progress: { [weak self] _, total, expectedToWrite in
                              guard let self = self else { return }
                              let progress = Float(total) / Float(expectedToWrite)
                              progressClosure?(total, expectedToWrite, progress)
                          }, download: { url in
                              print("location: \(String(describing: url))")
                          }) { _, _, _ in
        }
    }
}

extension DetailViewModel: DetailViewModelOutput {
    func progress(_ progress: ((Int64, Int64, Float) -> Void)?) {
        progressClosure = progress
    }

    var text: String {
        internalText
    }

    var isDL: Bool {
        isDownload
    }
}
