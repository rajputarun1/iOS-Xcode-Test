import XCTest
@testable import MyApp

final class MyAppTests: XCTestCase {

    func testMessage() {

        let app = MyApp()

        XCTAssertEqual(
            app.message(),
            "Hello from Xcode on macOS!"
        )
    }
}
