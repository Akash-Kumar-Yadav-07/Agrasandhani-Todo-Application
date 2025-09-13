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

// MARK: - Date Filter
enum DateFilter: String, CaseIterable {
    case all = "all"
    case today = "today"
    case tomorrow = "tomorrow"
    case thisWeek = "thisWeek"
    case overdue = "overdue"
    case noDueDate = "noDueDate"
    
    var displayName: String {
        switch self {
        case .all:
            return "All Dates"
        case .today:
            return "Today"
        case .tomorrow:
            return "Tomorrow"
        case .thisWeek:
            return "This Week"
        case .overdue:
            return "Overdue"
        case .noDueDate:
            return "No Due Date"
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "calendar"
        case .today:
            return "calendar.circle"
        case .tomorrow:
            return "calendar.badge.plus"
        case .thisWeek:
            return "calendar.circle.fill"
        case .overdue:
            return "calendar.badge.exclamationmark"
        case .noDueDate:
            return "calendar.badge.minus"
        }
    }
}

// MARK: - Status Filter
enum StatusFilter: String, CaseIterable {
    case all = "all"
    case pending = "pending"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .all:
            return "All Tasks"
        case .pending:
            return "Pending"
        case .completed:
            return "Completed"
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "list.bullet"
        case .pending:
            return "circle"
        case .completed:
            return "checkmark.circle.fill"
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
    
    var isDueThisWeek: Bool {
        guard let dueDate = dueDate else { return false }
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
        return dueDate >= startOfWeek && dueDate <= endOfWeek
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