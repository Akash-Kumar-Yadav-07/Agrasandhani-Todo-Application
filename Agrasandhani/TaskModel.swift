//
//  TaskModel.swift
//  Agrasandhani
//
//  Created by Akash Kumar Yadav on 13/09/25.
//

import Foundation
import SwiftUI

// MARK: - Task Categories
enum TaskCategory: String, CaseIterable {
    case meetings = "Meetings"
    case exams = "Exams"
    case classes = "Classes"
    case errands = "Errands"
    case personalGoals = "Personal Goals"
    
    var emoji: String {
        switch self {
        case .meetings:
            return "🤝"
        case .exams:
            return "📝"
        case .classes:
            return "📚"
        case .errands:
            return "🏃‍♂️"
        case .personalGoals:
            return "🎯"
        }
    }
    
    var color: Color {
        switch self {
        case .meetings:
            return .blue
        case .exams:
            return .red
        case .classes:
            return .green
        case .errands:
            return .orange
        case .personalGoals:
            return .purple
        }
    }
}

// MARK: - Task Priority
enum TaskPriority: Int16, CaseIterable {
    case low = 1
    case medium = 2
    case high = 3
    case critical = 4
    
    var name: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .critical:
            return "Critical"
        }
    }
    
    var color: Color {
        switch self {
        case .low:
            return .gray
        case .medium:
            return .blue
        case .high:
            return .orange
        case .critical:
            return .red
        }
    }
}

// MARK: - Recurrence Pattern
enum RecurrencePattern: String, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
}

// MARK: - Task Extensions
extension Task {
    var categoryEnum: TaskCategory {
        get {
            TaskCategory(rawValue: category ?? "Personal") ?? .personalGoals
        }
        set {
            category = newValue.rawValue
        }
    }
    
    var priorityEnum: TaskPriority {
        get {
            TaskPriority(rawValue: priority) ?? .medium
        }
        set {
            priority = newValue.rawValue
        }
    }
    
    var recurrencePatternEnum: RecurrencePattern? {
        get {
            guard let pattern = recurrencePattern else { return nil }
            return RecurrencePattern(rawValue: pattern)
        }
        set {
            recurrencePattern = newValue?.rawValue
        }
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }
    
    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    var isDueTomorrow: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInTomorrow(dueDate)
    }
    
    var formattedDueDate: String {
        guard let dueDate = dueDate else { return "" }
        
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(dueDate) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if Calendar.current.isDateInTomorrow(dueDate) {
            formatter.dateFormat = "'Tomorrow at' h:mm a"
        } else if Calendar.current.isDateInYesterday(dueDate) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else {
            formatter.dateFormat = "MMM d 'at' h:mm a"
        }
        
        return formatter.string(from: dueDate)
    }
    
    convenience init(context: NSManagedObjectContext, title: String, category: TaskCategory = .personalGoals) {
        self.init(context: context)
        self.title = title
        self.categoryEnum = category
        self.createdDate = Date()
        self.isCompleted = false
        self.priorityEnum = .medium
        self.isRecurring = false
    }
}