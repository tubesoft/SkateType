//
//  KeyboardViewController.swift
//  SkateType
//
//  Created by Takatomo INOUE on 2016/09/17.
//  Copyright © 2016年 Takatomo INOUE. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    @IBOutlet var nextKeyboardButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var beginPointX: CGFloat = 0.0
    var beginPointY: CGFloat = 0.0
    var insertingChar: String? = nil
    var isVertical: Bool = false
    let distChangeHV: CGFloat = 2
    let sensitivity: CGFloat = 3
    var isFirstTouch: Bool = true
    
    var x01: CGFloat = 0.0
    var x02: CGFloat = 0.0
    var x03: CGFloat = 0.0
    var x04: CGFloat = 0.0
    var x05: CGFloat = 0.0
    var y01: CGFloat = 0.0
    var y02: CGFloat = 0.0
    var y03: CGFloat = 0.0
    var y04: CGFloat = 0.0
    var y05: CGFloat = 0.0
    var movAveX: CGFloat = 0.0
    var movAveY: CGFloat = 0.0
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = UINib(nibName:"Keyboard", bundle:nil).instantiate(withOwner: self,options:nil)[0] as! UIView
        self.view.addSubview(v)

        // Perform custom UI setup here
//        self.nextKeyboardButton = UIButton(type: .system)
//        
//        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
//        self.nextKeyboardButton.sizeToFit()
//        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
//
//        
//        imageView.isUserInteractionEnabled = true
////        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self,action: Selector(("imageTapped:"))))
//        
//        self.view.addSubview(self.imageView)
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        self.label.text = ""
        self.view.addSubview(self.nextKeyboardButton)
        self.view.addSubview(self.deleteButton)
        self.view.addSubview(self.enterButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.deleteButton.rightAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.deleteButton.topAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.enterButton.rightAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.enterButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        insertingChar = " "
        beginPointX = (touches.first?.location(in: imageView).x)!
        beginPointY = (touches.first?.location(in: imageView).y)!
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let x = touches.first?.location(in: imageView).x
        let y = touches.first?.location(in: imageView).y
        print("X: \(x) Y:\(y)")
        if isVertical {
//            if fabs(x! - beginPointX) > distChangeHV {
            if movAveX > distChangeHV {
                isVertical = false
                beginPointX = x!
                beginPointY = y!
                if !isFirstTouch || insertingChar != " " {
                    let proxy = textDocumentProxy as UITextDocumentProxy
                    proxy.insertText(insertingChar!)
                }
                isFirstTouch = false
            }
        } else {
//            if fabs(y! - beginPointY) > distChangeHV {
            if movAveY > distChangeHV {
                isVertical = true
                beginPointX = x!
                beginPointY = y!
                if !isFirstTouch || insertingChar != " " {
                    let proxy = textDocumentProxy as UITextDocumentProxy
                    proxy.insertText(insertingChar!)
                }
                isFirstTouch = false
            }
        }
        defineLetterToInput(currentXPos: x!, currentYPos: y!, isVertical: isVertical)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.insertText(insertingChar!)
        insertingChar = " "
        label.text = ""
        isFirstTouch = true
        clearAve()
    }
    
    @IBAction func pressDelete(_ sender: AnyObject) {
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.deleteBackward()
    }
    
    @IBAction func pressReturn(_ sender: AnyObject) {
        let proxy = textDocumentProxy as UITextDocumentProxy
        proxy.insertText("\n")
    }
    
    func defineLetterToInput(currentXPos: CGFloat, currentYPos: CGFloat, isVertical: Bool) {
        var dist: CGFloat = 0
        var isTryingToChange = false
        calcMovAve(currentX: currentXPos, currentY: currentYPos)
        if isVertical {
            dist = fabs(beginPointY - currentYPos)
            if movAveX > distChangeHV {
                isTryingToChange = true
            }
        } else {
            dist = fabs(beginPointX - currentXPos)
            if movAveY > distChangeHV {
                isTryingToChange = true
            }

        }
        if !isTryingToChange {
            if dist < sensitivity * 3 {
                insertingChar = " "
            } else if dist < sensitivity * 4 {
                insertingChar = "a"
            } else if dist < sensitivity * 5 {
                insertingChar = "b"
            } else if dist < sensitivity * 6 {
                insertingChar = "c"
            } else if dist < sensitivity * 7 {
                insertingChar = "d"
            } else if dist < sensitivity * 8 {
                insertingChar = "e"
            } else if dist < sensitivity * 9 {
                insertingChar = "f"
            } else if dist < sensitivity * 10 {
                insertingChar = "g"
            } else if dist < sensitivity * 11 {
                insertingChar = "h"
            } else if dist < sensitivity * 12 {
                insertingChar = "i"
            } else if dist < sensitivity * 13 {
                insertingChar = "j"
            } else if dist < sensitivity * 14 {
                insertingChar = "k"
            } else if dist < sensitivity * 15 {
                insertingChar = "l"
            } else if dist < sensitivity * 16 {
                insertingChar = "m"
            } else if dist < sensitivity * 17 {
                insertingChar = "n"
            } else if dist < sensitivity * 18 {
                insertingChar = "o"
            } else if dist < sensitivity * 19 {
                insertingChar = "p"
            } else if dist < sensitivity * 20 {
                insertingChar = "q"
            } else if dist < sensitivity * 21 {
                insertingChar = "r"
            } else if dist < sensitivity * 22 {
                insertingChar = "s"
            } else if dist < sensitivity * 23 {
                insertingChar = "t"
            } else if dist < sensitivity * 24 {
                insertingChar = "u"
            } else if dist < sensitivity * 25 {
                insertingChar = "v"
            } else if dist < sensitivity * 26 {
                insertingChar = "w"
            } else if dist < sensitivity * 27 {
                insertingChar = "x"
            } else if dist < sensitivity * 28 {
                insertingChar = "y"
            } else if dist < sensitivity * 29 {
                insertingChar = "z"
            } else if dist < sensitivity * 30 {
                insertingChar = "."
            }
        }
        label.text = insertingChar
    }
    
    func calcMovAve (currentX: CGFloat, currentY: CGFloat) {
        x05 = x04
        x04 = x03
        x03 = x02
        x02 = x01
        x01 = currentX
        y05 = y04
        y04 = y03
        y03 = y02
        y02 = y01
        y01 = currentY
        
        if x01 != 0 && x02 != 0 && x03 != 0 && x04 != 0 && x05 != 0
            && y01 != 0 && y02 != 0 && y03 != 0 && y04 != 0 && y05 != 0 {
            movAveX = fabs(((x05-x04) + (x04-x03) + (x03-x02) + (x02-x01))/4)
            movAveY = fabs(((y05-y04) + (y04-y03) + (y03-y02) + (y02-y01))/4)
        }

    }
    
    func clearAve () {
        x01 = 0.0
        x02 = 0.0
        x03 = 0.0
        x04 = 0.0
        x05 = 0.0
        y01 = 0.0
        y02 = 0.0
        y03 = 0.0
        y04 = 0.0
        y05 = 0.0
        movAveX = 0.0
        movAveY = 0.0
    }
}
