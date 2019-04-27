import Vapor

public func routes(_ router: Router) throws {
    try router.register(collection: ServicesController())

    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
}
