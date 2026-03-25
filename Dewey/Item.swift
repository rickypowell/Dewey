//
//  Item.swift
//  Dewey
//
//  Created by Ricky Powell on 3/25/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
