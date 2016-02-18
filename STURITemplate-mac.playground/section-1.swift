//  Copyright (c) 2014 Scott Talbot. All Rights Reserved

import Foundation
import STURITemplate


let u = NSURL(string: "http://example.org/")

let searchTemplate: STURITemplate
let detailTemplate: STURITemplate
do {
    searchTemplate = try STURITemplate(string: "address{?formatted_address}")
    detailTemplate = try STURITemplate(string: "address/{id}")

    do {
        let f = try STURITemplate(string: "{")
    } catch (let error) {
        error
    }

    searchTemplate.variableNames

    let searchRelativeURL = searchTemplate.urlByExpandingWithVariables(["formatted_address": "105 Campbell St"])!
    let detailRelativeURL = detailTemplate.urlByExpandingWithVariables(["id": "abcdef"])!

    let searchURL = NSURL(string: searchRelativeURL.absoluteString, relativeToURL: u)!
    searchURL.absoluteString
    
    let detailURL = NSURL(string: detailRelativeURL.absoluteString, relativeToURL: u)!
    detailURL.absoluteString
} catch (let error) {
    error
}
