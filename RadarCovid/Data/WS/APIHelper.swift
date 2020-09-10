//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import Foundation

public struct APIHelper {
    public static func rejectNil(_ source: [String: Any?]) -> [String: Any]? {
        let destination = source.reduce(into: [String: Any]()) { (result, item) in
            if let value = item.value {
                result[item.key] = value
            }
        }

        if destination.isEmpty {
            return nil
        }
        return destination
    }

    public static func rejectNilHeaders(_ source: [String: Any?]) -> [String: String] {
        return source.reduce(into: [String: String]()) { (result, item) in
            if let collection = item.value as? [Any?] {
                result[item.key] = collection.compactMap { value in
                    guard let value = value else { return nil }
                    return "\(value)"
                }
                .joined(separator: ",")
            } else if let value: Any = item.value {
                result[item.key] = "\(value)"
            }
        }
    }

    public static func convertBoolToString(_ source: [String: Any]?) -> [String: Any]? {
        guard let source = source else {
            return nil
        }

        return source.reduce(into: [String: Any](), { (result, item) in
            switch item.value {
            case let finalItem as Bool:
                result[item.key] = finalItem.description
            default:
                result[item.key] = item.value
            }
        })
    }

    public static func mapValuesToQueryItems(_ source: [String: Any?]) -> [URLQueryItem]? {
        let destination = source.filter({ $0.value != nil}).reduce(into: [URLQueryItem]()) { (result, item) in
            if let collection = item.value as? [Any?] {
                let value = collection.compactMap { value in
                    guard let value = value else { return nil }
                    return "\(value)"
                }
                .joined(separator: ",")
                result.append(URLQueryItem(name: item.key, value: value))
            } else if let value = item.value {
                result.append(URLQueryItem(name: item.key, value: "\(value)"))
            }
        }

        if destination.isEmpty {
            return nil
        }
        return destination
    }
}
