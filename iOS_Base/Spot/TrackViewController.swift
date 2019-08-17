//
//  TrackViewController.swift
//  Spot
//
//  Created by Neo Ighodaro on 09/06/2019.
//  Copyright © 2019 Spot. All rights reserved.
//

import UIKit
import SwiftySound

class TrackViewController: UIViewController {

    var track: Song!
    var sound: Sound!
    
    var timer: Timer?
    var pausedAt: Int = 0

    @IBOutlet weak var coverImageWrapper: UIView!
    @IBOutlet weak var song: UILabel!
    @IBOutlet weak var duration: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Defaults
        duration.text = "00:00"
        song.text = "\(track?.artist ?? "Unknown Artist") - \(track?.title ?? "Unknown Title")"
        
        tickTimer()
        
        // Start time ticker
        timer = Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(tickTimer), userInfo: nil, repeats: true)
        
        // Make card-like
        coverImageWrapper.layer.cornerRadius = 20.0
        coverImageWrapper.layer.shadowColor = UIColor.gray.cgColor
        coverImageWrapper.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        coverImageWrapper.layer.shadowRadius = 12.0
        coverImageWrapper.layer.shadowOpacity = 0.7
        
        let imageView = UIImageView(image: UIImage(named: "cover"))
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20.0
        
        coverImageWrapper.addSubview(imageView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func tickTimer() {
        guard pausedAt <= 0 else { return }

        let minutes = Duration.instance.count / 60 % 60
        let seconds = Duration.instance.count % 60
        
        self.duration.text = String(format:"%02i:%02i", minutes, seconds)
    }
    
    @IBAction func playPauseButtonWasPressed(_ sender: Any) {
        if sound.playing {
            pausedAt = Duration.instance.count
            Duration.instance.freeze = true
            sound.pause()
        } else {
            Duration.instance.count = pausedAt
            Duration.instance.freeze = false
            pausedAt = 0
            sound.resume()
        }
    }

    @IBAction func minimiseButtonWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
