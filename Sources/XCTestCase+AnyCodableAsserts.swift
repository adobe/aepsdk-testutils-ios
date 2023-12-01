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

import AEPCore
import AEPServices
import Foundation
import XCTest

public protocol AnyCodableAsserts {
    /// Gets the `AnyCodable` representation of a JSON string
    func getAnyCodable(_ jsonString: String) -> AnyCodable?

    /// Gets an event's data payload converted into `AnyCodable` format
    func getAnyCodable(_ event: Event) -> AnyCodable?

    /// Converts a network request's connect payload into `AnyCodable` format.
    func getAnyCodable(_ networkRequest: NetworkRequest) -> AnyCodable?

    /// Asserts exact equality between two `AnyCodable` instances.
    ///
    /// In the event of an assertion failure, this function provides a trace of the key path, which includes dictionary keys and array indexes,
    /// to aid debugging.
    ///
    /// - Parameters:
    ///   - expected: The expected `AnyCodable` to compare.
    ///   - actual: The actual `AnyCodable` to compare.
    ///   - file: The file from which the method is called, used for localized assertion failures.
    ///   - line: The line from which the method is called, used for localized assertion failures.
    func assertEqual(expected: AnyCodable?, actual: AnyCodable?, file: StaticString, line: UInt)

    /// Performs a flexible JSON comparison where only the key-value pairs from the expected JSON are required.
    /// By default, the function validates that both values are of the same type.
    ///
    /// Alternate mode paths enable switching from the default type matching mode to exact value matching
    /// mode for specified paths onward.
    ///
    /// For example, given an expected JSON like:
    /// ```
    /// {
    ///   "key1": "value1",
    ///   "key2": [{ "nest1": 1}, {"nest2": 2}],
    ///   "key3": { "key4": 1 },
    ///   "key.name": 1,
    ///   "key[123]": 1
    /// }
    /// ```
    /// An example `exactMatchPaths` path for this JSON would be: `"key2[1].nest2"`.
    ///
    /// Alternate mode paths must begin from the top level of the expected JSON.
    /// Multiple paths can be defined. If two paths collide, the shorter one takes priority.
    ///
    /// Formats for keys:
    /// - Nested keys: Use dot notation, e.g., "key3.key4".
    /// - Keys with dots: Escape the dot, e.g., "key\.name".
    ///
    /// Formats for arrays:
    /// - Index specification: `[<INT>]` (e.g., `[0]`, `[28]`).
    /// - Keys with array brackets: Escape the brackets, e.g., `key\[123\]`.
    ///
    /// For wildcard array matching, where position doesn't matter:
    /// 1. Specific index with wildcard: `[*<INT>]` (ex: `[*0]`, `[*28]`). Only a single wildcard character `*` MUST be placed to the
    /// left of the index value. The element at the given index in `expected` will use wildcard matching in `actual`.
    /// 2. Universal wildcard: `[*]`. All elements in `expected` will use wildcard matching in `actual`.
    ///
    /// In array comparisons, elements are compared in order, up to the last element of the expected array.
    /// When combining wildcard and standard indexes, regular indexes are validated first.
    ///
    /// - Parameters:
    ///   - expected: The expected `AnyCodable` to compare.
    ///   - actual: The actual `AnyCodable` to compare.
    ///   - exactMatchPaths: The key paths in the expected JSON that should use exact matching mode, where values require both the same type and literal value.
    ///   - file: The file from which the method is called, used for localized assertion failures.
    ///   - line: The line from which the method is called, used for localized assertion failures.
    func assertTypeMatch(expected: AnyCodable, actual: AnyCodable?, exactMatchPaths: [String], file: StaticString, line: UInt)

    func assertTypeMatch(expected: AnyCodable, actual: AnyCodable?, pathOptions: [MultiPathConfig], file: StaticString, line: UInt)
    func assertTypeMatch(expected: AnyCodable, actual: AnyCodable?, pathOptions: MultiPathConfig..., file: StaticString, line: UInt)

    /// Performs a flexible JSON comparison where only the key-value pairs from the expected JSON are required.
    /// By default, the function uses exact match mode, validating that both values are of the same type
    /// and have the same literal value.
    ///
    /// Alternate mode paths enable switching from the default exact matching mode to type matching
    /// mode for specified paths onward.
    ///
    /// For example, given an expected JSON like:
    /// ```
    /// {
    ///   "key1": "value1",
    ///   "key2": [{ "nest1": 1}, {"nest2": 2}],
    ///   "key3": { "key4": 1 },
    ///   "key.name": 1,
    ///   "key[123]": 1
    /// }
    /// ```
    /// An example `typeMatchPaths` path for this JSON would be: `"key2[1].nest2"`.
    ///
    /// Alternate mode paths must begin from the top level of the expected JSON.
    /// Multiple paths can be defined. If two paths collide, the shorter one takes priority.
    ///
    /// Formats for keys:
    /// - Nested keys: Use dot notation, e.g., "key3.key4".
    /// - Keys with dots: Escape the dot, e.g., "key\.name".
    ///
    /// Formats for arrays:
    /// - Index specification: `[<INT>]` (e.g., `[0]`, `[28]`).
    /// - Keys with array brackets: Escape the brackets, e.g., `key\[123\]`.
    ///
    /// For wildcard array matching, where position doesn't matter:
    /// 1. Specific index with wildcard: `[*<INT>]` (ex: `[*0]`, `[*28]`). Only a single wildcard character `*` MUST be placed to the
    /// left of the index value. The element at the given index in `expected` will use wildcard matching in `actual`.
    /// 2. Universal wildcard: `[*]`. All elements in `expected` will use wildcard matching in `actual`.
    ///
    /// In array comparisons, elements are compared in order, up to the last element of the expected array.
    /// When combining wildcard and standard indexes, regular indexes are validated first.
    ///
    /// - Parameters:
    ///   - expected: The expected `AnyCodable` to compare.
    ///   - actual: The actual `AnyCodable` to compare.
    ///   - typeMatchPaths: The key paths in the expected JSON that should use type matching mode, where values require only the same type (and are non-nil if the expected value is not nil).
    ///   - file: The file from which the method is called, used for localized assertion failures.
    ///   - line: The line from which the method is called, used for localized assertion failures.
    func assertExactMatch(expected: AnyCodable, actual: AnyCodable?, typeMatchPaths: [String], file: StaticString, line: UInt)

    func assertExactMatch(expected: AnyCodable, actual: AnyCodable?, pathOptions: [MultiPathConfig], file: StaticString, line: UInt)
    func assertExactMatch(expected: AnyCodable, actual: AnyCodable?, pathOptions: MultiPathConfig..., file: StaticString, line: UInt)
}

public extension AnyCodableAsserts where Self: XCTestCase {
    func getAnyCodable(_ jsonString: String) -> AnyCodable? {
        return try? JSONDecoder().decode(AnyCodable.self, from: jsonString.data(using: .utf8)!)
    }

    func getAnyCodable(_ event: Event) -> AnyCodable? {
        return AnyCodable(AnyCodable.from(dictionary: event.data))
    }

    func getAnyCodable(_ networkRequest: NetworkRequest) -> AnyCodable? {
        guard let payloadAsDictionary = try? JSONSerialization.jsonObject(with: networkRequest.connectPayload, options: []) as? [String: Any] else {
            return nil
        }
        return AnyCodable(AnyCodable.from(dictionary: payloadAsDictionary))
    }

    // Exact equality is just a special case of exact match
    func assertEqual(expected: AnyCodable?, actual: AnyCodable?, file: StaticString = #file, line: UInt = #line) {
        if expected == nil && actual == nil {
            return
        }
        guard let expected = expected, let actual = actual else {
            XCTFail(#"""
                \#(expected == nil ? "Expected is nil" : "Actual is nil") and \#(expected == nil ? "Actual" : "Expected") is non-nil.

                Expected: \#(String(describing: expected))

                Actual: \#(String(describing: actual))
            """#, file: file, line: line)
            return
        }
        assertExactMatch(expected: expected, actual: actual, pathOptions: CollectionEqualCount(paths: nil, isActive: true, scope: .subtree), file: file, line: line)
    }

    // MARK: Type match
    func assertTypeMatch(expected: AnyCodable, actual: AnyCodable?, exactMatchPaths: [String] = [], file: StaticString = #file, line: UInt = #line) {
        assertTypeMatch(expected: expected, actual: actual, pathOptions: ValueExactMatch(paths: exactMatchPaths, scope: .subtree), file: file, line: line)
    }

    func assertTypeMatch(expected: AnyCodable, actual: AnyCodable?, pathOptions: [MultiPathConfig], file: StaticString = #file, line: UInt = #line) {
        let treeDefaults: [MultiPathConfig] = [
            CollectionEqualCount(paths: nil, isActive: false),
            KeyMustBeAbsent(paths: nil, isActive: false),
            ValueTypeMatch(paths: nil),
            WildcardMatch(paths: nil, isActive: false)
        ]

        let nodeTree = generateNodeTree(pathOptions: pathOptions, treeDefaults: treeDefaults, file: file, line: line)
        validateJSON(expected: expected, actual: actual, nodeTree: nodeTree, file: file, line: line)
    }

    func assertTypeMatch(expected: AnyCodable, actual: AnyCodable?, pathOptions: MultiPathConfig..., file: StaticString = #file, line: UInt = #line) {
        assertTypeMatch(expected: expected, actual: actual, pathOptions: pathOptions, file: file, line: line)
    }

    // MARK: Exact match
    func assertExactMatch(expected: AnyCodable, actual: AnyCodable?, typeMatchPaths: [String] = [], file: StaticString = #file, line: UInt = #line) {
        assertExactMatch(expected: expected, actual: actual, pathOptions: ValueTypeMatch(paths: typeMatchPaths, scope: .subtree), file: file, line: line)
    }

    func assertExactMatch(expected: AnyCodable, actual: AnyCodable?, pathOptions: [MultiPathConfig], file: StaticString = #file, line: UInt = #line) {
        let treeDefaults: [MultiPathConfig] = [
            CollectionEqualCount(paths: nil, isActive: false),
            KeyMustBeAbsent(paths: nil, isActive: false),
            ValueExactMatch(paths: nil),
            WildcardMatch(paths: nil, isActive: false)
        ]

        let nodeTree = generateNodeTree(pathOptions: pathOptions, treeDefaults: treeDefaults, file: file, line: line)
        validateJSON(expected: expected, actual: actual, nodeTree: nodeTree, file: file, line: line)
    }

    func assertExactMatch(expected: AnyCodable, actual: AnyCodable?, pathOptions: MultiPathConfig..., file: StaticString = #file, line: UInt = #line) {
        assertExactMatch(expected: expected, actual: actual, pathOptions: pathOptions, file: file, line: line)
    }

    // MARK: - AnyCodable flexible validation helpers
    /// Performs a cutomizable validation between the given `expected` and `actual` values, using the configured options.
    /// In case of a validation failure **and** if `shouldAssert` is `true`, a test failure occurs.
    ///
    /// - Parameters:
    ///   - expected: The expected value to compare.
    ///   - actual: The actual value to compare.
    ///   - keyPath: A list of keys or array indexes representing the path to the current value being compared. Defaults to an empty list.
    ///   - nodeTree: A tree of configuration objects used to control various validation settings.
    ///   - shouldAssert: Indicates if an assertion error should be thrown if `expected` and `actual` are not equal. Defaults to `true`.
    ///   - file: The file from which the method is called, used for localized assertion failures.
    ///   - line: The line from which the method is called, used for localized assertion failures.
    ///
    /// - Returns: `true` if `expected` and `actual` are equal based on the settings in `nodeTree`, otherwise returns `false`.
    @discardableResult
    private func validateJSON(
        expected: AnyCodable?,
        actual: AnyCodable?,
        keyPath: [Any] = [],
        nodeTree: NodeConfig,
        shouldAssert: Bool = true,
        file: StaticString = #file,
        line: UInt = #line) -> Bool {
        if expected?.value == nil {
            return true
        }
        guard let expected = expected, let actual = actual else {
            if shouldAssert {
                XCTFail(#"""
                    Expected JSON is non-nil but Actual JSON is nil.

                    Expected: \#(String(describing: expected))

                    Actual: \#(String(describing: actual))

                    Key path: \#(keyPathAsString(keyPath))
                """#, file: file, line: line)
            }
            return false
        }

        switch (expected, actual) {
        case let (expected, actual) where (expected.value is String && actual.value is String):
            fallthrough
        case let (expected, actual) where (expected.value is Bool && actual.value is Bool):
            fallthrough
        case let (expected, actual) where (expected.value is Int && actual.value is Int):
            fallthrough
        case let (expected, actual) where (expected.value is Double && actual.value is Double):
            if nodeTree.primitiveExactMatch.isActive {
                if shouldAssert {
                    XCTAssertEqual(expected, actual, "Key path: \(keyPathAsString(keyPath))", file: file, line: line)
                }
                return expected == actual
            } else {
                // Value type matching already passed by virtue of passing the where condition in the switch case
                return true
            }
        case let (expected, actual) where (expected.value is [String: AnyCodable] && actual.value is [String: AnyCodable]):
            return validateJSON(
                expected: expected.value as? [String: AnyCodable],
                actual: actual.value as? [String: AnyCodable],
                keyPath: keyPath,
                nodeTree: nodeTree,
                shouldAssert: shouldAssert,
                file: file,
                line: line)
        case let (expected, actual) where (expected.value is [AnyCodable] && actual.value is [AnyCodable]):
            return validateJSON(
                expected: expected.value as? [AnyCodable],
                actual: actual.value as? [AnyCodable],
                keyPath: keyPath,
                nodeTree: nodeTree,
                shouldAssert: shouldAssert,
                file: file,
                line: line)
        case let (expected, actual) where (expected.value is [Any?] && actual.value is [Any?]):
            return validateJSON(
                expected: AnyCodable.from(array: expected.value as? [Any?]),
                actual: AnyCodable.from(array: actual.value as? [Any?]),
                keyPath: keyPath,
                nodeTree: nodeTree,
                shouldAssert: shouldAssert,
                file: file,
                line: line)
        case let (expected, actual) where (expected.value is [String: Any?] && actual.value is [String: Any?]):
            return validateJSON(
                expected: AnyCodable.from(dictionary: expected.value as? [String: Any?]),
                actual: AnyCodable.from(dictionary: actual.value as? [String: Any?]),
                keyPath: keyPath,
                nodeTree: nodeTree,
                shouldAssert: shouldAssert,
                file: file,
                line: line)
        default:
            if shouldAssert {
                XCTFail(#"""
                    Expected and Actual types do not match.

                    Expected: \#(expected)

                    Actual: \#(actual)

                    Key path: \#(keyPathAsString(keyPath))
                """#, file: file, line: line)
            }
            return false
        }
    }

    /// Performs a cutomizable validation between the given `expected` and `actual` `AnyCodable`arrays, using the configured options.
    /// In case of a validation failure **and** if `shouldAssert` is `true`, a test failure occurs.
    ///
    /// - Parameters:
    ///   - expected: The expected array of `AnyCodable` to compare.
    ///   - actual: The actual array of `AnyCodable` to compare.
    ///   - keyPath: A list of keys or array indexes representing the path to the current value being compared.
    ///   - nodeTree: A tree of configuration objects used to control various validation settings.
    ///   - shouldAssert: Indicates if an assertion error should be thrown if `expected` and `actual` are not equal.
    ///   - file: The file from which the method is called, used for localized assertion failures.
    ///   - line: The line from which the method is called, used for localized assertion failures.
    ///
    /// - Returns: `true` if `expected` and `actual` are equal based on the settings in `nodeTree`, otherwise returns `false`.
    private func validateJSON(
        expected: [AnyCodable]?,
        actual: [AnyCodable]?,
        keyPath: [Any],
        nodeTree: NodeConfig,
        shouldAssert: Bool = true,
        file: StaticString = #file,
        line: UInt = #line) -> Bool {
        if expected == nil {
            return true
        }
        guard let expected = expected, let actual = actual else {
            if shouldAssert {
                XCTFail(#"""
                    Expected JSON is non-nil but Actual JSON is nil.

                    Expected: \#(String(describing: expected))

                    Actual: \#(String(describing: actual))

                    Key path: \#(keyPathAsString(keyPath))
                """#, file: file, line: line)
            }
            return false
        }
        if nodeTree.collectionEqualCount.isActive ? (expected.count != actual.count) : (expected.count > actual.count) {
            if shouldAssert {
                XCTFail(#"""
                    Expected JSON \#(nodeTree.collectionEqualCount.isActive ? "count does not match" : "has more elements than") Actual JSON.

                    Expected count: \#(expected.count)
                    Actual count: \#(actual.count)

                    Expected: \#(expected)

                    Actual: \#(actual)

                    Key path: \#(keyPathAsString(keyPath))
                """#, file: file, line: line)
            }
            return false
        }

        // Create a dictionary where:
        // key: the index in String format
        // value: the resolved option for if wildcard matching should be used for the index
        //   - see resolveOption for precedence
        var expectedIndexes = (0..<expected.count).reduce(into: [String: NodeConfig.Config]()) { result, index in
            let indexString = String(index)
            result[indexString] = NodeConfig.resolveOption(.wildcardMatch, for: nodeTree.getChild(named: indexString), parent: nodeTree)
        }
        let wildcardIndexes = expectedIndexes.filter({ $0.value.isActive })
        wildcardIndexes.forEach { key, _ in
            expectedIndexes.removeValue(forKey: key)
        }

        var availableWildcardActualIndexes = Set((0..<actual.count).map({ String($0) })).subtracting(expectedIndexes.keys)

        var validationResult = true
        // Validate non-wildcard expected side indexes first, as these don't have
        // position flexibility
        for (index, config) in expectedIndexes {
            let intIndex = Int(index)!
            validationResult = validateJSON(
                expected: expected[intIndex],
                actual: actual[intIndex],
                keyPath: keyPath + [intIndex],
                nodeTree: nodeTree.getChild(named: index) ?? nodeTree.asFinalNode(),
                shouldAssert: shouldAssert,
                file: file, line: line) && validationResult
        }

        for (index, config) in wildcardIndexes {
            let intIndex = Int(index)!

            guard let actualIndex = availableWildcardActualIndexes.first(where: {
                validateJSON(
                    expected: expected[intIndex],
                    actual: actual[Int($0)!],
                    keyPath: keyPath + [intIndex],
                    nodeTree: nodeTree.getChild(named: index) ?? nodeTree.asFinalNode(),
                    shouldAssert: false)
            }) else {
                if shouldAssert {
                    XCTFail(#"""
                        Wildcard \#(NodeConfig.resolveOption(.primitiveExactMatch, for: nodeTree.getChild(named: index), parent: nodeTree).isActive ? "exact" : "type") match found no matches on Actual side satisfying the Expected requirement.

                        Requirement: \#(nodeTree)

                        Expected: \#(expected[intIndex])

                        Actual (remaining unmatched elements): \#(availableWildcardActualIndexes.map({ actual[Int($0)!] }))

                        Key path: \#(keyPathAsString(keyPath))
                        """#, file: file, line: line)
                }
                validationResult = false
                break
            }
            availableWildcardActualIndexes.remove(actualIndex)
        }

        return validationResult
    }

    /// Performs a cutomizable validation between the given `expected` and `actual` `AnyCodable`dictionaries, using the configured options.
    /// In case of a validation failure **and** if `shouldAssert` is `true`, a test failure occurs.
    ///
    /// - Parameters:
    ///   - expected: The expected dictionary of `AnyCodable` to compare.
    ///   - actual: The actual dictionary of `AnyCodable` to compare.
    ///   - keyPath: A list of keys or array indexes representing the path to the current value being compared.
    ///   - nodeTree: A tree of configuration objects used to control various validation settings.
    ///   - shouldAssert: Indicates if an assertion error should be thrown if `expected` and `actual` are not equal.
    ///   - file: The file from which the method is called, used for localized assertion failures.
    ///   - line: The line from which the method is called, used for localized assertion failures.
    ///
    /// - Returns: `true` if `expected` and `actual` are equal based on the settings in `nodeTree`, otherwise returns `false`.
    private func validateJSON(
        expected: [String: AnyCodable]?,
        actual: [String: AnyCodable]?,
        keyPath: [Any],
        nodeTree: NodeConfig,
        shouldAssert: Bool = true,
        file: StaticString = #file,
        line: UInt = #line) -> Bool {
        if expected == nil {
            return true
        }
        guard let expected = expected, let actual = actual else {
            if shouldAssert {
                XCTFail(#"""
                    Expected JSON is non-nil but Actual JSON is nil.

                    Expected: \#(String(describing: expected))

                    Actual: \#(String(describing: actual))

                    Key path: \#(keyPathAsString(keyPath))
                """#, file: file, line: line)
            }
            return false
        }
        if nodeTree.collectionEqualCount.isActive ? (expected.count != actual.count) : (expected.count > actual.count) {
            if shouldAssert {
                XCTFail(#"""
                    Expected JSON \#(nodeTree.collectionEqualCount.isActive ? "count does not match" : "has more elements than") Actual JSON.

                    Expected count: \#(expected.count)
                    Actual count: \#(actual.count)

                    Expected: \#(expected)

                    Actual: \#(actual)

                    Key path: \#(keyPathAsString(keyPath))
                """#, file: file, line: line)
            }
            return false
        }

        // Check if key must be absent
        let keysThatMustBeAbsent = nodeTree.children.filter({ $0.keyMustBeAbsent.isActive }).compactMap({ $0.name })
        var keyAbsenceResult = true
        for absentKey in keysThatMustBeAbsent {
            if actual[absentKey] != nil {
                if shouldAssert {
                    XCTFail(#"""
                        Actual JSON should not have key with name: \#(absentKey)

                        Expected: \#(expected)

                        Actual: \#(actual)

                        Key path: \#(keyPathAsString(keyPath))
                    """#, file: file, line: line)
                }
                keyAbsenceResult = false
            }
        }
        guard keyAbsenceResult else {
            return keyAbsenceResult
        }

        var validationResult = true
        for (key, value) in expected {
            validationResult = validateJSON(
                expected: value,
                actual: actual[key],
                keyPath: keyPath + [key],
                nodeTree: nodeTree.getChild(named: key) ?? nodeTree.asFinalNode(),
                shouldAssert: shouldAssert,
                file: file,
                line: line)
                && validationResult
        }
        return validationResult
    }

    // MARK: - Test setup and output helpers

    /// Generates a tree structure from an array of path `String`s.
    ///
    /// This function processes each path in `paths`, extracts its individual components using `processPathComponents`, and
    /// constructs a nested dictionary structure. The constructed dictionary is then merged into the main tree. If the resulting tree
    /// is empty after processing all paths, this function returns `nil`.
    ///
    /// - Parameter paths: An array of path `String`s to be processed. Each path represents a nested structure to be transformed
    /// into a tree-like dictionary.
    ///
    /// - Returns: A tree-like dictionary structure representing the nested structure of the provided paths. Returns `nil` if the
    /// resulting tree is empty.
    private func generateNodeTree(pathOptions: [MultiPathConfig], treeDefaults: [MultiPathConfig], file: StaticString = #file, line: UInt = #line) -> NodeConfig {
        // 1. creates the first node using the incoming defaults
        // using the first node it passes the path to the node to create the child nodes and just loops through all the paths passing them

        var subtreeOptions: [NodeConfig.OptionKey: NodeConfig.Config] = [:]
        for treeDefault in treeDefaults {
            let key = treeDefault.optionKey
            let config = NodeConfig.Config(isActive: treeDefault.isActive)
            subtreeOptions[key] = config
        }

        let rootNode = NodeConfig(name: nil, subtreeOptions: subtreeOptions)

        for pathConfig in pathOptions {
            rootNode.createOrUpdateNode(using: pathConfig)
        }

        return rootNode
    }

    /// Converts a key path represented by an array of JSON object keys and array indexes into a human-readable `String` format.
    ///
    /// The key path is used to trace the recursive traversal of a nested JSON structure.
    /// For instance, the key path for the value "Hello" in the JSON `{ "a": { "b": [ "World", "Hello" ] } }`
    /// would be `["a", "b", 1]`.
    /// This method would convert it to the `String`: `"a.b[1]"`.
    ///
    /// Special considerations:
    /// 1. If a key in the JSON object contains a dot (`.`), it will be escaped with a backslash in the resulting `String`.
    /// 2. Empty keys in the JSON object will be represented as `""` in the resulting `String`.
    ///
    /// - Parameter keyPath: An array of keys or array indexes representing the path to a value in a nested JSON structure.
    ///
    /// - Returns: A human-readable `String` representation of the key path.
    private func keyPathAsString(_ keyPath: [Any]) -> String {
        var result = ""
        for item in keyPath {
            switch item {
            case let item as String:
                if !result.isEmpty {
                    result += "."
                }
                if item.contains(".") {
                    result += item.replacingOccurrences(of: ".", with: "\\.")
                } else if item.isEmpty {
                    result += "\"\""
                } else {
                    result += item
                }
            case let item as Int:
                result += "[" + String(item) + "]"
            default:
                break
            }
        }
        return result
    }
}
