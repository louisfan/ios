//
//  ViewController.swift
//  FLWBarrageView
//
//  Created by LW on 15/5/26.
//  Copyright (c) 2015年 FLW. All rights reserved.
//
import CoreText
import UIKit

class ViewController: UIViewController {
    @IBOutlet var  barrageView : FLWBarrageView?
    @IBOutlet var playerView:FLWMoviePlayer?
    var dialogueArray:NSMutableArray = NSMutableArray()
    
    func makeDialogues(){
        var dia :FLWBarrageObject = FLWBarrageObject(nick: "abc", cont: "哈哈哈")
        dialogueArray.addObject(dia)
        dia = FLWBarrageObject(nick: "🐶", cont: "有条狗")
        dialogueArray.addObject(dia)
        
        dia = FLWBarrageObject(nick: "🐱", cont: "有只猫猫猫猫猫那")
        dialogueArray.addObject(dia)
        
        dia = FLWBarrageObject(nick: "你猜你猜你猜你猜你猜", cont: "不猜")
        dialogueArray.addObject(dia)
        
        dia = FLWBarrageObject(nick: "猜猜猜猜猜猜猜", cont: "哈哈哈哈哈哈哈哈哈哈哈哈")
        dialogueArray.addObject(dia)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeDialogues()
        var timer :NSTimer = NSTimer(timeInterval: 1, target: self, selector: "addString", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
//        self.barrageView = FLWBarrageView(frame: self.view.bounds)
//        self.view.addSubview(self.barrageView!)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(animated: Bool) {
        self.playerView?.playWithUrl(NSURL(string: "http://pl.youku.com/playlist/m3u8?vid=66135362&type=mp4&ts=1405562225&keyframe=0&ep=dSaUH0yLVMwC5irdiT8bYiTldSYNXPgM9xyAgtRgb7ggTOg%3D&sid=7405562223921125871a2&token=3440&ctype=12&ev=1&oip=1883348934")!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addString(){
        var diaObj :FLWBarrageObject = self.dialogueArray.objectAtIndex(Int(Int(arc4random())%(self.dialogueArray.count))) as! FLWBarrageObject
        var attStr : NSMutableAttributedString = self.makeAttString(diaObj)
        
        self.barrageView?.addString(attStr)
    }
    func makeAttString(diaObj:FLWBarrageObject)->(NSMutableAttributedString){
        var string:NSString = (diaObj.userNick!.stringByAppendingString(":"))
        var content:NSString = diaObj.content as NSString
        string = string.stringByAppendingString(content as String)
        var attStr : NSMutableAttributedString = NSMutableAttributedString(string: string as NSString as String)
        attStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSMakeRange(0, diaObj.userNick.length))
        attStr.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(diaObj.userNick.length+1, content.length))
        return attStr
    }
    
}

