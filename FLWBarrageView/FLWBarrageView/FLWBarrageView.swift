//
//  FLWBarrageView.swift
//  FLWBarrageView
//
//  Created by LW on 15/5/26.
//  Copyright (c) 2015年 FLW. All rights reserved.
//

import UIKit

class FLWBarrageObject:NSObject {
    var userNick:NSString!
    var content:NSString!
    init(nick:NSString,cont:NSString) {
        super.init()
        userNick = nick
        content = cont
    }
}

class FLWBarrageViewLabel: UILabel {
    init(frame: CGRect, contentStr:NSMutableAttributedString) {
        super.init(frame: frame)
        self.numberOfLines = 1
        self.contentString = contentStr
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var contentString:NSMutableAttributedString{
        get{
            return self.contentString
        }
        set{
            self.attributedText = newValue
            var textSize :CGSize = self.sizeThatFits(CGSizeMake(CGFloat.max, self.frame.size.height))
            var frame4self:CGRect = self.frame
            frame4self.size.width = textSize.width
            self.frame = frame4self
        }
    }
}

class FLWBarrageView: UIView {
    var freeingLabels:NSMutableArray! =  NSMutableArray()
    var allLabels:NSMutableArray! = NSMutableArray()
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func addString(attString:NSMutableAttributedString){
        var label:FLWBarrageViewLabel!
        if freeingLabels.count>0{
            label  = freeingLabels.firstObject as! FLWBarrageViewLabel
            freeingLabels.removeObject(label);
        }
        else{
            label = FLWBarrageViewLabel(frame: CGRectMake(0, 0, 100, 20), contentStr: attString)
            self.addSubview(label)
        }
        label.contentString = attString
        var frame4label:CGRect = label.frame;
        var randomInt = arc4random()%10
        var originY = ((self.frame.size.height - 20)/10)*(CGFloat(randomInt))+20
        frame4label.origin.x = self.frame.size.width
        frame4label.origin.y = originY
        label.frame = frame4label
        
        frame4label.origin.x = -frame4label.size.width
        var during:NSTimeInterval = NSTimeInterval(self.frame.size.width/75)
        UIView.animateWithDuration(during, animations: { () -> Void in
            label.frame = frame4label
            }, completion: { (Bool) -> Void in
                self.freeingLabels.addObject(label)
        })
    }
}
