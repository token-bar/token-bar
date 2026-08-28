import Foundation

enum AnthropicCostMapper {
    static func map(
        response: AnthropicCostReportResponse,
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
            providerName: "Anthropic",
            usagePercent: usagePercent,
            creditsRemaining: nil,
            spendAmount: spend,
            spendCurrency: "USD",
            quotaUsed: monthlyBudgetUSD.map { _ in (spend as NSDecimalNumber).doubleValue },
            quotaLimit: monthlyBudgetUSD,
            capturedAt: capturedAt
        )
    }

    static func totalSpend(from response: AnthropicCostReportResponse) -> Decimal {
        let centValues = response.data.flatMap { bucket in
            bucket.results?.compactMap(\.amount) ?? []
        }
        let totalCents = centValues.reduce(Decimal.zero) { partial, raw in
            partial + (Decimal(string: raw) ?? .zero)
        }
        return totalCents / 100
    }
}
