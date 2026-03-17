//
//  Persistence.swift
//  dszhdanokPW2
//
//  Created by Дарья Жданок on 9.11.25.
//

import CoreData

final class Persistence {
    static let shared = Persistence()
    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, err in
            if let err = err { fatalError("CoreData: \(err)") }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        let ctx = container.viewContext
        if ctx.hasChanges { try? ctx.save() }
    }
    
    func wipeAllTickets() {
        let ctx = container.viewContext
        let fetch: NSFetchRequest<NSFetchRequestResult> = Ticket.fetchRequest()
        let deleteReq = NSBatchDeleteRequest(fetchRequest: fetch)
        deleteReq.resultType = .resultTypeObjectIDs
        
        do {
            if let result = try ctx.execute(deleteReq) as? NSBatchDeleteResult,
               let ids = result.result as? [NSManagedObjectID] {
                let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: ids]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [ctx])
            }
            try ctx.save()
            ctx.refreshAllObjects()
        } catch {
            print("wipeAllWishes error:", error)
        }
    }
}
