//
//  PromiseQueue.swift
//  PinkyPromise
//
//  Created by Kevin Conner on 8/19/16.
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

/// A simple queue that runs one Promise at a time in the order they're added.

public final class PromiseQueue<Value> {

    /// The promise that is currently executing, if any.
    private var runningPromise: Promise<Value>?
    /// Promises that are waiting to begin.
    private var remainingPromises: [Promise<Value>] = []

    /// Creates a queue.
    public init() {}

    /**
     Creates a promise that enqueues an array of promises and unifies their results.

     - parameter promises: The array of promises to run.
     - returns: A promise whose task runs all the given promises and produces either an array of all the given promises' success values, or the first error among them.
     */
    public func batch(promises: [Promise<Value>]) -> Promise<[Value]> {
        return Promise { fulfill in
            var results: [Result<Value>] = []

            guard let lastPromise = promises.last else {
                fulfill(zipArray(results))
                return
            }

            for promise in promises.dropLast() {
                promise
                    .onResult { result in
                        results.append(result)
                    }
                    .enqueue(in: self)
            }

            lastPromise
                .onResult { result in
                    results.append(result)
                    fulfill(zipArray(results))
                }
                .enqueue(in: self)
        }
    }

    // MARK: Helpers

    /**
     Adds a promise to the queue.
     
     - parameter promise: The promise to be enqueued.

     The promise will begin when all the previously enqueued promises have completed.
     If the queue was empty, the promise will begin immediately.
     */
    fileprivate func add(_ promise: Promise<Value>) {
        remainingPromises.append(promise)

        continueIfIdle()
    }

    /// Begins the next promise, provided that no promise is running and the queue is not empty.
    private func continueIfIdle() {
        guard runningPromise == nil, let promise = remainingPromises.first else {
            return
        }

        remainingPromises.removeFirst()
        runningPromise = promise

        promise.call { _ in
            self.runningPromise = nil
            self.continueIfIdle()
        }
    }

}

public extension Promise {

    /**
     Adds a promise to a queue.

     - parameter queue: A queue that will run the promise.

     In order to work with a `PromiseQueue`, use `enqueue` instead of `call`.
     The queue will invoke `call` when all its previously enqueued promises have completed.
     */
    public func enqueue(in queue: PromiseQueue<Value>) {
        queue.add(self)
    }
    
}
