//
//  ViewController.swift
//  AppIconReducer
//
//  Created by zackzheng on 2019/8/1.
//  Copyright © 2019 zackzheng. All rights reserved.
//

import Cocoa

enum IconSize: Int, CaseIterable {
    case twentyNine = 29
    case forty = 40
    case fiftyEight = 58
    case seventySix = 76
    case eighty = 80
    case eightySeven = 87
    case oneHundredAndTwenty = 120
    case oneHundredAndFiftyTwo = 152
    case oneHundredAndSixtySeven = 167
    case oneHundredAndEighty = 180
    case oneThousandAndTwentyFour = 1024
}

class IndexViewController: NSViewController {

    @IBOutlet weak var stackView: NSStackView!
    @IBOutlet weak var destinationView: DestinationView!
    @IBOutlet weak var destinationImageView: NSImageView!
    @IBOutlet weak var tipsTextField: NSTextField!
    @IBOutlet weak var backgroundView: NSView!
    
    private var sizesToReduce = IconSize.allCases
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configBackgroundView()
        configDestinationView()
        configCheckButtons()
    }
    
    @objc func onClickCheckBox(sender: NSButton) {
        guard let iconSize = IconSize(rawValue: sender.tag) else {
            return
        }
        if sender.state == .on {
            sizesToReduce.append(iconSize)
        } else {
            if let index = sizesToReduce.firstIndex(of: iconSize) {
                sizesToReduce.remove(at: index)
            }
        }
    }
    
    @IBAction func onClickReduceButton(sender: NSButton) {
        
        guard let image = self.destinationImageView.image else {
            return
        }
        
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "保存"
        panel.message = "选择保存图片的目录"
        panel.beginSheetModal(for: self.view.window!) { [weak self] (response) in
            
            guard let `self` = self else {return}
            guard response == NSApplication.ModalResponse.OK, let path = panel.urls.first else {
                return
            }
            self.sizesToReduce.forEach({ (iconSize) in
                
                let ratio: CGFloat = 2.0 // NSScreen.main?.backingScaleFactor ?? 2.0
                let newSize = NSSize(width: CGFloat(iconSize.rawValue) / ratio, height: CGFloat(iconSize.rawValue) / ratio)
                let newImage = NSImage(size: newSize, flipped: true, drawingHandler: { (rect) -> Bool in
                    image.draw(in: rect)
                    return true
                })
                let cgRef = newImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!
                let newRep: NSBitmapImageRep = NSBitmapImageRep(cgImage: cgRef)
                let imageData = newRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
                do {
                    try imageData?.write(to: path.appendingPathComponent("icon\(iconSize.rawValue).png"))
                } catch {
                    print("error = ")
                    print(error)
                }
            })
        }
    }
    
    private func configBackgroundView() {
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = 10
        backgroundView.layer?.backgroundColor = NSColor.white.cgColor
    }
    
    private func configDestinationView() {
        destinationView.delegate = self
    }
    
    private func configCheckButtons() {
        sizesToReduce.forEach { size in
            let side = size.rawValue
            let button = NSButton(checkboxWithTitle: "\(side)x\(side)", target: self, action: #selector(IndexViewController.onClickCheckBox(sender:)))
            button.tag = size.rawValue
            button.state = .on
            stackView.addArrangedSubview(button)
        }
        stackView.distribution = .fillEqually
    }
}

extension IndexViewController: DestinationViewDelegate {
    
    func processImage(_ image: NSImage) {
        tipsTextField.stringValue = String("\(Int(image.size.width))x\(Int(image.size.height))")
        destinationImageView.image = image
    }
}
