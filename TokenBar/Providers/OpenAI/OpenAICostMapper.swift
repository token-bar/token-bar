import Foundation

enum OpenAICostMapper {
    static func map(
        response: OpenAICostsResponse,
        accountID: UUID,
        providerID: String,
        monthlyBudgetUSD: Double?,
        capturedAt: Date = .now
    ) -> UsageSnapshot {
        let spend = totalSpend(from: response)
        let usagePercent = SpendUsageMapper.usagePercent(
            spend: spend,
            monthlyBudgetUSD: monthlyBudgetUSD
        )

        return UsageSnapshot(
            accountID: accountID,
            providerID: providerID,
            providerName: "OpenAI",
            usagePercent: usagePercent,
            creditsRemaining: nil,
            spendAmount: spend,
            spendCurrency: "USD",
            quotaUsed: monthlyBudgetUSD.map { _ in (spend as NSDecimalNumber).doubleValue },
            quotaLimit: monthlyBudgetUSD,
            capturedAt: capturedAt
        )
    }

    static func totalSpend(from response: OpenAICostsResponse) -> Decimal {
        let values = response.data.flatMap { bucket in
            bucket.results?.compactMap(\.amount?.value) ?? []
        }
        return values.reduce(Decimal.zero) { partial, raw in
            partial + (Decimal(string: raw) ?? .zero)
        }
    }
}

enum SpendUsageMapper {
    static func usagePercent(spend: Decimal, monthlyBudgetUSD: Double?) -> Double? {
        guard let monthlyBudgetUSD, monthlyBudgetUSD > 0 else {
            return nil
        }
        let spendValue = (spend as NSDecimalNumber).doubleValue
        return min((spendValue / monthlyBudgetUSD) * 100, 100)
    }
}
