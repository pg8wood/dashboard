# PinkyPromise
A tiny Promises library.

[![Circle CI](https://circleci.com/gh/willowtreeapps/PinkyPromise.svg?style=svg)](https://circleci.com/gh/willowtreeapps/PinkyPromise) [![Coverage Status](https://coveralls.io/repos/github/willowtreeapps/PinkyPromise/badge.svg?branch=develop)](https://coveralls.io/github/willowtreeapps/PinkyPromise?branch=develop)

## Summary

PinkyPromise is an implementation of [Promises](https://en.wikipedia.org/wiki/Futures_and_promises) for Swift. It consists of two types:

- `Result` - A value or error. The Result type adapts the return-or-throw function pattern for use with asynchronous callbacks.
- `Promise` - An operation that produces a Result sometime after it is called. Promises can be composed and sequenced.

With PinkyPromise, you can run complex combinations of asynchronous operations with safe, clean, Swifty code.

## Installation

- With Carthage: `github "willowtreeapps/PinkyPromise"`
- With Cocoapods: `pod 'PinkyPromise'`
- Manually: Copy the files in the `Sources` folder into your project.

## Should I use this?

PinkyPromise:

- Is lightweight
- Is tested
- Embraces the Swift language with airtight type system contracts and `throw` / `catch`
- Embraces functional style with immutable values and value transformations
- Is a great way for Objective-C programmers to learn functional style in Swift
- Can be extended with your own Promise transformations

PinkyPromise is meant to be a lightweight tool that does a lot of heavy lifting. More elaborate implementations include [Result](https://github.com/antitypical/Result) and [PromiseKit](http://promisekit.org).

## Learning

Start with the [Examples](#examples) section below.

We've also written a playground to demonstrate the benefits and usage of PinkyPromise. Please clone the repository and open `PinkyPromise.playground` in Xcode.

A natural next step beyond Results and Promises is the [Observable](https://www.youtube.com/watch?v=looJcaeboBY) type. You might use PinkyPromise as a first step toward learning [RxSwift](https://github.com/ReactiveX/RxSwift), which we recommend.

## Examples

A Promise is best at running an asynchronous operation that can succeed or fail.

A Result is best at representing a success or failure from such an operation.

### Why Result?

The usual asynchronous operation pattern on iOS is a function that takes arguments and a completion block, then begins the work. The completion block will receive an optional value and an optional error when the work completes:

````swift
func getString(withArgument argument: String, completion: ((String?, ErrorType?) -> Void)?) {
    …
    if successful {
        completion?(value, nil)
    } else {
        completion?(nil, error)
    }
}

getString(withArgument: "foo") { value, error in
    if let value = value {
        print(value)
    } else {
        print(error)
    }
}
````

This is a loose contract not guaranteed by the compiler. We have only assumed that `error` is not nil when `value` is nil.

Compare with the standard Swift pattern for failable synchronous methods: A function like `Data(contentsOf:options:)` will either return a value or throw an error, not both, and not neither, and not optionally. This is an airtight contract. But you can't use that pattern in asynchronous calls, because you can only throw backward out of the function you're in, not forward into a completion block.

Here's how you'd write that asynchronous operation with a tighter contract, using Result. The Result is a success or failure. It can be created with `return` or `throw`, and inspected with `value`, which will either return or throw.

````swift
func getStringResult(withArgument argument: String, completion: ((Result<String>) -> Void)?) {
    …
    completion?(Result {
        if successful {
            return value
        } else {
            throw error
        }
    })
}
 
getStringResult(withArgument: "foo") { result in
    do {
        print(try result.value())
    } catch {
        print(error)
    }
}
````

Under the hood, `Result<T>` is an `enum` with two cases: `.Success(T)` and `.Failure(ErrorType)`. It's possible to create a Result using an enum case and inspect it using `switch`. But since Result represents a returned value or a thrown error, we prefer to use it in the style shown above.

### Why Promise?

Promises are useful for combining many asynchronous operations into one. To do that, we need to be able to create an asynchronous operation without starting it right away.

To make a new Promise, you create it with a task. A task is a block that itself takes a completion block, usually called `fulfill`. The Promise runs the task to do its work, and when it's done, the task passes a `Result` to `fulfill`. (Hint: The task used to create this Promise is the same as the body of `getStringResult(withArgument:)`.)

````swift
func getStringPromise(withArgument argument: String) -> Promise<String> {
    return Promise { fulfill in
        …
        fulfill(Result {
            if successful {
                return value
            } else {
                throw error
            }
        })
    }
}

let stringPromise = getStringPromise(withArgument: "bar")
````

`stringPromise` has captured its task, and the task has captured the argument. It is an operation waiting to begin. So with Promises you can create operations and then start them later. You can start them more than once, or not at all.
 
Next, we ask `stringPromise` to run by passing a completion block to the `call` method. `call` runs the task and routes the Result back to the completion block. When the Promise completes, our completion block will receive the Result, and can get the value or error with `try` and `catch`.

````swift
stringPromise.call { result in
    do {
        print(try result.value())
    } catch {
        print(error)
    }
}
````

As we've seen, with Promises, supplying the arguments and supplying the completion block are separate events. The greatest strength of a Promise is that in between those two events, the task-to-be-done exists as an immutable value. And in functional style, immutable values can be transformed and combined.

Here is an example of a complex Promise made of several Promises:

````swift
let getFirstThreeChildrenOfObjectWithIDPromise =
    getStringPromise(withArgument: "baz") // Promise<String>
    .flatMap { objectID in
        // String -> Promise<ModelObject>
        Queries.getObjectPromise(withID: objectID)
    }
    .map { object in
        // ModelObject -> [String]
        let childObjectIDs = object.childObjectIDs
        let count = max(3, childObjectIDs.count)
        return childObjectIDs[0..<count]
    }
    .flatMap { childObjectIDs in
        // [String] -> Promise<[ModelObject]>
        zipArray(childObjectIDs.map { childObjectID
            // String -> Promise<ModelObject>
            Queries.getObjectPromise(withID: childObjectID)
        })
    }
````

`getFirstThreeChildrenOfObjectWithIDPromise` is a single asynchronous operation that consists of many small operations. It:

1. Tries to get a String for an object ID.
2. If successful, runs an API request for the object with that ID.
3. If successful, collects up to three child IDs from the object.
4. If successful, runs simultaneous requests for each child object, producing an array.
5. Produces either a list of up to three child objects, or an error from any step of the process.

Even though this operation has many steps that depend on prior operations' success, we don't have to coordinate them by writing multiple completion blocks. Instead, we just handle the final result, using the tight contract afforded by Result:

````swift
getFirstThreeChildrenOfObjectWithIDPromise.call { [weak self] result in
    do {
        self?.updateViews(withObjects: try result.value())
    } catch {
        self?.showError(error)
    }
}
````

## Tests

We intend to keep PinkyPromise fully unit tested.

You can run tests in Xcode, or use `bundle exec fastlane run_tests` with [Fastlane](https://fastlane.tools).

We run continuous integration on [CircleCI](https://circleci.com/gh/willowtreeapps/PinkyPromise).

## Roadmap

- More Promise transformations?

## Contributing to PinkyPromise

Contributions are welcome. Please see the [Contributing guidelines](CONTRIBUTING.md).

PinkyPromise has adopted a [code of conduct](CODE_OF_CONDUCT.md) defined by the [Contributor Covenant](http://contributor-covenant.org), the same used by the [Swift language](https://swift.org) and countless other open source software teams.
