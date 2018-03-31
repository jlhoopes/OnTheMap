//
//  OTMBlackBox.swift
//  OnTheMap
//
//  Created by Jason Hoopes on 3/30/18.
//  Copyright © 2018 Jason Hoopes. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
