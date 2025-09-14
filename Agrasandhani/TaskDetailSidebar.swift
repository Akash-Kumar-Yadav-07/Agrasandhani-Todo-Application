import SwiftUI
import CoreData

struct TaskDetailSidebar: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var quickActionManager = QuickActionManager.shared
    @Binding var isPresented: Bool
    
    @State private var editingTitle = ""
    @State private var editingNotes = ""
    @State private var editingDueDate = Date()
    @State private var hasDueDate = false
    @State private var selectedPriority = TaskPriority.medium
    @State private var selectedCategory = TaskCategory.personalGoals
    @State private var showingDeleteConfirmation = false
    @State private var hasUnsavedChanges = false
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            headerView
                .background(AgrasandhaniTheme.Colors.cardBackground)
            
            // Task details content
            ScrollView {
                VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.lg) {
                    // Task Title Section
                    taskTitleSection
                    
                    // Task Status Section
                    taskStatusSection
                    
                    // Priority & Category Section
                    priorityCategorySection
                    
                    // Due Date Section
                    dueDateSection
                    
                    // Notes Section
                    notesSection
                    
                    // Subtasks Section (if applicable)
                    if task.isMainTask {
                        subtasksSection
                    }
                    
                    // Quick Actions Section
                    quickActionsSection
                    
                    // Save Section
                    saveSection
                }
                .padding(AgrasandhaniTheme.Spacing.lg)
            }
            .background(AgrasandhaniTheme.Colors.primaryBackground)
        }
        .frame(width: 350)
        .background(AgrasandhaniTheme.Colors.primaryBackground)
        .onAppear {
            loadTaskData()
        }
        .onChange(of: task.objectID) {
            loadTaskData()
        }
        .onChange(of: editingTitle) { checkForChanges() }
        .onChange(of: editingNotes) { checkForChanges() }
        .onChange(of: selectedPriority) { checkForChanges() }
        .onChange(of: selectedCategory) { checkForChanges() }
        .onChange(of: hasDueDate) { checkForChanges() }
        .onChange(of: editingDueDate) { checkForChanges() }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Task Details")
                    .font(AgrasandhaniTheme.Typography.titleFont)
                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                
                Text(task.categoryEnum.emoji + " " + task.categoryEnum.rawValue)
                    .font(.caption)
                    .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            Button {
                // Close without saving
                isPresented = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
            }
            .buttonStyle(.plain)
        }
        .padding(AgrasandhaniTheme.Spacing.lg)
    }
    
    private var taskTitleSection: some View {
        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.sm) {
            Label("Title", systemImage: "pencil.and.scribble")
                .font(.headline)
                .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
            
            TextField("Task title", text: $editingTitle)
                .textFieldStyle(.plain)
                .font(.body)
                .padding(AgrasandhaniTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                        .fill(AgrasandhaniTheme.Colors.cardBackground)
                        .stroke(AgrasandhaniTheme.Colors.divineAccent.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
        }
    }
    
    private var taskStatusSection: some View {
        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.sm) {
            Label("Status", systemImage: "checkmark.circle")
                .font(.headline)
                .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
            
            HStack {
                Button {
                    quickActionManager.quickCompleteTask(task, viewContext: viewContext)
                } label: {
                    HStack {
                        Image(systemName: task.hierarchicalCompletionStatus.icon)
                            .foregroundColor(task.hierarchicalCompletionStatus.color)
                        
                        Text(task.isCompleted ? "Completed" : "Pending")
                            .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                    }
                    .padding(AgrasandhaniTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                            .fill(task.hierarchicalCompletionStatus.color.opacity(0.1))
                            .stroke(task.hierarchicalCompletionStatus.color.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                if task.hasSubTasks {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(task.completedSubTasksCount)/\(task.totalSubTasksCount) subtasks")
                            .font(.caption)
                            .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                        
                        ProgressView(value: task.subTaskCompletionProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: AgrasandhaniTheme.Colors.divineAccent))
                            .frame(width: 100)
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private var priorityCategorySection: some View {
        HStack(spacing: AgrasandhaniTheme.Spacing.lg) {
            // Priority Section
            VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.sm) {
                Label("Priority", systemImage: "exclamationmark.triangle")
                    .font(.headline)
                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                
                Menu {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Button {
                            selectedPriority = priority
                            quickActionManager.quickChangePriority(task, to: priority, viewContext: viewContext)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 8, height: 8)
                                Text(priority.displayName)
                                if task.priorityEnum == priority {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Circle()
                            .fill(selectedPriority.color)
                            .frame(width: 12, height: 12)
                        Text(selectedPriority.displayName)
                            .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                    }
                    .padding(AgrasandhaniTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                            .fill(AgrasandhaniTheme.Colors.cardBackground)
                            .stroke(selectedPriority.color.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Category Section
            VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.sm) {
                Label("Category", systemImage: "tag")
                    .font(.headline)
                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                
                Menu {
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        Button {
                            selectedCategory = category
                            quickActionManager.quickChangeCategory(task, to: category, viewContext: viewContext)
                        } label: {
                            HStack {
                                Text(category.emoji)
                                Text(category.rawValue)
                                if task.categoryEnum == category {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedCategory.emoji)
                        Text(selectedCategory.rawValue)
                            .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                    }
                    .padding(AgrasandhaniTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                            .fill(AgrasandhaniTheme.Colors.cardBackground)
                            .stroke(selectedCategory.color.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.sm) {
            HStack {
                Label("Due Date", systemImage: "calendar")
                    .font(.headline)
                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                
                Spacer()
                
                Toggle("", isOn: $hasDueDate)
                    .toggleStyle(SwitchToggleStyle())
            }
            
            if hasDueDate {
                VStack(spacing: AgrasandhaniTheme.Spacing.sm) {
                    DatePicker("Due Date", selection: $editingDueDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                    
                    if task.dueDate != nil {
                        HStack {
                            Image(systemName: task.isOverdue ? "exclamationmark.triangle" : "clock")
                                .foregroundColor(task.isOverdue ? .orange : AgrasandhaniTheme.Colors.divineAccent)
                            
                            Text(task.formattedDueDate)
                                .font(.caption)
                                .foregroundColor(task.isOverdue ? .orange : AgrasandhaniTheme.Colors.primaryText)
                        }
                        .padding(.horizontal, AgrasandhaniTheme.Spacing.sm)
                    }
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.sm) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)
                .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
            
            TextField("Add notes...", text: $editingNotes, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(3...6)
                .padding(AgrasandhaniTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                        .fill(AgrasandhaniTheme.Colors.cardBackground)
                        .stroke(AgrasandhaniTheme.Colors.divineAccent.opacity(0.3), lineWidth: 1)
                )
                .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
        }
    }
    
    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.sm) {
            HStack {
                Label("Subtasks", systemImage: "list.bullet.indent")
                    .font(.headline)
                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                
                Spacer()
                
                Text("\(task.completedSubTasksCount) of \(task.totalSubTasksCount)")
                    .font(.caption)
                    .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
            }
            
            if task.hasSubTasks {
                VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.xs) {
                    ForEach(task.subTasksArray.prefix(3), id: \.objectID) { subtask in
                        HStack {
                            Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(subtask.isCompleted ? .green : AgrasandhaniTheme.Colors.secondaryText)
                                .font(.caption)
                            
                            Text(subtask.title ?? "")
                                .font(.caption)
                                .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                                .strikethrough(subtask.isCompleted)
                        }
                    }
                    
                    if task.totalSubTasksCount > 3 {
                        Text("+ \(task.totalSubTasksCount - 3) more subtasks")
                            .font(.caption2)
                            .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                    }
                }
            } else {
                Text("No subtasks")
                    .font(.caption)
                    .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.sm) {
            Label("Quick Actions", systemImage: "bolt")
                .font(.headline)
                .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AgrasandhaniTheme.Spacing.sm) {
                
                actionButton("Schedule Today", icon: "calendar.day.timeline.left", color: .blue) {
                    quickActionManager.scheduleForToday(task, viewContext: viewContext)
                    loadTaskData()
                }
                
                actionButton("Schedule Tomorrow", icon: "calendar.badge.plus", color: .indigo) {
                    quickActionManager.scheduleForTomorrow(task, viewContext: viewContext)
                    loadTaskData()
                }
                
                actionButton("Mark Urgent", icon: "exclamationmark.triangle.fill", color: .orange) {
                    quickActionManager.markAsUrgent(task, viewContext: viewContext)
                    loadTaskData()
                }
                
                actionButton("Duplicate", icon: "doc.on.doc.fill", color: .cyan) {
                    quickActionManager.quickDuplicateTask(task, viewContext: viewContext)
                }
                
                actionButton("Postpone 1 Day", icon: "clock.arrow.circlepath", color: .gray) {
                    quickActionManager.postponeTask(task, by: 1, viewContext: viewContext)
                    loadTaskData()
                }
                
                actionButton("Delete", icon: "trash.fill", color: .red, isDestructive: true) {
                    showingDeleteConfirmation = true
                }
            }
        }
        .alert("Delete Task", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                quickActionManager.quickDeleteTask(task, viewContext: viewContext)
                isPresented = false
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
    }
    
    private var saveSection: some View {
        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.sm) {
            Divider()
                .background(AgrasandhaniTheme.Colors.divineAccent.opacity(0.2))
            
            HStack(spacing: AgrasandhaniTheme.Spacing.md) {
                // Cancel Button
                Button {
                    // Reload original data without saving
                    loadTaskData()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.caption)
                        Text("Reset")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.small)
                            .fill(AgrasandhaniTheme.Colors.cardBackground)
                            .stroke(AgrasandhaniTheme.Colors.secondaryText.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Save Button
                Button {
                    saveChanges()
                    hasUnsavedChanges = false
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: hasUnsavedChanges ? "exclamationmark.circle" : "checkmark.circle")
                            .font(.caption)
                        Text(hasUnsavedChanges ? "Save Changes" : "Saved")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.small)
                            .fill(hasUnsavedChanges ? AgrasandhaniTheme.Colors.divineAccent : AgrasandhaniTheme.Colors.completedGreen)
                    )
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .disabled(!hasUnsavedChanges)
            }
        }
    }
    
    private func actionButton(_ title: String, icon: String, color: Color, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AgrasandhaniTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.small)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.small)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func loadTaskData() {
        editingTitle = task.title ?? ""
        editingNotes = task.notes ?? ""
        selectedPriority = task.priorityEnum
        selectedCategory = task.categoryEnum
        hasDueDate = task.dueDate != nil
        if let dueDate = task.dueDate {
            editingDueDate = dueDate
        }
        hasUnsavedChanges = false
    }
    
    private func checkForChanges() {
        let titleChanged = editingTitle != (task.title ?? "")
        let notesChanged = editingNotes != (task.notes ?? "")
        let priorityChanged = selectedPriority != task.priorityEnum
        let categoryChanged = selectedCategory != task.categoryEnum
        let dueDateToggleChanged = hasDueDate != (task.dueDate != nil)
        let dueDateValueChanged = hasDueDate && task.dueDate != nil && editingDueDate != task.dueDate!
        
        hasUnsavedChanges = titleChanged || notesChanged || priorityChanged || categoryChanged || dueDateToggleChanged || dueDateValueChanged
    }
    
    private func saveChanges() {
        task.title = editingTitle.isEmpty ? "Untitled Task" : editingTitle
        task.notes = editingNotes.isEmpty ? nil : editingNotes
        
        if hasDueDate {
            task.dueDate = editingDueDate
        } else {
            task.dueDate = nil
        }
        
        try? viewContext.save()
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context, title: "Sample Task")
    task.notes = "This is a sample task with some notes"
    
    return TaskDetailSidebar(task: task, isPresented: .constant(true))
        .environment(\.managedObjectContext, context)
        .environmentObject(ThemeManager.shared)
        .frame(height: 600)
}