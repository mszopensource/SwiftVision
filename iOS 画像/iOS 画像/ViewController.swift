//
//  ViewController.swift
//  iOS 画像
//
//  Created by Shunzhe Ma on 5/15/20.
//  Copyright © 2020 Shunzhe Ma. All rights reserved.
//

import UIKit
import Vision
import SwiftExtensions

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: 機械学習
    
    func analyzeImage(_ input: UIImage) {
        //セットアップ
        guard let model = try? VNCoreMLModel(for: anime().model) else {
            fatalError("MLモデルを読み込めません")
        }
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                      fatalError("結果がありません")
                   }
            let detectedResult = topResult.identifier
            //Now we have the name of the label here
            detectedResult.アラートを表示(on: self)
        }
        //画像変換 UIImage -> ciImage
        guard let convertedImage = input.cgImage else {
            fatalError("画像変換に失敗しました")
        }
        //分析する
        let handler = VNImageRequestHandler(cgImage: convertedImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // MARK: 写真の選択
    
    @IBAction func actionSelectImage(){
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        self.dismiss(animated: true, completion: { () -> Void in
            self.analyzeImage(image)
        })
    }


}

