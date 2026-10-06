import Foundation

enum CursorPersonalSessionValidator {
    static func isExpired(token: String, now: Date = .now) -> Bool {
        guard let expiration = jwtExpirationDate(from: token) else {
            return false
        }
        return expiration <= now
    }

    private static func jwtExpirationDate(from token: String) -> Date? {
        let jwt = extractJWT(from: token)
        let segments = jwt.split(separator: ".")
        guard segments.count >= 2 else { return nil }

        var payload = String(segments[1])
        payload = payload.padding(
            toLength: ((payload.count + 3) / 4) * 4,
            withPad: "=",
            startingAt: 0
        )

        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = json["exp"] as? TimeInterval else {
            return nil
        }

        return Date(timeIntervalSince1970: exp)
    }

    private static func extractJWT(from token: String) -> String {
        if let range = token.range(of: "%3A%3A") {
            return String(token[range.upperBound...])
        }
        if let range = token.range(of: "::") {
            return String(token[range.upperBound...])
        }
        return token
    }
}
