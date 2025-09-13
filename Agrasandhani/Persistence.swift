//
//  Persistence.swift
//  Agrasandhani
//
//  Created by Akash Kumar Yadav on 13/09/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample tasks for preview
        let sampleTasks = [
            ("Complete project proposal", TaskCategory.meetings),
            ("Study for final exam", TaskCategory.exams),
            ("Attend SwiftUI class", TaskCategory.classes),
            ("Buy groceries", TaskCategory.errands),
            ("Learn new programming language", TaskCategory.personalGoals)
        ]
        
        for (title, category) in sampleTasks {
            let newTask = Task(context: viewContext, title: title, category: category)
            if category == .exams {
                newTask.dueDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())
                newTask.priorityEnum = .high
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Agrasandhani")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
