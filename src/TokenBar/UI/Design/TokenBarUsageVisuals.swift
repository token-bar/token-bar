import SwiftUI

enum TokenBarUsageColor {
    static func color(forPercent percent: Double) -> Color {
        switch percent {
        case 90...: .red
        case 75..<90: .orange
        case 50..<75: .yellow
        default: .green
        }
    }

    static func gradient(forPercent percent: Double) -> LinearGradient {
        let base = color(forPercent: percent)
        return LinearGradient(
            colors: [base.opacity(0.85), base],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct TokenBarUsageRing: View {
    let percent: Double
    var diameter: CGFloat = 88
    var lineWidth: CGFloat = 9

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary.opacity(0.8), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(percent / 100, 0), 1))
                .stroke(
                    TokenBarUsageColor.color(forPercent: percent),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("\(Int(percent.rounded()))")
                    .font(.title.weight(.bold))
                    .monospacedDigit()
                Text("%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: diameter, height: diameter)
        .accessibilityLabel("\(Int(percent.rounded())) percent used")
    }
}

struct TokenBarUsageProgressTrack: View {
    let fraction: Double
    var percent: Double?
    var height: CGFloat = 8

    private var clampedFraction: Double {
        min(max(fraction, 0), 1)
    }

    private var tintPercent: Double {
        percent ?? (clampedFraction * 100)
    }

    var body: some View {
        GeometryReader { geometry in
            Capsule()
                .fill(.quaternary.opacity(0.65))

            Capsule()
                .fill(TokenBarUsageColor.gradient(forPercent: tintPercent))
                .frame(width: geometry.size.width * clampedFraction)
        }
        .frame(height: height)
        .accessibilityLabel("Usage progress")
        .accessibilityValue("\(Int(tintPercent.rounded())) percent")
    }
}

struct TokenBarMetricPill: View {
    let title: String
    let value: String
    var tint: Color = .secondary

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct TokenBarProviderUsageChart: View {
    let items: [(providerID: String, providerName: String, percent: Double)]

    private var maxPercent: Double {
        max(items.map(\.percent).max() ?? 1, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(items, id: \.providerID) { item in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(TokenBarUsageColor.gradient(forPercent: item.percent))
                        .frame(width: 28, height: barHeight(for: item.percent))

                    ProviderBrandIcon(providerID: item.providerID, size: 12)
                        .opacity(0.95)

                    Text(shortName(item.providerName))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(item.providerName) \(Int(item.percent.rounded())) percent")
            }
        }
        .frame(height: 120)
    }

    private func barHeight(for percent: Double) -> CGFloat {
        let normalized = percent / maxPercent
        return max(12, CGFloat(normalized) * 72)
    }

    private func shortName(_ name: String) -> String {
        name.split(separator: " ").first.map(String.init) ?? name
    }
}
