//
//  ViewController.swift
//  MacOS 機械学習
//
//  Created by Shunzhe Ma on 5/15/20.
//  Copyright © 2020 Shunzhe Ma. All rights reserved.
//

import Cocoa
import Vision

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: 機械学習
    
    func analyzeImage(_ input: CIImage) {
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
            self?.showAlert(text: detectedResult)
        }
        //分析する
        let handler = VNImageRequestHandler(ciImage: input)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // MARK: File selection
    @IBAction func browseFile(sender: AnyObject) {
        let openPanel = NSOpenPanel();
        openPanel.title = "Select a file"
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["jpg", "png", "jpeg"]
        
        openPanel.begin { (result) -> Void in
            if(result == NSApplication.ModalResponse.OK){
                //Start CoreML tast
                let path = openPanel.url!.path
                self.processFiles(path: path)
            }
        }
    }
    
    func processFiles(path: String){
        if let image = CIImage(contentsOf: URL(fileURLWithPath: path)) {
            analyzeImage(image)
        }
    }
    
    // MARK: Helper
    func showAlert(text: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "機械学習の結果"
            alert.informativeText = text
            alert.alertStyle = .informational
            alert.addButton(withTitle: "はい")
            alert.runModal()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

