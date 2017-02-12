//
//  AgreementTextLabel.swift
//  Splitter
//
//  Created by Wayne Rumble on 11/02/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class AgreementTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        self.backgroundColor = .clear
        self.isScrollEnabled = true
        self.isUserInteractionEnabled = true
        self.isEditable = false
        self.dataDetectorTypes = .link
        self.attributedText = self.setUpText()
    }
    
    func setUpText() -> NSMutableAttributedString {
        let text = NSMutableAttributedString(string: "By Tapping Register you agree that Payment processing services for you on Splitter are provided by Stripe and are subject to the Stripe Connected Account Agreement, which includes the Stripe Terms of Service. By agreeing to these terms or continuing to operate as a user on Splitter, you agree to be bound by the Stripe Services Agreement, as the same may be modified by Stripe from time to time. As a condition of Splitter enabling payment processing services through Stripe, you agree to provide Splitter accurate and complete information about you and your business, and you authorize Splitter to share it and transaction information related to your use of the payment processing services provided by Stripe.")
        
        self.addTextAttributes(text: text)
        self.addParagraphStyling(text: text)
        
        return text
    }
    
    func addTextAttributes(text: NSMutableAttributedString) {
        text.addAttribute(NSForegroundColorAttributeName, value: UIColor(netHex: 0x000010), range: NSMakeRange(0, text.length))
        text.addAttribute(NSLinkAttributeName, value: "https://stripe.com/gb/connect-account/legal", range: NSRange(location: 128, length: 35))
        text.addAttribute(NSLinkAttributeName, value: "https://stripe.com/gb/legal", range: NSRange(location: 183, length: 24))
        self.linkTextAttributes = [NSForegroundColorAttributeName: UIColor(netHex: 0xe9edef)]
    }
    
    func addParagraphStyling(text: NSMutableAttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        text.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: text.length))
    }
}
