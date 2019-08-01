//
//  DestinationView.swift
//  AppIconReducer
//
//  Created by zackzheng on 2019/8/1.
//  Copyright © 2019 zackzheng. All rights reserved.
//

import Cocoa

protocol DestinationViewDelegate {
    func processImage(_ image: NSImage)
}

class DestinationView: NSView {
    
    var delegate: DestinationViewDelegate?
    
    override func awakeFromNib() {
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {

        isReceivingDrag = false
        let pasteBoard = sender.draggingPasteboard
        guard let image = NSImage(pasteboard: pasteBoard) else {
            return false
        }
        delegate?.processImage(image)
        return true
    }
}
