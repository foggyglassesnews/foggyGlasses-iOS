//
//  SideMenuProtocol.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/10/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation

protocol SideMenuProtocol {
    func clickedNewGroup()
    func clickedPendingGroup(group: FoggyGroup)
    func clickedGroup(group: FoggyGroup)
}
