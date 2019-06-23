//
//  SharePostProtocol.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/10/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation

protocol SharePostProtocol {
    func clickedComments(post: SharePost)
    func clickedArticle(article: Article, post: SharePost?)
    func clickedMore(article: Article)
    func clickedGroup(group: FoggyGroup)
}
