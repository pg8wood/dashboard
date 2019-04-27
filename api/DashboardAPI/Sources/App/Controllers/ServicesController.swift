import Vapor

final class ServicesController {
    
    func createHandler(_ req: Request) throws -> Future<Service> {
        // Decide request body JSON and save resulting Service to database.
        return try req.content.decode(Service.self).flatMap { (service) in
            return service.save(on: req)
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Service]> {
        return Service.query(on: req).decode(Service.self).all()
    }
    
    func getOneHandler(_ req: Request) throws -> Future<Service> {
        return try req.parameters.next(Service.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Service> {
        return try flatMap(to: Service.self, req.parameters.next(Service.self), req.content.decode(Service.self)) { (oldService, newService) in
            oldService.name = newService.name
            oldService.url = newService.url
            return oldService.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Service.self).flatMap { (service) in
            return service.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
}

extension ServicesController: RouteCollection {
    func boot(router: Router) throws {
        let servicesRoute = router.grouped("dashboard", "services")
        servicesRoute.get(use: getAllHandler)
        servicesRoute.get(Service.parameter, use: getOneHandler)
        servicesRoute.post(use: createHandler)
        servicesRoute.put(Service.parameter, use: updateHandler)
        servicesRoute.delete(Service.parameter, use: deleteHandler)
    }
}
