//
//  FLWMoviePlayer.swift
//  FLWBarrageView
//
//  Created by LW on 15/5/27.
//  Copyright (c) 2015年 FLW. All rights reserved.
//

import UIKit
import AVFoundation
class FLWMoviePlayer: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func playWithUrl(url:NSURL){
        var player:AVPlayer = AVPlayer(URL: url)
        var playerLayer:AVPlayerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        player.play()
    }
}
