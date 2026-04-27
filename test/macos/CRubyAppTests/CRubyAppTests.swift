import XCTest
@testable import CRubyApp

final class CRubyAppTests: XCTestCase {
    func testEval() {
        XCTAssertEqual(3,   evalToInt("1 + 2"))
        XCTAssertEqual("3", evalToString("1 + 2"))
    }

    func testLoadPath() {
        let paths = evalToString("$LOAD_PATH.map {_1.sub %r|.*/Resources/?|, '/'}")
        for dir in [
            "/lib/ruby/rbconfig",
            "/lib/ruby/site_ruby",
            "/lib/ruby/vendor_ruby"
        ] {
            XCTAssertTrue(paths.contains(dir), "expected $LOAD_PATH to contain \(dir)")
        }
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
