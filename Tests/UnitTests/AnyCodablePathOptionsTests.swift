//
// Copyright 2023 Adobe. All rights reserved.
// This file is licensed to you under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy
// of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
// OF ANY KIND, either express or implied. See the License for the specific language
// governing permissions and limitations under the License.
//

import AEPServices
import AEPTestUtils
import Foundation
import XCTest

/// This test suite validates path options work as expected, and at a high level cover:
/// 1. General path option behavior - ex: subtree scope, multi options
/// 2. Specific option behavior - ex: KeyMustBeAbsent edge cases
class AnyCodablePathOptionsTests: XCTestCase, AnyCodableAsserts {
    // MARK: - General path options tests -
    // MARK: Path options
    func testSatisfiedPathOption_PassesWithArray() {
        let expectedJSONString = """
        [1]
        """

        let actualJSONString = """
        [2]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "[0]"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "[0]"))
        }
    }

    func testSatisfiedPathOption_PassesWithDictionary() {
        let expectedJSONString = """
        {
          "key0": 1
        }
        """

        let actualJSONString = """
        {
          "key0": 2
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "key0"))
        }
    }

    func testSatisfiedNestedPathOption_PassesWithDictionary() {
        let expectedJSONString = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": 1
          }
        }
        """

        let actualJSONString = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": 2
          }
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0-1.key1-0"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "key0-1.key1-0"))
        }
    }

    func testSatisfiedNestedPathOption_PassesWithArray() {
        let expectedJSONString = """
        [
          1,
          [
            1
          ]
        ]
        """

        let actualJSONString = """
        [
          1,
          [
            2
          ]
        ]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "[1][0]"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "[1][0]"))
        }
    }

    func testUnsatisfiedPathOption_FailsWithArray() {
        let expectedJSONString = """
        [1]
        """

        let actualJSONString = """
        [1, 2]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil))
        }
    }

    func testUnsatisfiedPathOption_FailsWithDictionary() {
        let expectedJSONString = """
        {
          "key0-0": 1
        }
        """

        let actualJSONString = """
        {
          "key0-0": 1,
          "key0-1": 1
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil))
        }
    }

    func testUnatisfiedNestedPathOption_FailsWithArray() {
        let expectedJSONString = """
        [
          1,
          [
            [1]
          ]
        ]
        """

        let actualJSONString = """
        [
          1,
          [
            [1, 2]
          ]
        ]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[1][0]"))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[1][0]"))
        }
    }

    func testUnsatisfiedNestedPathOption_FailsWithDictionary() {
        let expectedJSONString = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": {
              "key2-0": 1
            }
          }
        }
        """

        let actualJSONString = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": {
              "key2-0": 1,
              "key2-1": 1
            }
          }
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key0-1.key1-0"))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key0-1.key1-0"))
        }
    }

    func testNonexistentExpectedPathDoesNotAffectValidation_withArray() {
        let expectedJSONString = """
        [1]
        """

        let actualJSONString = """
        [1, 2]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[1]"))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[1]"))
    }

    func testNonexistentExpectedPathDoesNotAffectValidation_withDictionary() {
        let expectedJSONString = """
        {
          "key0-0": 1
        }
        """

        let actualJSONString = """
        {
          "key0-0": 1,
          "key0-1": 1
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key-doesnt-exist"))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key-doesnt-exist"))
    }

    func testInvalidExpectedPathDoesNotAffectValidation_withArray() {
        let expectedJSONString = """
        [1]
        """

        let actualJSONString = """
        [1, 2]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key0"))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key0"))
    }

    func testInvalidExpectedPathDoesNotAffectValidation_withDictionary() {
        let expectedJSONString = """
        {
          "key0-0": 1
        }
        """

        let actualJSONString = """
        {
          "key0-0": 1,
          "key0-1": 1
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[0]"))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[0]"))
    }

    // MARK: Arg format tests
    // NOTE: this is not testing Swift language variadic behavior (which is assumed to be correct), but
    // validating our own internal logic of how we pass variadic args to the main business logic
    func testVariadicAndArrayPathOptionsBehaveTheSame_withArray() {
        let expectedJSONString = """
        [1]
        """

        let actualJSONString = """
        [2]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "[0]"))
        assertExactMatch(expected: expected, actual: actual, pathOptions: [ValueTypeMatch(paths: "[0]")])

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "[0]"))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: [ValueExactMatch(paths: "[0]")])
        }
    }

    func testVariadicAndArrayPathOptionsBehaveTheSame_withDictionary() {
        let expectedJSONString = """
        {
          "key0": 1
        }
        """

        let actualJSONString = """
        {
          "key0": 2
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0"))
        assertExactMatch(expected: expected, actual: actual, pathOptions: [ValueTypeMatch(paths: "key0")])
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "key0"))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: [ValueExactMatch(paths: "key0")])
        }
    }

    func testVariadicAndArrayPathsBehaveTheSame_withArray() {
        let expectedJSONString = """
        [1, 1]
        """

        let actualJSONString = """
        [2, 2]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "[0]", "[1]"))
        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: ["[0]", "[1]"]))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "[0]", "[1]"))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: ["[0]", "[1]"]))
        }
    }

    func testVariadicAndArrayPathsBehaveTheSame_withDictionary() {
        let expectedJSONString = """
        {
          "key0": 1,
          "key1": 1
        }
        """

        let actualJSONString = """
        {
          "key0": 2,
          "key1": 2
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0", "key1"))
        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: ["key0", "key1"]))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "key0", "key1"))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: ["key0", "key1"]))
        }
    }

    // MARK: Scope tests (subtree, single node)
    func testSubtreeOptionPropagates_WithArray() {
        let expectedJSONString = """
        [
          1,
          [
            1
          ]
        ]
        """

        let actualJSONString = """
        [
          1,
          [
            2
          ]
        ]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: nil, scope: .subtree))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: nil, scope: .subtree))
        }
    }

    func testSubtreeOptionPropagates_WithDictionary() {
        let expectedJSONString = """
        {
          "key0-0": {
            "key1-0": 1
          }
        }
        """

        let actualJSONString = """
        {
          "key0-0": {
            "key1-0": 2
          }
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: nil, scope: .subtree))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: nil, scope: .subtree))
        }
    }

    func testSingleNodeOption_DoesNotPropagate_WithDictionary() {
        let expectedJSONString = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": 1
          }
        }
        """

        let actualJSONString = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": 2
          }
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: nil))
        }
        assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: nil))
    }

    func testSingleNodeOption_DoesNotPropagate_WithArray() {
        let expectedJSONString = """
        [
          1,
          [
            1
          ]
        ]
        """

        let actualJSONString = """
        [
          1,
          [
            2
          ]
        ]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: nil))
        }
        assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: nil))
    }

    // MARK: Multi-option tests
    func testPathOptions_OrderIndependence() {
        let expectedJSONString = """
        {
          "key0": 1,
          "key1": 1
        }
        """

        let actualJSONString = """
        {
          "key0": 2,
          "key1": 2
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0"), ValueTypeMatch(paths: "key1"))
        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key1"), ValueTypeMatch(paths: "key0"))
    }

    /// Validates that multiple options applied to the same key work as expected
    func testPathOptions_OverlappingConditions() {
        let expectedJSONString = """
        {
          "key1": [2]
        }
        """

        let actualJSONString = """
        {
          "key1": ["a", "b", 1]
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key1[0]"), WildcardMatch(paths: "key1[0]"))
    }

    // MARK: Multi-path tests
    func testMultiPath_whenArray() {
        let expectedJSONString = """
        [1, 1]
        """

        let actualJSONString = """
        [2, 2]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "[0]", "[1]"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "[0]", "[1]"))
        }
    }

    func testMultiPath_whenDictionary() {
        let expectedJSONString = """
        {
          "key0": 1,
          "key1": 1
        }
        """

        let actualJSONString = """
        {
          "key0": 2,
          "key1": 2
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0", "key1"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "key0", "key1"))
        }
    }

    func testMultiPath_SubtreePropagates_whenArray() {
        let expectedJSONString = """
        [
          [
            [1], [1]
          ],
          [
            [1], [1]
          ]
        ]
        """

        let actualJSONString = """
        [
          [
            [2], [2]
          ],
          [
            [2], [2]
          ]
        ]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "[0]", "[1]", scope: .subtree))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "[0]", "[1]", scope: .subtree))
        }
    }

    func testMultiPath_SubtreePropagates_whenDictionary() {
        let expectedJSONString = """
        {
          "key0-0": {
            "key1-0": {
              "key2-0": 1
            },
            "key1-1": {
              "key2-0": 1
            }
          },
          "key0-1": {
            "key1-0": {
              "key2-0": 1
            },
            "key1-1": {
              "key2-0": 1
            }
          }
        }
        """

        let actualJSONString = """
        {
          "key0-0": {
            "key1-0": {
              "key2-0": 2
            },
            "key1-1": {
              "key2-0": 2
            }
          },
          "key0-1": {
            "key1-0": {
              "key2-0": 2
            },
            "key1-1": {
              "key2-0": 2
            }
          }
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0-0", "key0-1", scope: .subtree))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "key0-0", "key0-1", scope: .subtree))
        }
    }

    // MARK: Config tests
    func testSetting_isActiveToFalse() {
        let expectedJSONString = """
        [1]
        """

        let actualJSONString = """
        [1, 2]
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil, isActive: false))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil, isActive: false))
    }

    // MARK: - Specific path option testing -
    // WildcardMatch
    // CollectionEqualCount
    // KeyMustBeAbsent
    // ValueExactMatch
    // ValueTypeMatch

    // MARK: KeyMustBeAbsent
    func testKeyMustBeAbsent_WithMissingKeyNames_Fails() {
        let expectedJSONString = """
        {}
        """

        let actualJSONString = """
        {
            "key1": 1
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!
        XCTExpectFailure("Validation should fail when key names not provided") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: nil))
        }
        XCTExpectFailure("Validation should fail when key names not provided") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: [nil], keyNames: []))
        }
        XCTExpectFailure("Validation should fail when key names not provided") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: nil))
        }
        XCTExpectFailure("Validation should fail when key names not provided") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: [nil], keyNames: []))
        }
    }

    func testKeyMustBeAbsent_WithSinglePath_Passes() {
        let expectedJSONString = """
        {}
        """

        let actualJSONString = """
        {
            "key1": 1
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: nil, keyNames: "key2"))
    }

    func testKeyMustBeAbsent_WithMultipleKeys_Passes() {
        let expectedJSONString = """
        {}
        """

        let actualJSONString = """
        {
            "key1": 1
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: nil, keyNames: "key2", "key3"))
    }

    func testKeyMustBeAbsent_Fails_WhenKeyPresent() {
        let expectedJSONString = """
        {}
        """

        let actualJSONString = """
        {
            "key1": 1
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        XCTExpectFailure("Validation should fail when key that must be absent is present in actual") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: nil, keyNames: "key1"))
        }
    }

    /// This test validates an edge case where the `KeyMustBeAbsent` option is used on a part of the `actual` JSON hierarchy that `expected`
    /// does **not** traverse.
    func testKeyMustBeAbsent_Fails_WhenKeyInDifferentHierarchy() {
        let expectedJSONString = """
        {
          "key1": 1
        }
        """

        let actualJSONString = """
        {
          "key1": 1,
          "key2": {
            "key3": 1
          }
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        XCTExpectFailure("Validation should fail when key that must be absent is present in actual") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: "key2", keyNames: "key3"))
        }
    }

    func testKeyMustBeAbsent_SubtreeOptionPropagates_WithDictionary() {
        let expectedJSONString = """
        {
          "key0-0": {
            "key1-0": {
              "key2-0":{
                "key3-0": 1
              }
            }
          }
        }
        """

        let actualJSONString = """
        {
          "key0-0": {
            "key1-0": {
              "key2-0":{
                "key3-0": 1,
                "disallowed-key": 1
              },
              "disallowed-key": 1
            }
          }
        }
        """
        let expected = getAnyCodable(expectedJSONString)!
        let actual = getAnyCodable(actualJSONString)!

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: nil, keyNames: "disallowed-key", scope: .subtree))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: nil, keyNames: "disallowed-key", scope: .subtree))
        }
    }
}
