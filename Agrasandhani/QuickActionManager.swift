import Foundation
import SwiftUI
import CoreData

class QuickActionManager: ObservableObject {
    static let shared = QuickActionManager()
    
    @Published var selectedTasks: Set<NSManagedObjectID> = []
    @Published var isMultiSelectMode: Bool = false
    @Published var showingBatchOperations: Bool = false
    
    private init() {}
    
    // MARK: - Selection Management
    
    func toggleSelection(for task: Task) {
        if selectedTasks.contains(task.objectID) {
            selectedTasks.remove(task.objectID)
        } else {
            selectedTasks.insert(task.objectID)
        }
        
        if selectedTasks.isEmpty {
            isMultiSelectMode = false
        }
    }
    
    func selectAll(tasks: [Task]) {
        selectedTasks = Set(tasks.map { $0.objectID })
        isMultiSelectMode = true
    }
    
    func deselectAll() {
        selectedTasks.removeAll()
        isMultiSelectMode = false
    }
    
    func isSelected(_ task: Task) -> Bool {
        selectedTasks.contains(task.objectID)
    }
    
    // MARK: - Quick Actions
    
    func quickCompleteTask(_ task: Task, viewContext: NSManagedObjectContext) {
        withAnimation(.easeInOut(duration: 0.3)) {
            task.isCompleted.toggle()
            if task.isCompleted {
                task.completedDate = Date()
                
                // If this is a main task, mark all subtasks as completed
                if task.isMainTask && task.hasSubTasks {
                    for subTask in task.subTasksArray {
                        subTask.isCompleted = true
                        subTask.completedDate = Date()
                    }
                }
            } else {
                task.completedDate = nil
                
                // If this is a main task, mark all subtasks as incomplete
                if task.isMainTask && task.hasSubTasks {
                    for subTask in task.subTasksArray {
                        subTask.isCompleted = false
                        subTask.completedDate = nil
                    }
                }
                
                // If this is a subtask, ensure parent is not marked as completed
                if task.isSubTask, let parent = task.parentTask {
                    parent.isCompleted = false
                    parent.completedDate = nil
                }
            }
            
            try? viewContext.save()
        }
    }
    
    func quickDeleteTask(_ task: Task, viewContext: NSManagedObjectContext) {
        withAnimation(.easeInOut(duration: 0.2)) {
            viewContext.delete(task)
            try? viewContext.save()
        }
    }
    
    func quickDuplicateTask(_ task: Task, viewContext: NSManagedObjectContext) {
        let newTask = Task(context: viewContext)
        newTask.title = "\(task.title ?? "") (Copy)"
        newTask.notes = task.notes
        newTask.category = task.category
        newTask.priority = task.priority
        newTask.createdDate = Date()
        newTask.isCompleted = false
        
        // Set due date 1 day later if original has one
        if let originalDue = task.dueDate {
            newTask.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: originalDue)
        }
        
        try? viewContext.save()
    }
    
    func quickChangePriority(_ task: Task, to priority: TaskPriority, viewContext: NSManagedObjectContext) {
        task.priorityEnum = priority
        try? viewContext.save()
    }
    
    func quickChangeCategory(_ task: Task, to category: TaskCategory, viewContext: NSManagedObjectContext) {
        task.categoryEnum = category
        try? viewContext.save()
    }
    
    func quickSetDueDate(_ task: Task, to date: Date?, viewContext: NSManagedObjectContext) {
        task.dueDate = date
        try? viewContext.save()
    }
    
    // MARK: - Batch Operations
    
    func batchComplete(_ complete: Bool, viewContext: NSManagedObjectContext) {
        for taskID in selectedTasks {
            if let task = try? viewContext.existingObject(with: taskID) as? Task {
                task.isCompleted = complete
                if complete {
                    task.completedDate = Date()
                } else {
                    task.completedDate = nil
                }
            }
        }
        try? viewContext.save()
        deselectAll()
    }
    
    func batchDelete(viewContext: NSManagedObjectContext) {
        for taskID in selectedTasks {
            if let task = try? viewContext.existingObject(with: taskID) as? Task {
                viewContext.delete(task)
            }
        }
        try? viewContext.save()
        deselectAll()
    }
    
    func batchChangePriority(to priority: TaskPriority, viewContext: NSManagedObjectContext) {
        for taskID in selectedTasks {
            if let task = try? viewContext.existingObject(with: taskID) as? Task {
                task.priorityEnum = priority
            }
        }
        try? viewContext.save()
        deselectAll()
    }
    
    func batchChangeCategory(to category: TaskCategory, viewContext: NSManagedObjectContext) {
        for taskID in selectedTasks {
            if let task = try? viewContext.existingObject(with: taskID) as? Task {
                task.categoryEnum = category
            }
        }
        try? viewContext.save()
        deselectAll()
    }
    
    func batchSetDueDate(to date: Date?, viewContext: NSManagedObjectContext) {
        for taskID in selectedTasks {
            if let task = try? viewContext.existingObject(with: taskID) as? Task {
                task.dueDate = date
            }
        }
        try? viewContext.save()
        deselectAll()
    }
    
    // MARK: - Preset Quick Actions
    
    func markAsUrgent(_ task: Task, viewContext: NSManagedObjectContext) {
        task.priorityEnum = .high
        task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        try? viewContext.save()
    }
    
    func postponeTask(_ task: Task, by days: Int, viewContext: NSManagedObjectContext) {
        if let currentDue = task.dueDate {
            task.dueDate = Calendar.current.date(byAdding: .day, value: days, to: currentDue)
        } else {
            task.dueDate = Calendar.current.date(byAdding: .day, value: days, to: Date())
        }
        try? viewContext.save()
    }
    
    func scheduleForToday(_ task: Task, viewContext: NSManagedObjectContext) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let scheduleTime = calendar.date(byAdding: .hour, value: 9, to: today) // 9 AM
        task.dueDate = scheduleTime
        try? viewContext.save()
    }
    
    func scheduleForTomorrow(_ task: Task, viewContext: NSManagedObjectContext) {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let tomorrowStart = calendar.startOfDay(for: tomorrow)
        let scheduleTime = calendar.date(byAdding: .hour, value: 9, to: tomorrowStart) // 9 AM
        task.dueDate = scheduleTime
        try? viewContext.save()
    }
    
    func scheduleForThisWeek(_ task: Task, viewContext: NSManagedObjectContext) {
        let calendar = Calendar.current
        let today = Date()
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.end ?? today
        task.dueDate = calendar.date(byAdding: .day, value: -1, to: endOfWeek) // Friday
        try? viewContext.save()
    }
    
    // MARK: - Keyboard Shortcuts
    
    struct KeyboardShortcuts {
        static let complete = KeyEquivalent("c")
        static let delete = KeyEquivalent("\u{7F}") // Delete key
        static let duplicate = KeyEquivalent("d")
        static let markUrgent = KeyEquivalent("u")
        static let scheduleToday = KeyEquivalent("1")
        static let scheduleTomorrow = KeyEquivalent("2")
        static let scheduleThisWeek = KeyEquivalent("3")
        static let postponeOneDay = KeyEquivalent("p")
        static let selectAll = KeyEquivalent("a")
        static let deselectAll = KeyEquivalent("\u{1B}") // Escape key
        static let batchOperations = KeyEquivalent("b")
    }
}

// MARK: - Quick Action Types

enum QuickActionType: String, CaseIterable {
    case complete = "Complete"
    case delete = "Delete"
    case duplicate = "Duplicate"
    case markUrgent = "Mark Urgent"
    case scheduleToday = "Schedule Today"
    case scheduleTomorrow = "Schedule Tomorrow"
    case scheduleThisWeek = "Schedule This Week"
    case postponeOneDay = "Postpone 1 Day"
    case postponeThreeDays = "Postpone 3 Days"
    case postponeOneWeek = "Postpone 1 Week"
    
    var icon: String {
        switch self {
        case .complete:
            return "checkmark.circle.fill"
        case .delete:
            return "trash.fill"
        case .duplicate:
            return "doc.on.doc.fill"
        case .markUrgent:
            return "exclamationmark.triangle.fill"
        case .scheduleToday:
            return "calendar.day.timeline.left"
        case .scheduleTomorrow:
            return "calendar.badge.plus"
        case .scheduleThisWeek:
            return "calendar.circle"
        case .postponeOneDay:
            return "clock.arrow.circlepath"
        case .postponeThreeDays:
            return "clock.arrow.2.circlepath"
        case .postponeOneWeek:
            return "arrow.clockwise"
        }
    }
    
    var color: Color {
        switch self {
        case .complete:
            return .green
        case .delete:
            return .red
        case .duplicate:
            return .blue
        case .markUrgent:
            return .orange
        case .scheduleToday:
            return .purple
        case .scheduleTomorrow:
            return .indigo
        case .scheduleThisWeek:
            return .cyan
        case .postponeOneDay, .postponeThreeDays, .postponeOneWeek:
            return .gray
        }
    }
    
    var keyboardShortcut: KeyEquivalent? {
        switch self {
        case .complete:
            return QuickActionManager.KeyboardShortcuts.complete
        case .delete:
            return QuickActionManager.KeyboardShortcuts.delete
        case .duplicate:
            return QuickActionManager.KeyboardShortcuts.duplicate
        case .markUrgent:
            return QuickActionManager.KeyboardShortcuts.markUrgent
        case .scheduleToday:
            return QuickActionManager.KeyboardShortcuts.scheduleToday
        case .scheduleTomorrow:
            return QuickActionManager.KeyboardShortcuts.scheduleTomorrow
        case .scheduleThisWeek:
            return QuickActionManager.KeyboardShortcuts.scheduleThisWeek
        case .postponeOneDay:
            return QuickActionManager.KeyboardShortcuts.postponeOneDay
        default:
            return nil
        }
    }
}

// MARK: - Batch Operation Types

enum BatchOperationType: String, CaseIterable {
    case complete = "Mark Complete"
    case incomplete = "Mark Incomplete"
    case delete = "Delete All"
    case changePriority = "Change Priority"
    case changeCategory = "Change Category"
    case setDueDate = "Set Due Date"
    case clearDueDate = "Clear Due Date"
    
    var icon: String {
        switch self {
        case .complete:
            return "checkmark.circle.fill"
        case .incomplete:
            return "circle"
        case .delete:
            return "trash.fill"
        case .changePriority:
            return "arrow.up.circle.fill"
        case .changeCategory:
            return "tag.fill"
        case .setDueDate:
            return "calendar.badge.plus"
        case .clearDueDate:
            return "calendar.badge.minus"
        }
    }
    
    var color: Color {
        switch self {
        case .complete:
            return .green
        case .incomplete:
            return .blue
        case .delete:
            return .red
        case .changePriority:
            return .orange
        case .changeCategory:
            return .purple
        case .setDueDate:
            return .indigo
        case .clearDueDate:
            return .gray
        }
    }
    
    var isDestructive: Bool {
        self == .delete
    }
}