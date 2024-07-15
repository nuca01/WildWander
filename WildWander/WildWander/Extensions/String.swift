//
//  String.swift
//  WildWander
//
//  Created by nuca on 15.07.24.
//

import Foundation
import CoreLocation

extension String {
    func decodePolyline() -> [CLLocationCoordinate2D]? {
        var coordinates: [CLLocationCoordinate2D] = []
        guard let data = self.data(using: .utf8) else { return nil }
        let byteArray = [UInt8](data)
        var index = 0
        let length = byteArray.count
        var latitude = 0
        var longitude = 0

        while index < length {
            var b = 0
            var shift = 0
            var result = 0

            repeat {
                b = Int(byteArray[index]) - 63
                index += 1
                result |= (b & 0x1f) << shift
                shift += 5
            } while b >= 0x20

            let deltaLatitude = (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
            latitude += deltaLatitude

            shift = 0
            result = 0

            repeat {
                b = Int(byteArray[index]) - 63
                index += 1
                result |= (b & 0x1f) << shift
                shift += 5
            } while b >= 0x20

            let deltaLongitude = (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
            longitude += deltaLongitude

            let coordinate = CLLocationCoordinate2D(latitude: Double(latitude) / 1e5, longitude: Double(longitude) / 1e5)
            coordinates.append(coordinate)
        }

        return coordinates
    }
}
