//
//  Tesseract.swift
//  Splitter
//
//  Created by Wayne Rumble on 16/03/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import TesseractOCR

class Tesseract {
    
    func recognise(_ image: UIImage) -> String {
        
        let tesseract = G8Tesseract(language: "eng")
        
        tesseract?.engineMode = .tesseractCubeCombined
        tesseract?.pageSegmentationMode = .singleBlock
        tesseract?.image = image
        tesseract?.recognize()
        
        return tesseract!.recognizedText!
    }
}
