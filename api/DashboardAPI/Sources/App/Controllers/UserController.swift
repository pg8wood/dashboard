import Vapor

final class UserController {
    
    func createHandler(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap { (user) in
            return user.save(on: req)
        }
    }
}

extension UserController: RouteCollection {
    func boot(router: Router) throws {
        let pushRoute = router.grouped("dashboard", "users")
        pushRoute.post(User.parameter, use: createHandler)
    }
}
