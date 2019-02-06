//
//  Earthquake.swift
//  earthquake-catalog-api
//
//  Created by Robby King on 2/2/19.
//  Copyright © 2019 Robby King. All rights reserved.
//

import Foundation

struct Earthquakes: Codable {
    let type: String
    let metadata: Metadata
    let features: [Feature]
    let bbox: [Double?]
}

struct Feature: Codable {
    let type: FeatureType
    let properties: Properties
    let geometry: Geometry
    let id: String
}

struct Geometry: Codable {
    let type: GeometryType
    let coordinates: [Double?]
}

enum GeometryType: String, Codable {
    case point = "Point"
}

struct Properties: Codable {
    let mag: Double?
    let place: String
    let time, updated, tz: Int
    let url, detail: String
    let felt: Int?
    let cdi, mmi: Double?
    let alert: String?
    let status: Status
    let tsunami, sig: Int
    let net: Net
    let code, ids, sources, types: String
    let nst: Int?
    let dmin: Double?
    let rms: Double?
    let gap: Double?
    let magType: MagType
    let type: PropertiesType
    let title: String
}

enum MagType: String, Codable {
//    case '2' = "2"
//    case '4' = "4"
    case H = "H"
    case lg = "lg"
    case m = "m"
    case ma = "ma"
    case mb = "mb"
    case MbLg = "MbLg"
    case mb_lg = "mb_lg"
    case mc = "mc"
    case Md = "Md"
    case md = "md"
    case mdl = "mdl"
    case Me = "Me"
    case mh = "mh"
    case Mi = "Mi"
    case ml = "ml"
    case mlg = "mlg"
    case mlr = "mlr"
    case Ms = "Ms"
    case ms_20 = "ms_20"
    case Mt = "Mt"
    case mun = "mun"
    case mw = "mw"
    case mwb = "mwb"
    case mwc = "mwc"
    case mwp = "mwp"
    case mwr = "mwr"
    case mww = "mww"
    case no = "no"
    case Unknown = "Unknown"
}

enum Net: String, Codable {
    case ak = "ak"
    case ci = "ci"
    case hv = "hv"
    case ld = "ld"
    case mb = "mb"
    case nc = "nc"
    case nm = "nm"
    case nn = "nn"
    case pr = "pr"
    case se = "se"
    case us = "us"
    case uu = "uu"
    case uw = "uw"
}

enum Status: String, Codable {
    case automatic = "automatic"
    case reviewed = "reviewed"
}

enum PropertiesType: String, Codable {
    case earthquake = "earthquake"
    case explosion = "explosion"
    case ice_quake = "ice quake"
    case quarry_blast = "quarry blast"
    case other_event = "other event"
}

enum FeatureType: String, Codable {
    case feature = "Feature"
}

struct Metadata: Codable {
    let generated: Int
    let url: String
    let title: String
    let status: Int
    let api: String
    let count: Int
}
