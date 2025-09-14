import SwiftUI
import CoreData

struct HierarchicalTaskRowView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    let isDarkMode: Bool
    @StateObject private var quickActionManager = QuickActionManager.shared
    @State private var showingAddSubTask = false
    @State private var newSubTaskTitle = ""
    
    // Callback for task selection
    var onTaskTapped: ((Task) -> Void)? = nil
    
    private var backgroundColor: Color {
        if task.isCompleted {
            return AgrasandhaniTheme.Colors.completedGreen.opacity(0.1)
        }
        return isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color.white
    }
    
    private var textColor: Color {
        return isDarkMode ? Color(red: 0.9, green: 0.9, blue: 0.95) : Color(red: 0.15, green: 0.15, blue: 0.15)
    }
    
    private var borderColor: Color {
        if task.isCompleted {
            return AgrasandhaniTheme.Colors.completedGreen
        }
        return isDarkMode ? Color.yellow : Color.orange
    }
    
    private var indentationWidth: CGFloat {
        CGFloat(task.indentationLevel * 20)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Main task row
            HStack(spacing: 0) {
                // Indentation
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: indentationWidth)
                
                // Task content
                mainTaskContent
            }
            
            // Subtasks (shown when expanded)
            if task.isExpanded && task.hasSubTasks {
                ForEach(task.subTasksArray, id: \.objectID) { subTask in
                    HierarchicalTaskRowView(task: subTask, isDarkMode: isDarkMode)
                }
            }
            
            // Add subtask field (shown when adding)
            if showingAddSubTask {
                addSubTaskField
            }
        }
    }
    
    private var mainTaskContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Expansion/Selection/Completion area
                HStack(spacing: 8) {
                    // Expansion toggle (only for main tasks with subtasks)
                    if task.hasSubTasks && task.isMainTask {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                task.toggleExpansion()
                                try? viewContext.save()
                            }
                        } label: {
                            Image(systemName: task.isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle.fill")
                                .font(.caption)
                                .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Hierarchical completion button
                    Button {
                        quickActionManager.quickCompleteTask(task, viewContext: viewContext)
                    } label: {
                        Image(systemName: task.hierarchicalCompletionStatus.icon)
                            .font(.title3)
                            .foregroundColor(task.hierarchicalCompletionStatus.color)
                    }
                    .buttonStyle(.plain)
                }
                
                // Task Content - Clean and Minimal
                HStack {
                    // Category emoji (only for main tasks)
                    if task.isMainTask {
                        Text(task.categoryEnum.emoji)
                            .font(.title3)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // Task title
                        Text(task.title ?? "Untitled Task")
                            .font(task.isMainTask ? .body : .callout)
                            .fontWeight(task.isMainTask ? .medium : .regular)
                            .foregroundColor(textColor)
                            .strikethrough(task.isCompleted)
                            .opacity(task.isCompleted ? 0.6 : 1.0)
                        
                        // Due date (only if exists and not completed)
                        if !task.isCompleted && !task.formattedDueDate.isEmpty {
                            Text(task.formattedDueDate)
                                .font(.caption2)
                                .foregroundColor(task.isOverdue ? .red : textColor.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    // Right side indicators - minimal
                    HStack(spacing: 8) {
                        // Subtask count (for main tasks with subtasks)
                        if task.hasSubTasks && task.isMainTask {
                            Text("\(task.completedSubTasksCount)/\(task.totalSubTasksCount)")
                                .font(.caption2)
                                .foregroundColor(textColor.opacity(0.6))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(textColor.opacity(0.1))
                                )
                        }
                        
                        // Priority dot (only for high priority)
                        if task.isMainTask && task.priorityEnum == .high {
                            Circle()
                                .fill(task.priorityEnum.color)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                
                // Quick Actions
                if task.isMainTask {
                    // Add subtask button
                    Button {
                        showingAddSubTask.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                            .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                    }
                    .buttonStyle(.plain)
                } else {
                    // Delete button for subtasks
                    Button {
                        quickActionManager.quickDeleteTask(task, viewContext: viewContext)
                    } label: {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(AgrasandhaniTheme.Colors.criticalRed.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, task.isSubTask ? 14 : 16)
            .padding(.vertical, task.isSubTask ? 10 : 12)
            .background(
                RoundedRectangle(cornerRadius: task.isSubTask ? 6 : 8)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: task.isSubTask ? 6 : 8)
                    .stroke(borderColor.opacity(0.15), lineWidth: 0.5)
            )
            .onTapGesture {
                // Open task detail sidebar for main tasks
                if task.isMainTask {
                    onTaskTapped?(task)
                }
            }
            .contextMenu {
                HierarchicalTaskContextMenu(task: task)
            }
        }
    }
    
    private var addSubTaskField: some View {
        HStack(spacing: 0) {
            // Indentation for subtask
            Rectangle()
                .fill(Color.clear)
                .frame(width: indentationWidth + 20)
            
            HStack {
                TextField("Add subtask...", text: $newSubTaskTitle)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        addSubTask()
                    }
                
                // Add Button
                Button {
                    addSubTask()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption2)
                        Text("Add")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AgrasandhaniTheme.Colors.divineAccent)
                    )
                    .foregroundColor(isDarkMode ? .black : .white)
                }
                .buttonStyle(.plain)
                .disabled(newSubTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(newSubTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                
                // Cancel Button
                Button {
                    showingAddSubTask = false
                    newSubTaskTitle = ""
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                            .font(.caption2)
                        Text("Cancel")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AgrasandhaniTheme.Colors.cardBackground)
                            .stroke(AgrasandhaniTheme.Colors.secondaryText.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                }
                .buttonStyle(.plain)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AgrasandhaniTheme.Colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AgrasandhaniTheme.Colors.divineAccent.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 8)
        }
        .animation(.easeInOut(duration: 0.2), value: showingAddSubTask)
    }
    
    private func addSubTask() {
        let trimmedTitle = newSubTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            _ = task.addSubTask(title: trimmedTitle, context: viewContext)
            try? viewContext.save()
            
            // Reset form
            newSubTaskTitle = ""
            showingAddSubTask = false
            
            // Ensure parent is expanded to show new subtask
            if !task.isExpanded {
                task.toggleExpansion()
                try? viewContext.save()
            }
        }
    }
}

// MARK: - Hierarchical Task Context Menu

struct HierarchicalTaskContextMenu: View {
    let task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var quickActionManager = QuickActionManager.shared
    
    var body: some View {
        VStack {
            Button(task.isCompleted ? "Mark Incomplete" : "Mark Complete") {
                quickActionManager.quickCompleteTask(task, viewContext: viewContext)
            }
            
            if task.isMainTask {
                Button("Add Subtask") {
                    // This will be handled by the main view's add subtask functionality
                }
                
                if task.hasSubTasks {
                    Button(task.isExpanded ? "Collapse" : "Expand") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            task.toggleExpansion()
                            try? viewContext.save()
                        }
                    }
                }
            }
            
            Button("Duplicate") {
                quickActionManager.quickDuplicateTask(task, viewContext: viewContext)
            }
            
            if task.isMainTask {
                Menu("Priority") {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Button {
                            quickActionManager.quickChangePriority(task, to: priority, viewContext: viewContext)
                        } label: {
                            HStack {
                                Image(systemName: priority.icon)
                                Text(priority.displayName)
                                if task.priorityEnum == priority {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                
                Menu("Schedule") {
                    Button("Today") {
                        quickActionManager.scheduleForToday(task, viewContext: viewContext)
                    }
                    Button("Tomorrow") {
                        quickActionManager.scheduleForTomorrow(task, viewContext: viewContext)
                    }
                    Button("This Week") {
                        quickActionManager.scheduleForThisWeek(task, viewContext: viewContext)
                    }
                }
            } else {
                // Subtask-specific actions
                Button("Edit Subtask") {
                    // This could open inline editing or a small modal
                }
            }
            
            Divider()
            
            Button("Delete", role: .destructive) {
                quickActionManager.quickDeleteTask(task, viewContext: viewContext)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context, title: "Sample Main Task")
    let subtask1 = task.addSubTask(title: "First subtask", context: context)
    let subtask2 = task.addSubTask(title: "Second subtask", context: context)
    subtask1.isCompleted = true
    
    return VStack {
        HierarchicalTaskRowView(task: task, isDarkMode: false)
            .environment(\.managedObjectContext, context)
            .environmentObject(ThemeManager.shared)
    }
    .padding()
    .background(AgrasandhaniTheme.Colors.primaryBackground)
}