//
//  PlaylistTableViewController.swift
//  Spot
//
//  Created by Neo Ighodaro on 09/06/2019.
//  Copyright © 2019 Spot. All rights reserved.
//

import UIKit
import Alamofire
import SwiftySound
import PusherSwift

class Duration {
    var count = 0
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
    
    var pusher: Pusher!

    let deviceName = "iPhone"

    override func viewDidLoad() {
        super.viewDidLoad()

        populateTracks()
        prepareSound()
        pusherConnect()
        
        navigationItem.title = "Music"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    fileprivate func populateTracks() {
        Alamofire.request("http://localhost:3000/tracks").validate().responseData { res in
            guard res.result.isSuccess, let responseData = res.data else {
                return print("Failed to fetch data from the server")
            }
            
            let decoder = JSONDecoder()
            self.tracks = try! decoder.decode([Song].self, from: responseData)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Realtime

    fileprivate func pusherConnect() {
        pusher = Pusher(key: "e869e6bdd555fab59a98", options: PusherClientOptions(
            host: .cluster("mt1")
        ))
        pusher.connect()
        
        let channel = pusher.subscribe("spotmusic")
        
        let _ = channel.bind(eventName: "tick") { [unowned self] data in
            if let data = data as? [String: String] {
                self.handleTickEvent(data: data)
            }
        }
        
        let _ = channel.bind(eventName: "current") { [unowned self] data in
            if let data = data as? [String: Any] {
                self.handleCurrentEvent(data: data)
            }
        }
    }
    
    fileprivate func handleTickEvent(data: [String: String]) {
        guard data["device"] != deviceName else { return }
        guard let intent = data["intent"] else { return }
        
        switch intent {
        case "pause":
            pauseSound() // pause timer
        case "resume":
            resumeSound() // resume timer
        default: break
        }
    }
    
    fileprivate func handleCurrentEvent(data: [String: Any]) {
        guard data["device"] as? String != deviceName else { return }
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
        sound.pause()
    }
    
    fileprivate func resumeSound() {
        sound.resume()
    }
    
    // MARK: - Timer
    
    fileprivate func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(tickTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc fileprivate func tickTimer() {
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

        let isPlaying = track.isPlaying ?? false
        cell.textLabel?.text = "\(isPlaying ? "🎶" : "") \(track.title) - \(track.artist)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startTimer()
        
        if lastPlayed == nil {
            lastPlayed = tracks[indexPath.row]
        }
        
        if sound.playing == false || currentlyPlaying == nil || currentlyPlaying?.id != lastPlayed?.id {
            if let index = tracks.firstIndex(where: { $0.id == currentlyPlaying?.id }) {
                tracks[index].isPlaying = false
            }

            tracks[indexPath.row].isPlaying = true
            self.tableView.reloadData()
            
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
