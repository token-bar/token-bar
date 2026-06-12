import XCTest
@testable import TokenBar

final class AnthropicCostMapperTests: XCTestCase {
    func testMapsSpendFromCentsAndUsagePercent() {
        let response = AnthropicCostReportResponse(data: [
            AnthropicCostBucket(results: [
                AnthropicCostResult(amount: "1250"),
                AnthropicCostResult(amount: "750"),
            ]),
        ])
        let accountID = UUID()

        let snapshot = AnthropicCostMapper.map(
            response: response,
            accountID: accountID,
            providerID: "anthropic",
            monthlyBudgetUSD: 50
        )

        XCTAssertEqual(snapshot.providerName, "Anthropic")
        XCTAssertEqual(snapshot.spendAmount, Decimal(string: "20"))
        XCTAssertEqual(snapshot.usagePercent ?? -1, 40, accuracy: 0.001)
        XCTAssertEqual(snapshot.quotaLimit ?? -1, 50)
    }

    func testOmitsUsagePercentWithoutBudget() {
        let response = AnthropicCostReportResponse(data: [
            AnthropicCostBucket(results: [
                AnthropicCostResult(amount: "500"),
            ]),
        ])

        let snapshot = AnthropicCostMapper.map(
            response: response,
            accountID: UUID(),
            providerID: "anthropic",
            monthlyBudgetUSD: nil
        )

        XCTAssertEqual(snapshot.spendAmount, Decimal(string: "5"))
        XCTAssertNil(snapshot.usagePercent)
    }
}
