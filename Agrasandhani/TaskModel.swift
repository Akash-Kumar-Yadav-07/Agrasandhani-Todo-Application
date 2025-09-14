//
//  TaskModel.swift
//  Agrasandhani
//
//  Created by Akash Kumar Yadav on 13/09/25.
//

import Foundation
import SwiftUI

// MARK: - Task Categories
enum TaskCategory: String, CaseIterable, Codable {
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
enum TaskPriority: Int16, CaseIterable, Codable {
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
    
    var displayName: String { name }
    
    var icon: String {
        switch self {
        case .low:
            return "arrow.down.circle"
        case .medium:
            return "minus.circle"
        case .high:
            return "arrow.up.circle"
        case .critical:
            return "exclamationmark.triangle.fill"
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
    
    // MARK: - Analytics Properties
    var completionTime: TimeInterval? {
        guard isCompleted, let created = createdDate, let completed = completedDate else { return nil }
        return completed.timeIntervalSince(created)
    }
    
    var isOverdueWhenCompleted: Bool {
        guard isCompleted, let completion = completedDate, let due = dueDate else { return false }
        return completion > due
    }
    
    var daysToComplete: Int? {
        guard isCompleted, let created = createdDate, let completed = completedDate else { return nil }
        return Calendar.current.dateComponents([.day], from: created, to: completed).day
    }
    
    var wasCompletedOnTime: Bool {
        guard isCompleted else { return false }
        guard let due = dueDate, let completion = completedDate else { return true }
        return completion <= due
    }
    
    // MARK: - Hierarchical Task Properties
    
    var isMainTask: Bool {
        return parentTaskID == nil || parentTaskID?.isEmpty == true
    }
    
    var isSubTask: Bool {
        return parentTaskID != nil && !(parentTaskID?.isEmpty ?? true)
    }
    
    var hasSubTasks: Bool {
        guard let context = managedObjectContext else { return false }
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "parentTaskID == %@", objectID.uriRepresentation().absoluteString)
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    var subTasksArray: [Task] {
        guard let context = managedObjectContext else { return [] }
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "parentTaskID == %@", objectID.uriRepresentation().absoluteString)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Task.sortOrder, ascending: true),
            NSSortDescriptor(keyPath: \Task.createdDate, ascending: true)
        ]
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
    
    var completedSubTasksCount: Int {
        return subTasksArray.filter { $0.isCompleted }.count
    }
    
    var totalSubTasksCount: Int {
        return subTasksArray.count
    }
    
    var subTaskCompletionProgress: Double {
        guard totalSubTasksCount > 0 else { return 0.0 }
        return Double(completedSubTasksCount) / Double(totalSubTasksCount)
    }
    
    var allSubTasksCompleted: Bool {
        guard hasSubTasks else { return true }
        return subTasksArray.allSatisfy { $0.isCompleted }
    }
    
    var parentTask: Task? {
        guard let parentID = parentTaskID, !parentID.isEmpty,
              let context = managedObjectContext,
              let url = URL(string: parentID),
              let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url) else {
            return nil
        }
        
        do {
            return try context.existingObject(with: objectID) as? Task
        } catch {
            return nil
        }
    }
    
    var indentationLevel: Int {
        var level = 0
        var currentTask = self.parentTask
        while currentTask != nil {
            level += 1
            currentTask = currentTask?.parentTask
        }
        return level
    }
    
    var rootTask: Task {
        var current = self
        while let parent = current.parentTask {
            current = parent
        }
        return current
    }
    
    func addSubTask(title: String, context: NSManagedObjectContext) -> Task {
        let subTask = Task(context: context)
        subTask.title = title
        subTask.parentTaskID = objectID.uriRepresentation().absoluteString
        subTask.categoryEnum = self.categoryEnum
        subTask.priorityEnum = self.priorityEnum
        subTask.createdDate = Date()
        subTask.isCompleted = false
        subTask.sortOrder = Int32(totalSubTasksCount)
        
        return subTask
    }
    
    func moveSubTask(from sourceIndex: Int, to destinationIndex: Int) {
        var tasks = subTasksArray
        guard sourceIndex < tasks.count, destinationIndex < tasks.count else { return }
        
        let movedTask = tasks.remove(at: sourceIndex)
        tasks.insert(movedTask, at: destinationIndex)
        
        for (index, task) in tasks.enumerated() {
            task.sortOrder = Int32(index)
        }
    }
    
    func toggleExpansion() {
        isExpanded.toggle()
    }
    
    func deleteSubTask(_ subTask: Task, context: NSManagedObjectContext) {
        context.delete(subTask)
        reorderSubTasks()
    }
    
    func reorderSubTasks() {
        let tasks = subTasksArray
        for (index, task) in tasks.enumerated() {
            task.sortOrder = Int32(index)
        }
    }
    
    var hierarchicalCompletionStatus: HierarchicalCompletionStatus {
        if !hasSubTasks {
            return isCompleted ? .completed : .incomplete
        }
        
        if allSubTasksCompleted && isCompleted {
            return .completed
        } else if completedSubTasksCount == 0 && !isCompleted {
            return .incomplete
        } else {
            return .partiallyCompleted
        }
    }
}

// MARK: - Analytics Data Models
struct ProductivityStats {
    let totalTasks: Int
    let completedTasks: Int
    let pendingTasks: Int
    let overdueTasks: Int
    let completionRate: Double
    let averageCompletionTime: TimeInterval?
    let currentStreak: Int
    let longestStreak: Int
    let tasksCompletedToday: Int
    let tasksCompletedThisWeek: Int
    let tasksCompletedThisMonth: Int
    
    var completionPercentage: Int {
        guard totalTasks > 0 else { return 0 }
        return Int((Double(completedTasks) / Double(totalTasks)) * 100)
    }
    
    var productivityScore: Int {
        let baseScore = min(completionPercentage, 100)
        let streakBonus = min(currentStreak * 2, 20) // Max 20 bonus points
        let timeliness = pendingTasks == 0 ? 10 : max(0, 10 - overdueTasks) // Penalty for overdue
        return min(baseScore + streakBonus + timeliness, 100)
    }
}

struct CategoryStats {
    let category: TaskCategory
    let totalTasks: Int
    let completedTasks: Int
    let completionRate: Double
    let averageCompletionTime: TimeInterval?
    
    var completionPercentage: Int {
        guard totalTasks > 0 else { return 0 }
        return Int((Double(completedTasks) / Double(totalTasks)) * 100)
    }
}

struct PriorityStats {
    let priority: TaskPriority
    let totalTasks: Int
    let completedTasks: Int
    let averageCompletionTime: TimeInterval?
    let onTimeCompletions: Int
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0.0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var onTimeRate: Double {
        guard completedTasks > 0 else { return 0.0 }
        return Double(onTimeCompletions) / Double(completedTasks)
    }
}

struct DailyProductivity {
    let date: Date
    let tasksCompleted: Int
    let tasksCreated: Int
    let totalCompletionTime: TimeInterval
    
    var averageCompletionTime: TimeInterval {
        guard tasksCompleted > 0 else { return 0 }
        return totalCompletionTime / Double(tasksCompleted)
    }
    
    var netProductivity: Int {
        return tasksCompleted - tasksCreated
    }
}

// MARK: - Goal System
struct Goal: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let type: GoalType
    let targetValue: Int
    let currentValue: Int
    let startDate: Date
    let endDate: Date
    let isCompleted: Bool
    let category: TaskCategory?
    let priority: TaskPriority?
    
    var progress: Double {
        guard targetValue > 0 else { return 0.0 }
        return min(Double(currentValue) / Double(targetValue), 1.0)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        return max(0, calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0)
    }
    
    var isExpired: Bool {
        Date() > endDate
    }
}

enum GoalType: String, CaseIterable, Codable {
    case dailyTasks = "daily_tasks"
    case weeklyTasks = "weekly_tasks"
    case monthlyTasks = "monthly_tasks"
    case streak = "streak"
    case categoryCompletion = "category_completion"
    case priorityCompletion = "priority_completion"
    case productivityScore = "productivity_score"
    
    var displayName: String {
        switch self {
        case .dailyTasks:
            return "Daily Tasks"
        case .weeklyTasks:
            return "Weekly Tasks"
        case .monthlyTasks:
            return "Monthly Tasks"
        case .streak:
            return "Streak"
        case .categoryCompletion:
            return "Category Focus"
        case .priorityCompletion:
            return "Priority Focus"
        case .productivityScore:
            return "Productivity Score"
        }
    }
    
    var icon: String {
        switch self {
        case .dailyTasks:
            return "calendar.day.timeline.left"
        case .weeklyTasks:
            return "calendar.circle"
        case .monthlyTasks:
            return "calendar"
        case .streak:
            return "flame.fill"
        case .categoryCompletion:
            return "folder.badge.questionmark"
        case .priorityCompletion:
            return "exclamationmark.triangle.fill"
        case .productivityScore:
            return "chart.line.uptrend.xyaxis"
        }
    }
    
    var color: Color {
        switch self {
        case .dailyTasks:
            return .blue
        case .weeklyTasks:
            return .green
        case .monthlyTasks:
            return .purple
        case .streak:
            return .orange
        case .categoryCompletion:
            return .cyan
        case .priorityCompletion:
            return .red
        case .productivityScore:
            return .indigo
        }
    }
}

// MARK: - Streak System
struct StreakData: Codable {
    let currentStreak: Int
    let longestStreak: Int
    let lastCompletionDate: Date?
    let streakStartDate: Date?
    let milestones: [StreakMilestone]
    
    var isActive: Bool {
        guard let lastDate = lastCompletionDate else { return false }
        let calendar = Calendar.current
        let today = Date()
        return calendar.isDate(lastDate, inSameDayAs: today) || 
               calendar.isDate(lastDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today) ?? today)
    }
    
    var nextMilestone: StreakMilestone? {
        return StreakMilestone.allCases.first { $0.days > currentStreak }
    }
}

enum StreakMilestone: Int, CaseIterable, Codable {
    case three = 3
    case seven = 7
    case fourteen = 14
    case thirty = 30
    case sixty = 60
    case hundred = 100
    case threeSixtyFive = 365
    
    var days: Int { rawValue }
    
    var title: String {
        switch self {
        case .three:
            return "3-Day Starter"
        case .seven:
            return "Week Warrior"
        case .fourteen:
            return "Two Week Champion"
        case .thirty:
            return "Month Master"
        case .sixty:
            return "Two Month Legend"
        case .hundred:
            return "100-Day Hero"
        case .threeSixtyFive:
            return "Year-Long Achiever"
        }
    }
    
    var description: String {
        switch self {
        case .three:
            return "Complete tasks for 3 consecutive days"
        case .seven:
            return "Complete tasks for 7 consecutive days"
        case .fourteen:
            return "Complete tasks for 2 consecutive weeks"
        case .thirty:
            return "Complete tasks for 30 consecutive days"
        case .sixty:
            return "Complete tasks for 2 consecutive months"
        case .hundred:
            return "Complete tasks for 100 consecutive days"
        case .threeSixtyFive:
            return "Complete tasks for a full year"
        }
    }
    
    var icon: String {
        switch self {
        case .three:
            return "3.circle.fill"
        case .seven:
            return "7.circle.fill"
        case .fourteen:
            return "14.circle.fill"
        case .thirty:
            return "30.circle.fill"
        case .sixty:
            return "60.circle.fill"
        case .hundred:
            return "100.circle.fill"
        case .threeSixtyFive:
            return "365.circle.fill"
        }
    }
    
    var reward: String {
        switch self {
        case .three:
            return "🔥 Fire Badge"
        case .seven:
            return "⚡ Lightning Badge"
        case .fourteen:
            return "💎 Diamond Badge"
        case .thirty:
            return "👑 Crown Badge"
        case .sixty:
            return "🏆 Trophy Badge"
        case .hundred:
            return "🌟 Superstar Badge"
        case .threeSixtyFive:
            return "🎖️ Legend Badge"
        }
    }
}

// MARK: - Hierarchical Task Types

enum HierarchicalCompletionStatus {
    case completed
    case incomplete
    case partiallyCompleted
    
    var icon: String {
        switch self {
        case .completed:
            return "checkmark.circle.fill"
        case .incomplete:
            return "circle"
        case .partiallyCompleted:
            return "circle.lefthalf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .completed:
            return .green
        case .incomplete:
            return .gray
        case .partiallyCompleted:
            return .orange
        }
    }
}