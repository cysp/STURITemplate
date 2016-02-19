//  Copyright (c) 2014 Scott Talbot. All Rights Reserved

import Foundation
import STURITemplate


let u = URL(string: "http://example.org/")!

let searchTemplate = try STURITemplate(string: "address{?formatted_address}")
let detailTemplate = try STURITemplate(string: "address/{id}")

searchTemplate.variableNames

let searchRelativeString: String = try searchTemplate.expand(variables: ["formatted_address": "105 Campbell St"])
let searchRelativeURL: URL = try searchTemplate.expand(variables: ["formatted_address": "105 Campbell St"])
let detailRelativeURL: URL = try detailTemplate.expand(variables: ["id": "abcdef"])

let searchURL = URL(string: searchRelativeURL.absoluteString!, relativeTo: u)!
searchURL.absoluteString

let detailURL = URL(string: detailRelativeURL.absoluteString!, relativeTo: u)!
detailURL.absoluteString


let searchTemplate2: STURITemplate;
do {
    searchTemplate2 = try STURITemplate(string: "address{?formatted_address")
} catch (let error as STURITemplateError) {
    error
} catch {
    error
}
