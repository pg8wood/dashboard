//
//  Result.swift
//  PinkyPromise
//
//  Created by Kevin Conner on 3/16/16.
//
//  The MIT License (MIT)
//  Copyright © 2016 WillowTree, Inc. All rights reserved.
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation

/**
 A model for a success or failure.

 This type precisely represents the domain of results of a function call that either returns a value or throws an error.
 
 Result is used by `Promise` to represent success or failure outside the normal flow of synchronous execution.
 
 Result is a functor and a monad; you can map and flatMap.

 - `map` transforms a success value into a new success value, but preserves errors.
 - `flatMap` also preserves errors, but transforms a success value to a new Result, meaning it may produce a new failure.
 - `tryMap` works like `flatMap`, but uses a transformation function that returns or throws.
 */
public enum Result<Value> {

    /// A successful result wrapping a returned value.
    case success(Value)
    /// A failed result wrapping a thrown error.
    case failure(Error)

    // MARK: Wrapping

    /**
     Creates a result by immediately invoking a function that returns or throws.

     - parameter create: A function whose returned value or thrown error becomes wrapped by the result.

     The opposite operation is `value()`.
     */
    public init(create: () throws -> Value) {
        do {
            let value = try create()
            self = .success(value)
        } catch {
            self = .failure(error)
        }
    }

    // MARK: Unwrapping

    /**
     Returns or throws the wrapped value or error.
     
     - throws: The wrapped error, if the result is a failure.
     - returns: The wrapped value, if the result is a success.
     
     The opposite operation is `init(create:)`.
     */
    public func value() throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }

    // MARK: Transforming

    /**
     Transforms a success value and wraps it in a new successful result.

     If the receiver is a failure, wraps the same error without invoking `transform`.

     - parameter transform: A function that produces a new success value, given a success value.
     - returns: A result with the transformed success value or the original failure.
     */
    public func map<U>(_ transform: (Value) -> U) -> Result<U> {
        return tryMap(transform)
    }

    /**
     Transforms a success value into a new successful or failed result.

     If the receiver is a failure, wraps the same error without invoking `transform`.

     - parameter transform: A function that produces a new result, given a success value.
     - returns: The transformed result or the original failure.
     */
    public func flatMap<U>(_ transform: (Value) -> Result<U>) -> Result<U> {
        return tryMap { value in
            try transform(value).value()
        }
    }

    /**
     Transforms a success value into a new successful or failed result.
     
     If the receiver is a failure, wraps the same error without invoking `transform`.

     - parameter transform: A function that returns a new success value or throws a new error, given a success value.
     - returns: The transformed result or the original failure.
     
     This is an error-catching variation on `flatMap(_:)`.
     */
    public func tryMap<U>(_ transform: (Value) throws -> U) -> Result<U> {
        return Result<U> {
            try transform(try value())
        }
    }

}

/**
 From two results, returns one result wrapping all their values or the first error.

 - parameter resultA: The first result to repackage.
 - parameter resultB: The second result to repackage.
 - returns: A result wrapping either a tuple of all the given results' success values, or the first error among them.
 */
public func zip<A, B>(_ resultA: Result<A>, _ resultB: Result<B>) -> Result<(A, B)> {
    return resultA.tryMap { a in
        (a, try resultB.value())
    }
}

/**
 From three results, returns one result wrapping all their values or the first error.
 
 - parameter resultA: The first result to repackage.
 - parameter resultB: The second result to repackage.
 - parameter resultC: The third result to repackage.
 - returns: A result wrapping either a tuple of all the given results' success values, or the first error among them.
 */
public func zip<A, B, C>(_ resultA: Result<A>, _ resultB: Result<B>, _ resultC: Result<C>) -> Result<(A, B, C)> {
    return zip(resultA, resultB).tryMap { a, b in
        (a, b, try resultC.value())
    }
}

/**
 From four results, returns one result wrapping all their values or the first error.
 
 - parameter resultA: The first result to repackage.
 - parameter resultB: The second result to repackage.
 - parameter resultC: The third result to repackage.
 - parameter resultD: The fourth result to repackage.
 - returns: A result wrapping either a tuple of all the given results' success values, or the first error among them.
 */
public func zip<A, B, C, D>(_ resultA: Result<A>, _ resultB: Result<B>, _ resultC: Result<C>, _ resultD: Result<D>) -> Result<(A, B, C, D)> {
    return zip(resultA, resultB, resultC).tryMap { a, b, c in
        (a, b, c, try resultD.value())
    }
}

/**
 From an array of results, returns one result wrapping all their values or the first error.
 
 - parameter results: The array of results to repackage.
 - returns: A result wrapping either an array of all the given results' success values, or the first error among them.
 */
public func zipArray<T>(_ results: [Result<T>]) -> Result<[T]> {
    return results.reduce(Result { [] }) { arrayResult, itemResult in
        arrayResult.tryMap { array in
            array + [try itemResult.value()]
        }
    }
}
