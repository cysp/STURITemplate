//  Copyright (c) 2014 Scott Talbot. All Rights Reserved

import STURITemplate


let u = NSURL(string: "http://example.org/")

let searchTemplate = STURITemplate(template: "address{?formatted_address}")
let detailTemplate = STURITemplate(template: "address/{id}")

searchTemplate.variableNames

let searchRelativeURL = searchTemplate.urlByExpandingWithVariables(["formatted_address": "105 Campbell St"])
let detailRelativeURL = detailTemplate.urlByExpandingWithVariables(["id": "abcdef"])

let searchURL = NSURL(string: searchRelativeURL.absoluteString!, relativeToURL: u)
searchURL.absoluteString!

let detailURL = NSURL(string: detailRelativeURL.absoluteString!, relativeToURL: u)
detailURL.absoluteString!
