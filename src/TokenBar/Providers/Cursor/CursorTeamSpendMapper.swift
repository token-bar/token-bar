import Foundation

enum CursorTeamSpendMapper {
    static func map(
        member: CursorTeamMemberSpend,
        accountID: UUID,
        providerID: String,
        capturedAt: Date = .now
    ) -> UsageSnapshot {
        let spendDollars = dollars(fromCents: member.overallSpendCents)
        let usagePercent = usagePercent(for: member)

        return UsageSnapshot(
            accountID: accountID,
            providerID: providerID,
            providerName: "Cursor",
            usagePercent: usagePercent,
            creditsRemaining: nil,
            spendAmount: spendDollars,
            spendCurrency: "USD",
            quotaUsed: member.overallSpendCents,
            quotaLimit: monthlyLimitCents(for: member),
            capturedAt: capturedAt
        )
    }

    static func selectMember(
        from response: CursorTeamSpendResponse,
        preferredEmail: String?
    ) -> CursorTeamMemberSpend? {
        let members = response.teamMemberSpend
        guard !members.isEmpty else { return nil }

        if let preferredEmail,
           let match = members.first(where: {
               $0.email?.caseInsensitiveCompare(preferredEmail) == .orderedSame
           }) {
            return match
        }

        return members.first
    }

    private static func usagePercent(for member: CursorTeamMemberSpend) -> Double? {
        guard let limitDollars = member.monthlyLimitDollars, limitDollars > 0 else {
            return nil
        }
        let limitCents = limitDollars * 100
        let percent = (member.overallSpendCents / limitCents) * 100
        return min(max(percent, 0), 100)
    }

    private static func monthlyLimitCents(for member: CursorTeamMemberSpend) -> Double? {
        member.monthlyLimitDollars.map { $0 * 100 }
    }

    /// Converts API cent values (JSON `Double`) to dollars without binary floating-point drift.
    private static func dollars(fromCents cents: Double) -> Decimal {
        Decimal(string: String(format: "%.4f", cents / 100)) ?? Decimal(cents / 100)
    }
}
