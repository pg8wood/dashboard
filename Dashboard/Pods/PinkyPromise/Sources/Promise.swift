//
//  Promise.swift
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
 A transformable, repeatable, failable asynchronous task.
 
 This type represents a function with a potentially failing completion callback.

 A Promise wraps a function which must eventually produce exactly one `Result` for each time it is run.
 
 Promises can be transformed, chained, and combined to construct complex asynchronous workflows.
 
 Unlike other implementations of promises, this type does not save its result.
 The task runs and produces a new result every time you invoke `call`.
 
 - First, create a promise that wraps an asynchronous task.
 - Use `flatMap` and other transformations to chain additional tasks that only run on success of the prior step.
 - Use `onSuccess` or `onFailure` to process a success or failure value, then continue.
 - After building up your composite promise, begin it with `call`.
 - In `call`'s completion, interpret a Result by switching on its cases, or call `value` to unwrap it and have failures thrown.
 */
public struct Promise<Value> {

    /// A completion function for the task wrapped by a promise.
    public typealias Observer = (Result<Value>) -> Void
    /// A function representing the work to be done by a promise. A task must eventually call its given observer function exactly once.
    public typealias Task = (@escaping Observer) -> Void

    /// Work to be done by the promise.
    private let task: Task

    // MARK: Creating a Promise

    /**
     Creates a promise that produces its result by running a given asynchronous task.

     - parameter task: The work function for this promise. The task must eventually call its given observer function exactly once.
     */
    public init(task: @escaping Task) {
        self.task = task
    }

    /**
     Creates a promise that, when called, immediately produces a given result.

     - parameter result: The result to be produced when the promise is run.
     */
    public init(result: Result<Value>) {
        self.init { fulfill in
            fulfill(result)
        }
    }

    /**
     Creates a promise that, when called, immediately succeeds with a given value.
     
     - parameter result: The value to be produced when the promise is run.
     */
    public init(value: Value) {
        self.init(result: .success(value))
    }

    /**
     Creates a promise that, when called, immediately fails with a given error.
     
     - parameter result: The error to be produced when the promise is run.
     */
    public init(error: Error) {
        self.init(result: .failure(error))
    }

    /**
     Creates a promise that, when called, immediately produces its result from a given function.
     
     - parameter produce: A synchronous failable function to be evaluated each time the promise is run.
     - returns: A promise whose task runs the given function and produces its returned value or its thrown error.
     
     The name `lift` refers to:

     - Lifting a synchronous function into asynchronous context.
     - Lifting the notion of producing a Result into Promise context.
     */
    public static func lift(_ produce: @escaping () throws -> Value) -> Promise<Value> {
        return Promise { fulfill in
            fulfill(Result(create: produce))
        }
    }

    // MARK: Transforming Results

    /**
     Creates a promise that wraps this promise and transforms its success value to a new success value.
     
     - parameter transform: A function that produces a new success value, given a success value.
     - returns: A promise whose task calls this promise, then produces either its error or a transformed success value.
     */
    public func map<U>(_ transform: @escaping (Value) -> U) -> Promise<U> {
        return flatMap { value in
            return Promise<U>(value: transform(value))
        }
    }

    /**
     Creates a promise that wraps this promise and runs a second failable task with its success value.
     
     - parameter transform: A function that returns a new success value or throws a new error, given a success value.
     - returns: A promise whose task calls this promise, then either produces its error or a transformed success value or error.
     
     This is a failable variation on `map(_:)`.
     */
    public func tryMap<U>(_ transform: @escaping (Value) throws -> U) -> Promise<U> {
        return flatMap { value in
            return Promise<U>(result: Result {
                try transform(value)
            })
        }
    }

    /**
     Creates a promise that wraps this promise and runs a second failable task with its success value.
     
     - parameter transform: A function that produces a promise for the second task, given a success value.
     - returns: A promise whose task calls this promise, then either produces its error or calls the second task and produces the final result.
     */
    public func flatMap<U>(_ transform: @escaping (Value) -> Promise<U>) -> Promise<U> {
        return Promise<U> { fulfill in
            self.call { result in
                do {
                    let mappedPromise = transform(try result.value())
                    mappedPromise.call(completion: fulfill)
                } catch {
                    fulfill(.failure(error))
                }
            }
        }
    }

    /**
     Creates a promise that wraps this promise and runs a second failable task with its error.
     
     - parameter transform: A function that produces a promise for the second task, given an error.
     - returns: A promise whose task calls this promise, then either produces its success value or calls the second task and produces the final result.
     */
    public func recover(_ transform: @escaping (Error) -> Promise<Value>) -> Promise<Value> {
        return Promise { fulfill in
            self.call { (result: Result<Value>) -> Void in
                do {
                    let value = try result.value()
                    fulfill(.success(value))
                } catch {
                    let mappedPromise = transform(error)
                    mappedPromise.call(completion: fulfill)
                }
            }
        }
    }

    // MARK: Planning Execution

    /**
     Creates a promise that wraps this promise and repeatedly runs it until it succeeds, up to a maximum number of runs.
     
     - parameter attemptCount: The number of times this promise will be run, so long as it keeps failing.
     - returns: A promise whose task calls this promise up to `attemptCount` times, then produces either the first success or the last failure.
     */
    public func retry(attemptCount: Int) -> Promise<Value> {
        return Promise { fulfill in
            func attempt(remainingAttempts: Int) {
                self.call { result in
                    switch (result, remainingAttempts) {
                    case (.success, _), (.failure, 0):
                        fulfill(result)
                    case (.failure, _):
                        attempt(remainingAttempts: remainingAttempts - 1)
                    }
                }
            }

            attempt(remainingAttempts: max(0, attemptCount - 1))
        }
    }

    /**
     Creates a promise that wraps this promise and runs it on a background queue.

     - returns: A promise whose task calls this promise on a background queue, then produces its result on the main queue.
     */
    public func inBackground() -> Promise<Value> {
        return Promise { fulfill in
            DispatchQueue.global().async {
                self.call { result in
                    DispatchQueue.main.async {
                        fulfill(result)
                    }
                }
            }
        }
    }

    /**
     Creates a promise that wraps this promise and runs it while participating in a dispatch group.
     
     - parameter group: The dispatch group to be joined.
     - returns: A promise whose task runs this promise and produces its result while participating in the dispatch group.
     
     The dispatch group task begins when the resulting promise is called. It ends after the promise produces its value.
     */
    public func inDispatchGroup(_ group: DispatchGroup) -> Promise<Value> {
        return Promise { fulfill in
            group.enter()
            self.call { result in
                fulfill(result)
                group.leave()
            }
        }
    }

    // MARK: Inspecting Results

    /**
     Creates a promise that wraps this promise and performs a secondary task with its result.
     
     - parameter resultTask: A function to be called with the result.
     - returns: A promise whose task runs this promise, then calls the result task before producing its result.
     
     This method behaves like the closure argument to `call(completion:)`, but can be used at any step in a composite promise.
     */
    public func onResult(_ resultTask: @escaping (Result<Value>) -> Void) -> Promise<Value> {
        return Promise { fulfill in
            self.call { result in
                resultTask(result)
                fulfill(result)
            }
        }
    }

    /**
     Creates a promise that wraps this promise and performs a secondary task with its success value.
     
     - parameter successTask: A function to be called with the success value.
     - returns: A promise whose task runs this promise, then calls the success task if it succeeded, before producing its result.
     
     This method can be used at any step in a composite promise.
     It's also useful in combination with `onFailure` just before a completionless `call()`, for handling results without having to unwrap the result object.
     */
    public func onSuccess(_ successTask: @escaping (Value) -> Void) -> Promise<Value> {
        return onResult { result in
            if case .success(let value) = result {
                successTask(value)
            }
        }
    }

    /**
     Creates a promise that wraps this promise and performs a secondary task with its error.
     
     - parameter failureTask: A function to be called with the error.
     - returns: A promise whose task runs this promise, then calls the failure task if it failed, before producing its result.
     
     This method can be used at any step in a composite promise.
     It's also useful in combination with `onSuccess` just before a completionless `call()`, for handling results without having to unwrap the result object.
     */
    public func onFailure(_ failureTask: @escaping (Error) -> Void) -> Promise<Value> {
        return onResult { result in
            if case .failure(let error) = result {
                failureTask(error)
            }
        }
    }

    // MARK: Invoking the Promise

    /**
     Performs work defined by the promise and eventually produces the promise's value.
     
     - parameter completion: A function that will receive the promise's produced value when it completes.
     
     A promise won't do any work until you use `call`.
     */
    public func call(completion: Observer? = nil) {
        task { result in
            completion?(result)
        }
    }

}

/**
 Creates a promise that runs two promises simultaneously and unifies their results.

 - parameter promiseA: The first promise to run.
 - parameter promiseB: The second promise to run.
 - returns: A promise whose task runs all the given promises and produces either a tuple of all the given promises' success values, or the first error among them.
 
 If the promises produce more than one failure, the first failure will be chosen in argument order, not completion order.
 */
public func zip<A, B>(_ promiseA: Promise<A>, _ promiseB: Promise<B>) -> Promise<(A, B)> {
    return Promise { fulfill in
        let group = DispatchGroup()

        var resultA: Result<A>!
        var resultB: Result<B>!

        promiseA.inDispatchGroup(group).call { result in
            resultA = result
        }

        promiseB.inDispatchGroup(group).call { result in
            resultB = result
        }

        group.notify(queue: DispatchQueue.main) {
            fulfill(zip(resultA, resultB))
        }
    }
}

/**
 Creates a promise that runs three promises simultaneously and unifies their results.

 - parameter promiseA: The first promise to run.
 - parameter promiseB: The second promise to run.
 - parameter promiseC: The third promise to run.
 - returns: A promise whose task runs all the given promises and produces either a tuple of all the given promises' success values, or the first error among them.

 If the promises produce more than one failure, the first failure will be chosen in argument order, not completion order.
 */
public func zip<A, B, C>(_ promiseA: Promise<A>, _ promiseB: Promise<B>, _ promiseC: Promise<C>) -> Promise<(A, B, C)> {
    return Promise { fulfill in
        let group = DispatchGroup()

        var resultA: Result<A>!
        var resultB: Result<B>!
        var resultC: Result<C>!

        promiseA.inDispatchGroup(group).call { result in
            resultA = result
        }

        promiseB.inDispatchGroup(group).call { result in
            resultB = result
        }

        promiseC.inDispatchGroup(group).call { result in
            resultC = result
        }

        group.notify(queue: DispatchQueue.main) {
            fulfill(zip(resultA, resultB, resultC))
        }
    }
}

/**
 Creates a promise that runs four promises simultaneously and unifies their results.

 - parameter promiseA: The first promise to run.
 - parameter promiseB: The second promise to run.
 - parameter promiseC: The third promise to run.
 - parameter promiseD: The fourth promise to run.
 - returns: A promise whose task runs all the given promises and produces either a tuple of all the given promises' success values, or the first error among them.

 If the promises produce more than one failure, the first failure will be chosen in argument order, not completion order.
 */
public func zip<A, B, C, D>(_ promiseA: Promise<A>, _ promiseB: Promise<B>, _ promiseC: Promise<C>, _ promiseD: Promise<D>) -> Promise<(A, B, C, D)> {
    return Promise { fulfill in
        let group = DispatchGroup()

        var resultA: Result<A>!
        var resultB: Result<B>!
        var resultC: Result<C>!
        var resultD: Result<D>!

        promiseA.inDispatchGroup(group).call { result in
            resultA = result
        }

        promiseB.inDispatchGroup(group).call { result in
            resultB = result
        }

        promiseC.inDispatchGroup(group).call { result in
            resultC = result
        }

        promiseD.inDispatchGroup(group).call { result in
            resultD = result
        }

        group.notify(queue: DispatchQueue.main) {
            fulfill(zip(resultA, resultB, resultC, resultD))
        }
    }
}

/**
 Creates a promise that runs an array of promises simultaneously and unifies their results.

 - parameter promises: The array of promises to run.
 - returns: A promise whose task runs all the given promises and produces either an array of all the given promises' success values, or the first error among them.
 
 If the promises produce more than one failure, the first failure will be chosen in array order, not completion order.
 */
public func zipArray<T>(_ promises: [Promise<T>]) -> Promise<[T]> {
    return Promise { fulfill in
        let group = DispatchGroup()

        var results: [Result<T>?] = Array(repeating: nil, count: promises.count)

        for (index, promise) in promises.enumerated() {
            promise.inDispatchGroup(group).call { result in
                results[index] = result
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            let unwrappedResults = results.map { $0! }
            fulfill(zipArray(unwrappedResults))
        }
    }
}
