import XCTest
@testable import TokenBar

final class CursorTeamSpendMapperTests: XCTestCase {
    func testMapsSpendAndUsagePercent() {
        let member = CursorTeamMemberSpend(
            userId: 1,
            name: "Alex",
            email: "alex@company.com",
            role: "member",
            spendCents: 2_450.12,
            overallSpendCents: 2_450.12,
            monthlyLimitDollars: 200
        )
        let accountID = UUID()

        let snapshot = CursorTeamSpendMapper.map(
            member: member,
            accountID: accountID,
            providerID: "cursor-team"
        )

        XCTAssertEqual(snapshot.providerName, "Cursor")
        XCTAssertEqual(snapshot.spendAmount, Decimal(string: "24.5012"))
        XCTAssertEqual(snapshot.usagePercent, 12.2506, accuracy: 0.001)
        XCTAssertEqual(snapshot.quotaLimit, 20_000)
    }

    func testSelectMemberPrefersConfiguredEmail() {
        let response = CursorTeamSpendResponse(teamMemberSpend: [
            CursorTeamMemberSpend(
                userId: 1,
                name: "Alex",
                email: "alex@company.com",
                role: "member",
                spendCents: 100,
                overallSpendCents: 100,
                monthlyLimitDollars: nil
            ),
            CursorTeamMemberSpend(
                userId: 2,
                name: "Sam",
                email: "sam@company.com",
                role: "owner",
                spendCents: 200,
                overallSpendCents: 200,
                monthlyLimitDollars: nil
            ),
        ])

        let member = CursorTeamSpendMapper.selectMember(
            from: response,
            preferredEmail: "sam@company.com"
        )

        XCTAssertEqual(member?.email, "sam@company.com")
    }
}
