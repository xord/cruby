import XCTest
@testable import CRubyApp

final class CRubyAppTests: XCTestCase {
    func testEval() {
        XCTAssertEqual(3,   evalToInt("1 + 2"))
        XCTAssertEqual("3", evalToString("1 + 2"))
    }

    func testLoadPath() {
        XCTAssertEqual(
            "[" +
            "\"/\", " +
            "\"/lib/ruby/rbconfig\", " +
            "\"/lib/ruby/site_ruby/3.2.0\", " +
            "\"/lib/ruby/site_ruby\", " +
            "\"/lib/ruby/vendor_ruby/3.2.0\", " +
            "\"/lib/ruby/vendor_ruby\", " +
            "\"/lib/ruby/3.2.0\"" +
            "]",
            evalToString("$LOAD_PATH.map {_1.sub %r|.*/Resources/?|, '/'}"))
    }

    func testRequire() {
        XCTAssertTrue(evalToBool("require 'stringio'"))
        XCTAssertFalse(evalToBool("require 'stringio'"))
    }

    private func eval(_ str: String) -> CRBValue {
        CRuby.evaluate(str)
    }

    private func evalToBool(_ str: String) -> Bool {
        eval(str).toBOOL()
    }

    private func evalToInt(_ str: String) -> Int {
        eval(str).toInteger()
    }

    private func evalToString(_ str: String) -> String {
        eval(str).toString()
    }
}
