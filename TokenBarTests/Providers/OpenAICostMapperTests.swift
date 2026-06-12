import XCTest
@testable import TokenBar

final class OpenAICostMapperTests: XCTestCase {
    func testMapsSpendAndUsagePercent() {
        let response = OpenAICostsResponse(data: [
            OpenAICostBucket(results: [
                OpenAICostResult(amount: OpenAICostAmount(value: "12.50", currency: "usd")),
                OpenAICostResult(amount: OpenAICostAmount(value: "7.50", currency: "usd")),
            ]),
        ])
        let accountID = UUID()

        let snapshot = OpenAICostMapper.map(
            response: response,
            accountID: accountID,
            providerID: "openai",
            monthlyBudgetUSD: 100
        )

        XCTAssertEqual(snapshot.providerName, "OpenAI")
        XCTAssertEqual(snapshot.spendAmount, Decimal(string: "20"))
        XCTAssertEqual(snapshot.usagePercent ?? -1, 20, accuracy: 0.001)
        XCTAssertEqual(snapshot.quotaLimit ?? -1, 100)
    }

    func testOmitsUsagePercentWithoutBudget() {
        let response = OpenAICostsResponse(data: [
            OpenAICostBucket(results: [
                OpenAICostResult(amount: OpenAICostAmount(value: "5.00", currency: "usd")),
            ]),
        ])

        let snapshot = OpenAICostMapper.map(
            response: response,
            accountID: UUID(),
            providerID: "openai",
            monthlyBudgetUSD: nil
        )

        XCTAssertNil(snapshot.usagePercent)
        XCTAssertNil(snapshot.quotaLimit)
    }
}
