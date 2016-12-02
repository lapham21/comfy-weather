//
//  AddClothingInputView.swift
//  ComfyWeather
//
//  Created by Son Le on 10/12/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import RxSwift
import RxCocoa

final class AddClothingInputView: UICollectionReusableView {

    private var disposeBag = DisposeBag()

    @IBOutlet weak var outfitNameTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    func configure(withViewModel viewModel: AddClothingInputViewModel?,
                   completion: (() -> ())?) {
        disposeBag = DisposeBag()

        if let viewModel = viewModel {
            viewModel.outfitName.asObservable()
                .bindTo(outfitNameTextField.rx.text)
                .addDisposableTo(disposeBag)

            outfitNameTextField.rx.text
                .bindTo(viewModel.outfitName)
                .addDisposableTo(disposeBag)

            viewModel.outfitName.asObservable()
                .map { !$0.isEmpty }
                .bindTo(submitButton.rx.enabled)
                .addDisposableTo(disposeBag)
        }

        if let completion = completion {
            outfitNameTextField.rx.controlEvent(.editingDidEnd)
                .subscribe(onNext: completion)
                .addDisposableTo(disposeBag)
            
            submitButton.rx.controlEvent(.touchUpInside)
                .subscribe(onNext: completion)
                .addDisposableTo(disposeBag)
        }
    }

}
