//
//  Song.swift
//  Spot
//
//  Created by Neo Ighodaro on 09/06/2019.
//  Copyright © 2019 Spot. All rights reserved.
//

import Foundation

struct Song: Codable {
    let id: Int
    let title: String
    let cover: String
    let duration: Int
    let artist: String
}
