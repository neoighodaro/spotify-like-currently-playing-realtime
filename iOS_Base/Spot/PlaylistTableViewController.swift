//
//  PlaylistTableViewController.swift
//  Spot
//
//  Created by Neo Ighodaro on 09/06/2019.
//  Copyright © 2019 Spot. All rights reserved.
//

import UIKit
import SwiftySound

class Duration {
    var count = 0
    var freeze = false
    static let instance = Duration.init()
    private init() {}
}

class PlaylistTableViewController: UITableViewController {
    
    var sound: Sound!
    var tracks: [Song] = []

    var lastPlayed: Song?
    var currentlyPlaying: Song?

    var duration = 0
    var timer: Timer?
    var timerStarted = false
    
    let deviceName = "iPhone"
    var playingDevice: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        populateTracks()
        prepareSound()
        
        navigationItem.title = "Music"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    fileprivate func populateTracks() {
        tracks.append(
            Song(id: 1, title: "Sample", cover: "https://via.placeholder.com/500x500", duration: 195, artist: "Neo", isPlaying: false)
        )
    }
    
    // MARK: - Sound controls
    
    fileprivate func prepareSound() {
        guard let url = Bundle.main.url(forResource: "jingle", withExtension: "mp3") else { return }

        sound = Sound(url: url)
    }
    
    fileprivate func playSound() {
        if sound.playing {
            sound.stop()
        }
        
        sound.play(numberOfLoops: 0) { [unowned self] finished in
            if finished {
                self.resetTimer()
                self.killTimer()
                self.currentlyPlaying = nil
            }
        }
    }
    
    fileprivate func pauseSound() {
        if !sound.paused {
            sound.pause()
        }
    }
    
    fileprivate func resumeSound() {
        if sound.paused {
            sound.resume()
        }
    }
    
    // MARK: - Timer
    
    fileprivate func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(tickTimer), userInfo: nil, repeats: true)
        }
    }
    
    fileprivate func setTimer(count: Int) {
        Duration.instance.count = count
    }
    
    @objc fileprivate func tickTimer() {
        if Duration.instance.freeze {
            return
        }

        Duration.instance.count += 1
        
        if Duration.instance.count > 1000 {
            killTimer()
        }
    }
    
    fileprivate func resetTimer() {
        Duration.instance.count = 0
    }
    
    fileprivate func killTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = tracks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath)

        cell.textLabel?.text = "🎶 \(track.title) - \(track.artist)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startTimer()
        
        if lastPlayed == nil {
            lastPlayed = tracks[indexPath.row]
        }
        
        if sound.playing == false || currentlyPlaying == nil || currentlyPlaying?.id != lastPlayed?.id {
            lastPlayed = currentlyPlaying
            currentlyPlaying = tracks[indexPath.row]
            
            playSound()
            resetTimer()
            
            if timerStarted == false {
                timer?.fire()
                timerStarted = true
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? TrackViewController else { return }
        
        if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
            vc.track = tracks[indexPath.row]
        }
        
        vc.sound = sound
    }
}
