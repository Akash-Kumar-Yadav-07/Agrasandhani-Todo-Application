import SwiftUI
import CoreData

struct QuickActionsView: View {
    let task: Task
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var quickActionManager = QuickActionManager.shared
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var showingFullMenu = false
    
    var body: some View {
        HStack(spacing: AgrasandhaniTheme.Spacing.xs) {
            // Quick actions menu only (completion is handled by the main button on the left)
            Menu {
                quickActionMenuContent
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
            }
            .buttonStyle(.plain)
            .menuStyle(.borderlessButton)
        }
    }
    
    @ViewBuilder
    private var quickActionMenuContent: some View {
        // Priority actions
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
        
        // Category actions
        Menu("Category") {
            ForEach(TaskCategory.allCases, id: \.self) { category in
                Button {
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
        }
        
        Divider()
        
        // Schedule actions
        Button("Schedule Today") {
            quickActionManager.scheduleForToday(task, viewContext: viewContext)
        }
        .keyboardShortcut(QuickActionManager.KeyboardShortcuts.scheduleToday, modifiers: .command)
        
        Button("Schedule Tomorrow") {
            quickActionManager.scheduleForTomorrow(task, viewContext: viewContext)
        }
        .keyboardShortcut(QuickActionManager.KeyboardShortcuts.scheduleTomorrow, modifiers: .command)
        
        Button("Schedule This Week") {
            quickActionManager.scheduleForThisWeek(task, viewContext: viewContext)
        }
        .keyboardShortcut(QuickActionManager.KeyboardShortcuts.scheduleThisWeek, modifiers: .command)
        
        Divider()
        
        // Postpone actions
        Button("Postpone 1 Day") {
            quickActionManager.postponeTask(task, by: 1, viewContext: viewContext)
        }
        .keyboardShortcut(QuickActionManager.KeyboardShortcuts.postponeOneDay, modifiers: .command)
        
        Button("Postpone 3 Days") {
            quickActionManager.postponeTask(task, by: 3, viewContext: viewContext)
        }
        
        Button("Postpone 1 Week") {
            quickActionManager.postponeTask(task, by: 7, viewContext: viewContext)
        }
        
        Divider()
        
        // Other actions
        Button("Mark Urgent") {
            quickActionManager.markAsUrgent(task, viewContext: viewContext)
        }
        .keyboardShortcut(QuickActionManager.KeyboardShortcuts.markUrgent, modifiers: .command)
        
        Button("Duplicate") {
            quickActionManager.quickDuplicateTask(task, viewContext: viewContext)
        }
        .keyboardShortcut(QuickActionManager.KeyboardShortcuts.duplicate, modifiers: .command)
        
        Divider()
        
        Button("Delete", role: .destructive) {
            quickActionManager.quickDeleteTask(task, viewContext: viewContext)
        }
        .keyboardShortcut(QuickActionManager.KeyboardShortcuts.delete, modifiers: .command)
    }
}

// MARK: - Batch Operations View

struct BatchOperationsView: View {
    @StateObject private var quickActionManager = QuickActionManager.shared
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var selectedBatchOperation: BatchOperationType?
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedCategory: TaskCategory = .meetings
    @State private var selectedDueDate = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.md) {
            // Header
            HStack {
                Text("Batch Operations")
                    .font(AgrasandhaniTheme.Typography.headerFont)
                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                
                Text("(\(quickActionManager.selectedTasks.count) selected)")
                    .font(AgrasandhaniTheme.Typography.captionFont)
                    .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                
                Spacer()
                
                Button("Clear Selection") {
                    quickActionManager.deselectAll()
                }
                .font(AgrasandhaniTheme.Typography.captionFont)
                .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
            }
            
            // Quick batch actions
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AgrasandhaniTheme.Spacing.sm) {
                batchActionButton(.complete, "Complete All") {
                    quickActionManager.batchComplete(true, viewContext: viewContext)
                }
                
                batchActionButton(.incomplete, "Mark Pending") {
                    quickActionManager.batchComplete(false, viewContext: viewContext)
                }
                
                batchActionButton(.delete, "Delete All") {
                    quickActionManager.batchDelete(viewContext: viewContext)
                }
            }
            
            Divider()
            
            // Detailed batch operations
            VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.sm) {
                Text("Advanced Operations")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                
                // Priority change
                HStack {
                    Text("Priority:")
                        .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 8, height: 8)
                                Text(priority.displayName)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                    
                    Button("Apply") {
                        quickActionManager.batchChangePriority(to: selectedPriority, viewContext: viewContext)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AgrasandhaniTheme.Colors.divineAccent)
                    .font(.caption)
                }
                
                // Category change
                HStack {
                    Text("Category:")
                        .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.emoji)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                    
                    Button("Apply") {
                        quickActionManager.batchChangeCategory(to: selectedCategory, viewContext: viewContext)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AgrasandhaniTheme.Colors.divineAccent)
                    .font(.caption)
                }
                
                // Due date change
                HStack {
                    Text("Due Date:")
                        .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                    
                    DatePicker("", selection: $selectedDueDate, displayedComponents: [.date])
                        .frame(width: 120)
                    
                    Button("Apply") {
                        quickActionManager.batchSetDueDate(to: selectedDueDate, viewContext: viewContext)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AgrasandhaniTheme.Colors.divineAccent)
                    .font(.caption)
                    
                    Button("Clear") {
                        quickActionManager.batchSetDueDate(to: nil, viewContext: viewContext)
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
            }
        }
        .padding(AgrasandhaniTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                .fill(AgrasandhaniTheme.Colors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                        .stroke(AgrasandhaniTheme.Colors.divineAccent.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: AgrasandhaniTheme.Colors.shadowColor, radius: 4, x: 0, y: 2)
    }
    
    private func batchActionButton(_ type: BatchOperationType, _ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(type.color)
                
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
                    .fill(type.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.small)
                            .stroke(type.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Action Toolbar

struct QuickActionToolbar: View {
    @StateObject private var quickActionManager = QuickActionManager.shared
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: AgrasandhaniTheme.Spacing.md) {
            // Multi-select toggle
            Button {
                quickActionManager.isMultiSelectMode.toggle()
                if !quickActionManager.isMultiSelectMode {
                    quickActionManager.deselectAll()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: quickActionManager.isMultiSelectMode ? "checkmark.square.fill" : "square")
                    Text("Multi-Select")
                        .font(.caption)
                }
            }
            .foregroundColor(quickActionManager.isMultiSelectMode ? AgrasandhaniTheme.Colors.divineAccent : AgrasandhaniTheme.Colors.secondaryText)
            
            Spacer()
            
            if quickActionManager.isMultiSelectMode && !quickActionManager.selectedTasks.isEmpty {
                Text("\(quickActionManager.selectedTasks.count) selected")
                    .font(.caption)
                    .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                
                Button("Batch Operations") {
                    quickActionManager.showingBatchOperations.toggle()
                }
                .font(.caption)
                .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                .keyboardShortcut(QuickActionManager.KeyboardShortcuts.batchOperations, modifiers: .command)
            }
        }
        .padding(.horizontal, AgrasandhaniTheme.Spacing.md)
        .padding(.vertical, AgrasandhaniTheme.Spacing.sm)
        .background(AgrasandhaniTheme.Colors.secondaryBackground)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let task = Task(context: context, title: "Sample Task")
    
    return VStack {
        QuickActionsView(task: task)
            .environment(\.managedObjectContext, context)
            .environmentObject(ThemeManager.shared)
        
        BatchOperationsView()
            .environment(\.managedObjectContext, context)
            .environmentObject(ThemeManager.shared)
    }
    .padding()
    .background(AgrasandhaniTheme.Colors.primaryBackground)
}