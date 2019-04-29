import Vapor

final class PushController {
    
    func createHandler(_ req: Request) throws -> Future<PushModel> {
        
    }
}

extension PushController: RouteCollection {
    func boot(router: Router) throws {
        let pushRoute = router.grouped("push", "token")
        pushRoute.post(PushModel.parameter, use: createHandler)
    }
}
