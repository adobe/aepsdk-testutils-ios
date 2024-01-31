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
        let expected = """
        [1]
        """

        let actual = """
        [2]
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "[0]"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "[0]"))
        }
    }

    func testSatisfiedPathOption_PassesWithDictionary() {
        let expected = """
        {
          "key0": 1
        }
        """

        let actual = """
        {
          "key0": 2
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "key0"))
        }
    }

    func testSatisfiedNestedPathOption_PassesWithDictionary() {
        let expected = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": 1
          }
        }
        """

        let actual = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": 2
          }
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0-1.key1-0"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "key0-1.key1-0"))
        }
    }

    func testSatisfiedNestedPathOption_PassesWithArray() {
        let expected = """
        [
          1,
          [
            1
          ]
        ]
        """

        let actual = """
        [
          1,
          [
            2
          ]
        ]
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "[1][0]"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "[1][0]"))
        }
    }

    func testUnsatisfiedPathOption_FailsWithArray() {
        let expected = """
        [1]
        """

        let actual = """
        [1, 2]
        """

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil))
        }
    }

    func testUnsatisfiedPathOption_UsingDefaultPathOption_FailsWithArray() {
        let expected = """
        [1]
        """

        let actual = """
        [1, 2]
        """

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount())
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount())
        }
    }

    func testUnsatisfiedPathOption_FailsWithDictionary() {
        let expected = """
        {
          "key0-0": 1
        }
        """

        let actual = """
        {
          "key0-0": 1,
          "key0-1": 1
        }
        """

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil))
        }
    }

    func testUnatisfiedNestedPathOption_FailsWithArray() {
        let expected = """
        [
          1,
          [
            [1]
          ]
        ]
        """

        let actual = """
        [
          1,
          [
            [1, 2]
          ]
        ]
        """

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[1][0]"))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[1][0]"))
        }
    }

    func testUnsatisfiedNestedPathOption_FailsWithDictionary() {
        let expected = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": {
              "key2-0": 1
            }
          }
        }
        """

        let actual = """
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

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key0-1.key1-0"))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key0-1.key1-0"))
        }
    }

    func testNonexistentExpectedPathDoesNotAffectValidation_withArray() {
        let expected = """
        [1]
        """

        let actual = """
        [1, 2]
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[1]"))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[1]"))
    }

    func testNonexistentExpectedPathDoesNotAffectValidation_withDictionary() {
        let expected = """
        {
          "key0-0": 1
        }
        """

        let actual = """
        {
          "key0-0": 1,
          "key0-1": 1
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key-doesnt-exist"))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key-doesnt-exist"))
    }

    func testInvalidExpectedPathDoesNotAffectValidation_withArray() {
        let expected = """
        [1]
        """

        let actual = """
        [1, 2]
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key0"))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key0"))
    }

    func testInvalidExpectedPathDoesNotAffectValidation_withDictionary() {
        let expected = """
        {
          "key0-0": 1
        }
        """

        let actual = """
        {
          "key0-0": 1,
          "key0-1": 1
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[0]"))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "[0]"))
    }

    func testOrderDependentOptionOverride() {
        let expected = """
        {
          "key1": 1
        }
        """

        let actual = """
        {
          "key1": 1,
          "key2": 2
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(), CollectionEqualCount(isActive: false))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(), CollectionEqualCount(isActive: false))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(isActive: false), CollectionEqualCount())
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(isActive: false), CollectionEqualCount())
        }
    }

    func testOrderDependentOptionOverride_WithSpecificKey() {
        let expected = """
        {
          "key1": [1]
        }
        """

        let actual = """
        {
          "key1": [1,2]
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key1"), CollectionEqualCount(paths: "key1", isActive: false))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key1"), CollectionEqualCount(paths: "key1", isActive: false))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key1", isActive: false), CollectionEqualCount(paths: "key1"))
        }
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: "key1", isActive: false), CollectionEqualCount(paths: "key1"))
        }
    }

    // MARK: Arg format tests
    // NOTE: this is not testing Swift language variadic behavior (which is assumed to be correct), but
    // validating our own internal logic of how we pass variadic args to the main business logic
    func testVariadicAndArrayPathOptionsBehaveTheSame_withArray() {
        let expected = """
        [1]
        """

        let actual = """
        [2]
        """

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
        let expected = """
        {
          "key0": 1
        }
        """

        let actual = """
        {
          "key0": 2
        }
        """

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
        let expected = """
        [1, 1]
        """

        let actual = """
        [2, 2]
        """

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
        let expected = """
        {
          "key0": 1,
          "key1": 1
        }
        """

        let actual = """
        {
          "key0": 2,
          "key1": 2
        }
        """

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
        let expected = """
        [
          1,
          [
            1
          ]
        ]
        """

        let actual = """
        [
          1,
          [
            2
          ]
        ]
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: nil, scope: .subtree))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: nil, scope: .subtree))
        }
    }

    func testSubtreeOptionPropagates_WithDictionary() {
        let expected = """
        {
          "key0-0": {
            "key1-0": 1
          }
        }
        """

        let actual = """
        {
          "key0-0": {
            "key1-0": 2
          }
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: nil, scope: .subtree))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: nil, scope: .subtree))
        }
    }

    func testSingleNodeOption_DoesNotPropagate_WithDictionary() {
        let expected = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": 1
          }
        }
        """

        let actual = """
        {
          "key0-0": 1,
          "key0-1": {
            "key1-0": 2
          }
        }
        """

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: nil))
        }
        assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: nil))
    }

    func testSingleNodeOption_DoesNotPropagate_WithArray() {
        let expected = """
        [
          1,
          [
            1
          ]
        ]
        """

        let actual = """
        [
          1,
          [
            2
          ]
        ]
        """

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: nil))
        }
        assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: nil))
    }

    func testSubtreeOption_OverriddenBySingleNode() {
        let expected = """
        {
          "key0-0": {
            "key1-0": {
              "key2-0": 1
            }
          }
        }
        """

        let actual = """
        {
          "key0-0": {
            "key1-0": {
              "key2-0": 1
            },
            "key1-1": 1
          }
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(scope: .subtree), CollectionEqualCount(paths: "key0-0", isActive: false))
        // Sanity check: Override without `.singleNode` should fail
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(scope: .subtree))
        }
    }

    func testSubtreeOption_OverriddenAtDifferentLevels() {
        let expected = """
        {
          "key0-0": {
            "key1-0": {
              "key2-0": 1
            }
          }
        }
        """

        let actual = """
        {
          "key0-0": {
            "key1-0": {
              "key2-0": 1,
              "key2-1": 1
            },
            "key1-1": 1
          }
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(scope: .subtree), CollectionEqualCount(paths: "key0-0", isActive: false, scope: .subtree))
        // Sanity check: Override without `.subtree` should fail
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(scope: .subtree), CollectionEqualCount(paths: "key0-0", isActive: false))
        }
    }

    /// Validates that when constructing the node tree, subtree values are not improperly overridden or reset to their default values..
    func testSubtreeValues_NotIncorrectlyOverridden_WhenSettingMultiple() {
        let expected = """
        {
          "key1": {
            "key2": {
              "key3": [
                {
                  "key4": "STRING_TYPE"
                }
              ]
            }
          }
        }
        """

        let actual = """
        {
          "key1": {
            "key2": {
              "key3": [
                {
                  "key4": "abc"
                }
              ]
            }
          }
        }
        """

        assertExactMatch(
            expected: expected,
            actual: actual,
            pathOptions:
                ValueTypeMatch(paths: "key1.key2.key3", scope: .subtree),
            CollectionEqualCount(scope: .subtree)
        )

        assertExactMatch(
            expected: expected,
            actual: actual,
            pathOptions:
                CollectionEqualCount(scope: .subtree),
            ValueTypeMatch(paths: "key1.key2.key3", scope: .subtree)
        )
    }

    // MARK: Multi-option tests
    func testPathOptions_OrderIndependence() {
        let expected = """
        {
          "key0": 1,
          "key1": 1
        }
        """

        let actual = """
        {
          "key0": 2,
          "key1": 2
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0"), ValueTypeMatch(paths: "key1"))
        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key1"), ValueTypeMatch(paths: "key0"))
    }

    /// Validates that multiple options applied to the same key work as expected
    func testPathOptions_OverlappingConditions() {
        let expected = """
        {
          "key1": [2]
        }
        """

        let actual = """
        {
          "key1": ["a", "b", 1]
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key1[0]"), WildcardMatch(paths: "key1[0]"))
    }

    // MARK: Multi-path tests
    func testMultiPath_whenArray() {
        let expected = """
        [1, 1]
        """

        let actual = """
        [2, 2]
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "[0]", "[1]"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "[0]", "[1]"))
        }
    }

    func testMultiPath_whenDictionary() {
        let expected = """
        {
          "key0": 1,
          "key1": 1
        }
        """

        let actual = """
        {
          "key0": 2,
          "key1": 2
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0", "key1"))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "key0", "key1"))
        }
    }

    func testMultiPath_SubtreePropagates_whenArray() {
        let expected = """
        [
          [
            [1], [1]
          ],
          [
            [1], [1]
          ]
        ]
        """

        let actual = """
        [
          [
            [2], [2]
          ],
          [
            [2], [2]
          ]
        ]
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "[0]", "[1]", scope: .subtree))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "[0]", "[1]", scope: .subtree))
        }
    }

    func testMultiPath_SubtreePropagates_whenDictionary() {
        let expected = """
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

        let actual = """
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

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0-0", "key0-1", scope: .subtree))
        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: "key0-0", "key0-1", scope: .subtree))
        }
    }

    // MARK: Config tests
    func testSetting_isActiveToFalse() {
        let expected = """
        [1]
        """

        let actual = """
        [1, 2]
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil, isActive: false))
        assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil, isActive: false))
    }

    // MARK: - Specific path option testing -
    // CollectionEqualCount
    // KeyMustBeAbsent
    // ValueExactMatch
    // ValueTypeMatch
    // WildcardMatch

    // MARK: CollectionEqualCount
    /// Validates that the default init applies the option as expected. Note that this only tests the top level entity, because the default scope is `.singleNode`.
    func testCollectionEqualCount_WithDefaultInit_CorrectlyFails() {
        let expected = """
        {}
        """

        let actual = """
        {
          "key1": 1
        }
        """

        XCTExpectFailure("Validation should fail when collection counts are not equal") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount())
        }
    }

    // MARK: KeyMustBeAbsent
    /// Validates that the default init applies the option as expected. Note that this only tests the top level entity, because the default scope is `.singleNode`.
    func testKeyMustBeAbsent_WithDefaultInit_CorrectlyFails() {
        let expected = """
        {}
        """

        let actual = """
        {
          "key1": 1
        }
        """

        XCTExpectFailure("Validation should fail when key name is present") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: "key1"))
        }
    }

    // TODO: Wildcard keyname/index functionality
    func testKeyMustBeAbsent_WithInnerPath_CorrectlyFails() {
        let expected = """
        {}
        """

        let actual = """
        {
          "events": [
            {
              "request": {
                "path": "something"
              }
            }
          ],
          "path": "top level"
        }
        """
        XCTExpectFailure("Validation should fail when key names not provided") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: "events[0].request.path", scope: .subtree))
        }
    }

    func testKeyMustBeAbsent_WithSinglePath_Passes() {
        let expected = """
        {}
        """

        let actual = """
        {
            "key1": 1
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: "key2"))
    }

    func testKeyMustBeAbsent_WithMultipleKeys_Passes() {
        let expected = """
        {}
        """

        let actual = """
        {
            "key1": 1
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: "key2", "key3"))
    }

    func testKeyMustBeAbsent_Fails_WhenKeyPresent() {
        let expected = """
        {}
        """

        let actual = """
        {
            "key1": 1
        }
        """

        XCTExpectFailure("Validation should fail when key that must be absent is present in actual") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: "key1"))
        }
    }

    /// This test validates an edge case where the `KeyMustBeAbsent` option is used on a part of the `actual` JSON hierarchy that `expected`
    /// does **not** traverse.
    func testKeyMustBeAbsent_Fails_WhenKeyInDifferentHierarchy() {
        let expected = """
        {
          "key1": 1
        }
        """

        let actual = """
        {
          "key1": 1,
          "key2": {
            "key3": 1
          }
        }
        """

        XCTExpectFailure("Validation should fail when key that must be absent is present in actual") {
            assertExactMatch(expected: expected, actual: actual, pathOptions: KeyMustBeAbsent(paths: "key2.key3"))
        }
    }

    // MARK: ValueExactMatch
    func testValueExactMatch_WithDefaultPathsInit_CorrectlyFails() {
        let expected = """
        {
            "key1": 1
        }
        """

        let actual = """
        {
            "key1": 2
        }
        """

        XCTExpectFailure("Validation should fail when path option is not satisfied") {
            assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(scope: .subtree))
        }
    }

    // MARK: ValueTypeMatch
    func testValueTypeMatch_WithDefaultPathsInit_Passes() {
        let expected = """
        {
        "key1": 1
        }
        """

        let actual = """
        {
            "key1": 2
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(scope: .subtree))
    }

    func testValueTypeMatch_SubtreeOption_Propagates() {
        let expected = """
        {
          "key0-0": [
            {
              "key1-0": 1
            }
          ]
        }
        """

        let actual = """
        {
          "key0-0": [
            {
              "key1-0": 2
            }
          ]
        }
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: "key0-0", scope: .subtree))
    }

    func testValueTypeMatch_SingleNodeAndSubtreeOption() {
        let expected = """
        {
          "key0-0": [
            {
              "key1-0": 1
            }
          ],
          "key0-1": 1
        }
        """

        let actual = """
        {
          "key0-0": [
            {
              "key1-0": 2
            }
          ],
          "key0-1": 2
        }
        """

        assertExactMatch(
            expected: expected,
            actual: actual,
            pathOptions:
                ValueTypeMatch(paths: "key0-1"),
            ValueTypeMatch(paths: "key0-0", scope: .subtree))
    }

    // MARK: WildcardMatch
    /// Validates that the default init applies the option as expected. Note that this only tests the top level entity, because the default scope is `.singleNode`.
    func testValueExactMatch_WithDefaultInit_CorrectlyFails() {
        let expected = """
        [1, 2]
        """

        let actual = """
        [2, 1]
        """

        assertExactMatch(expected: expected, actual: actual, pathOptions: WildcardMatch())
    }
}
