//
//  Array+Extensions.swift
//  Documents
//
//  Created by Alexander Yuzhin on 05.04.2021.
//  Copyright © 2021 Ascensio System SIA. All rights reserved.
//

import Foundation

// MARK: - Methods

public extension Array {
    /// Insert an element at the beginning of array.
    ///
    ///        [2, 3, 4, 5].prepend(1) -> [1, 2, 3, 4, 5]
    ///        ["e", "l", "l", "o"].prepend("h") -> ["h", "e", "l", "l", "o"]
    ///
    /// - Parameter newElement: element to insert.
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }

    /// Safely swap values at given index positions.
    ///
    ///        [1, 2, 3, 4, 5].safeSwap(from: 3, to: 0) -> [4, 2, 3, 1, 5]
    ///        ["h", "e", "l", "l", "o"].safeSwap(from: 1, to: 0) -> ["e", "h", "l", "l", "o"]
    ///
    /// - Parameters:
    ///   - index: index of first element.
    ///   - otherIndex: index of other element.
    mutating func safeSwap(from index: Index, to otherIndex: Index) {
        guard index != otherIndex else { return }
        guard startIndex ..< endIndex ~= index else { return }
        guard startIndex ..< endIndex ~= otherIndex else { return }
        swapAt(index, otherIndex)
    }

    /// Sort an array like another array based on a key path. If the other array doesn't contain a certain value, it will be sorted last.
    ///
    ///        [MyStruct(x: 3), MyStruct(x: 1), MyStruct(x: 2)].sorted(like: [1, 2, 3], keyPath: \.x)
    ///            -> [MyStruct(x: 1), MyStruct(x: 2), MyStruct(x: 3)]
    ///
    /// - Parameters:
    ///   - otherArray: array containing elements in the desired order.
    ///   - keyPath: keyPath indicating the property that the array should be sorted by
    /// - Returns: sorted array.
    func sorted<T: Hashable>(like otherArray: [T], keyPath: KeyPath<Element, T>) -> [Element] {
        let dict = otherArray.enumerated().reduce(into: [:]) { $0[$1.element] = $1.offset }
        return sorted {
            guard let thisIndex = dict[$0[keyPath: keyPath]] else { return false }
            guard let otherIndex = dict[$1[keyPath: keyPath]] else { return true }
            return thisIndex < otherIndex
        }
    }
}

// MARK: - Methods (Equatable)

public extension Array where Element: Equatable {
    /// Remove all instances of an item from array.
    ///
    ///        [1, 2, 2, 3, 4, 5].removeAll(2) -> [1, 3, 4, 5]
    ///        ["h", "e", "l", "l", "o"].removeAll("l") -> ["h", "e", "o"]
    ///
    /// - Parameter item: item to remove.
    /// - Returns: self after removing all instances of item.
    @discardableResult
    mutating func removeAll(_ item: Element) -> [Element] {
        removeAll(where: { $0 == item })
        return self
    }

    /// Remove all instances contained in items parameter from array.
    ///
    ///        [1, 2, 2, 3, 4, 5].removeAll([2,5]) -> [1, 3, 4]
    ///        ["h", "e", "l", "l", "o"].removeAll(["l", "h"]) -> ["e", "o"]
    ///
    /// - Parameter items: items to remove.
    /// - Returns: self after removing all instances of all items in given array.
    @discardableResult
    mutating func removeAll(_ items: [Element]) -> [Element] {
        guard !items.isEmpty else { return self }
        removeAll(where: { items.contains($0) })
        return self
    }

    /// Remove all duplicate elements from Array.
    ///
    ///        [1, 2, 2, 3, 4, 5].removeDuplicates() -> [1, 2, 3, 4, 5]
    ///        ["h", "e", "l", "l", "o"]. removeDuplicates() -> ["h", "e", "l", "o"]
    ///
    /// - Returns: Return array with all duplicate elements removed.
    @discardableResult
    mutating func removeDuplicates() -> [Element] {
        // Thanks to https://github.com/sairamkotha for improving the method
        self = reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
        return self
    }

    /// Return array with all duplicate elements removed.
    ///
    ///     [1, 1, 2, 2, 3, 3, 3, 4, 5].withoutDuplicates() -> [1, 2, 3, 4, 5])
    ///     ["h", "e", "l", "l", "o"].withoutDuplicates() -> ["h", "e", "l", "o"])
    ///
    /// - Returns: an array of unique elements.
    ///
    func withoutDuplicates() -> [Element] {
        // Thanks to https://github.com/sairamkotha for improving the method
        return reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }

    /// Returns an array with all duplicate elements removed using KeyPath to compare.
    ///
    /// - Parameter path: Key path to compare, the value must be Equatable.
    /// - Returns: an array of unique elements.
    func withoutDuplicates<E: Equatable>(keyPath path: KeyPath<Element, E>) -> [Element] {
        return reduce(into: [Element]()) { result, element in
            if !result.contains(where: { $0[keyPath: path] == element[keyPath: path] }) {
                result.append(element)
            }
        }
    }

    /// Returns an array with all duplicate elements removed using KeyPath to compare.
    ///
    /// - Parameter path: Key path to compare, the value must be Hashable.
    /// - Returns: an array of unique elements.
    func withoutDuplicates<E: Hashable>(keyPath path: KeyPath<Element, E>) -> [Element] {
        var set = Set<E>()
        return filter { set.insert($0[keyPath: path]).inserted }
    }
}