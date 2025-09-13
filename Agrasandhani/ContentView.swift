//
//  ContentView.swift
//  Agrasandhani
//
//  Created by Akash Kumar Yadav on 13/09/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isDarkMode") private var isDarkModeStorage: Bool = true
    @State private var isDarkMode: Bool = true
    @State private var showingAddTask = false
    @State private var selectedCategory: TaskCategory? = nil
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \Task.priority, ascending: false),
            NSSortDescriptor(keyPath: \Task.dueDate, ascending: true)
        ],
        animation: .default)
    private var tasks: FetchedResults<Task>

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack(spacing: 0) {
                // Divine Header
                divineHeader
                    .frame(height: 120)
                
                // Category Filter  
                categoryFilter
                    .frame(height: 60)
                
                // Tasks List
                tasksList
            }
            .background(AgrasandhaniTheme.Colors.primaryBackground)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addTaskButton
                }
                ToolbarItem(placement: .automatic) {
                    themeToggleButton
                }
            }
            .toolbarBackground(AgrasandhaniTheme.Colors.secondaryBackground, for: .automatic)
            .toolbarColorScheme(isDarkMode ? .dark : .light, for: .automatic)
            .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 500)
        } detail: {
            divineWelcomeView
        }
        .navigationSplitViewStyle(.balanced)
        .background(AgrasandhaniTheme.Colors.primaryBackground)
        .toolbarBackground(AgrasandhaniTheme.Colors.primaryBackground, for: .windowToolbar)
        .toolbarColorScheme(isDarkMode ? .dark : .light, for: .windowToolbar)
        .navigationTitle("Agrasandhani")
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
                .environment(\.managedObjectContext, viewContext)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            isDarkMode = isDarkModeStorage
        }
        .onChange(of: isDarkModeStorage) {
            isDarkMode = isDarkModeStorage
        }
    }
    
    // MARK: - Divine Header
    private var divineHeader: some View {
        GeometryReader { geometry in
            VStack(spacing: AgrasandhaniTheme.Spacing.sm) {
                HStack(spacing: AgrasandhaniTheme.Spacing.xs) {
                    Image(systemName: "scroll")
                        .font(geometry.size.width < 350 ? .title3 : .title2)
                        .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                    
                    Text("अग्रसन्धानी")
                        .font(geometry.size.width < 350 ? .title2 : AgrasandhaniTheme.Typography.titleFont)
                        .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                    
                    if geometry.size.width > 300 {
                        Text("Divine Ledger")
                            .font(geometry.size.width < 350 ? AgrasandhaniTheme.Typography.smallFont : AgrasandhaniTheme.Typography.captionFont)
                            .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                    }
                }
                
                // Task Summary - Adaptive Layout
                if geometry.size.width > 280 {
                    HStack(spacing: AgrasandhaniTheme.Spacing.xs) {
                        taskSummaryCard("Active", count: activeTasks.count, color: AgrasandhaniTheme.Colors.hopeGlow, compact: geometry.size.width < 350)
                        taskSummaryCard("Done", count: completedTasks.count, color: AgrasandhaniTheme.Colors.completedGreen, compact: geometry.size.width < 350)
                        taskSummaryCard("Due", count: overdueTasks.count, color: AgrasandhaniTheme.Colors.warningAmber, compact: geometry.size.width < 350)
                    }
                }
            }
            .padding(geometry.size.width < 350 ? AgrasandhaniTheme.Spacing.sm : AgrasandhaniTheme.Spacing.md)
            .background(
                AgrasandhaniTheme.Colors.divineGradient
                    .opacity(0.1)
            )
        }
        .frame(height: 120)
    }
    
    private func taskSummaryCard(_ title: String, count: Int, color: Color, compact: Bool = false) -> some View {
        VStack(spacing: compact ? AgrasandhaniTheme.Spacing.xxs : AgrasandhaniTheme.Spacing.xs) {
            Text("\(count)")
                .font(compact ? AgrasandhaniTheme.Typography.bodyFont : AgrasandhaniTheme.Typography.headerFont)
                .foregroundColor(color)
            Text(title)
                .font(compact ? .caption2 : AgrasandhaniTheme.Typography.smallFont)
                .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: compact ? 40 : 50)
        .padding(compact ? AgrasandhaniTheme.Spacing.xs : AgrasandhaniTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.small)
                .fill(color.opacity(0.1))
        )
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryFilterButton(nil, title: "All", emoji: "📋")
                    
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        categoryFilterButton(category, title: category.rawValue, emoji: category.emoji)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
            .background(AgrasandhaniTheme.Colors.secondaryBackground)
            
            Divider()
                .background(AgrasandhaniTheme.Colors.divineAccent.opacity(0.2))
        }
    }
    
    private func categoryFilterButton(_ category: TaskCategory?, title: String, emoji: String) -> some View {
        let isSelected = selectedCategory == category
        
        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                Text(emoji)
                    .font(.callout)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? 
                          AgrasandhaniTheme.Colors.divineAccent : 
                          Color.clear)
            )
            .foregroundColor(isSelected ? Color.white : AgrasandhaniTheme.Colors.primaryText)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : AgrasandhaniTheme.Colors.secondaryText.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Tasks List
    private var tasksList: some View {
        List {
            ForEach(filteredTasks) { task in
                TaskRowView(task: task, isDarkMode: isDarkMode)
                    .listRowBackground(AgrasandhaniTheme.Colors.primaryBackground)
                    .listRowSeparator(.hidden)
                    .padding(.vertical, AgrasandhaniTheme.Spacing.xs)
            }
            .onDelete(perform: deleteTasks)
        }
        .listStyle(.plain)
        .background(AgrasandhaniTheme.Colors.primaryBackground)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Add Task Button
    private var addTaskButton: some View {
        Button {
            showingAddTask = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("Add Task")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(AgrasandhaniTheme.Colors.divineAccent)
            )
            .foregroundColor(Color.white)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Theme Toggle Button  
    private var themeToggleButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isDarkMode.toggle()
                isDarkModeStorage = isDarkMode
            }
        } label: {
            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                .font(.callout)
                .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                .padding(6)
                .background(
                    Circle()
                        .fill(AgrasandhaniTheme.Colors.cardBackground.opacity(0.8))
                        .stroke(AgrasandhaniTheme.Colors.divineAccent.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Welcome View
    private var divineWelcomeView: some View {
        VStack(spacing: AgrasandhaniTheme.Spacing.lg) {
            Image(systemName: "scroll.fill")
                .font(.system(size: 60))
                .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                .darkModeGlow()
            
            VStack(spacing: AgrasandhaniTheme.Spacing.md) {
                Text("Divine Ledger Awaits")
                    .divineTitle()
                
                Text("Select a task from the ledger\nor add a new divine entry")
                    .divineBody()
                    .multilineTextAlignment(.center)
            }
            
            // Inspirational Quote
            VStack(spacing: AgrasandhaniTheme.Spacing.sm) {
                Text("कर्मण्येवाधिकारस्ते मा फलेषु कदाचन")
                    .font(AgrasandhaniTheme.Typography.captionFont)
                    .foregroundColor(AgrasandhaniTheme.Colors.accentText)
                    .motivationalGlow()
                
                Text("You have the right to perform your actions,\nbut you are not entitled to the fruits of action")
                    .font(AgrasandhaniTheme.Typography.smallFont)
                    .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                
                // Additional motivational text for dark mode
                if isDarkMode {
                    Text("✨ Transform darkness into light through action ✨")
                        .motivationalText()
                        .motivationalGlow()
                }
            }
            .padding(AgrasandhaniTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                    .fill(AgrasandhaniTheme.Colors.cardGradient.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                    .stroke(AgrasandhaniTheme.Colors.divineAccent.opacity(0.2), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AgrasandhaniTheme.Colors.primaryBackground)
    }
    
    // MARK: - Computed Properties
    private var activeTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }
    
    private var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }
    
    private var overdueTasks: [Task] {
        tasks.filter { $0.isOverdue }
    }
    
    private var filteredTasks: [Task] {
        if let selectedCategory = selectedCategory {
            return tasks.filter { $0.categoryEnum == selectedCategory }
        }
        return Array(tasks)
    }
    
    // MARK: - Methods
    private func deleteTasks(offsets: IndexSet) {
        withAnimation(AgrasandhaniTheme.Animations.smoothEase) {
            offsets.map { filteredTasks[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting task: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// MARK: - Task Row View (Completely Rewritten)
struct TaskRowView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) private var viewContext
    let isDarkMode: Bool
    
    // Computed colors that will update when isDarkMode changes
    private var backgroundColor: Color {
        if task.isCompleted {
            return Color.green.opacity(0.1)
        }
        return isDarkMode ? Color(red: 0.12, green: 0.12, blue: 0.18) : Color.white
    }
    
    private var textColor: Color {
        return isDarkMode ? Color(red: 0.9, green: 0.9, blue: 0.95) : Color(red: 0.15, green: 0.15, blue: 0.15)
    }
    
    private var borderColor: Color {
        return task.isCompleted ? Color.green : (isDarkMode ? Color.yellow : Color.orange)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Completion Button
            Button {
                task.isCompleted.toggle()
                task.completedDate = task.isCompleted ? Date() : nil
                try? viewContext.save()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(task.isCompleted ? Color.green : textColor)
            }
            .buttonStyle(.plain)
            
            // Task Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.categoryEnum.emoji)
                        .font(.body)
                    
                    Text(task.title ?? "Untitled Task")
                        .font(.body)
                        .foregroundColor(textColor)
                        .strikethrough(task.isCompleted)
                        .opacity(task.isCompleted ? 0.6 : 1.0)
                    
                    Spacer()
                    
                    // Priority indicator
                    Circle()
                        .fill(task.priorityEnum.color)
                        .frame(width: 8, height: 8)
                        .opacity(task.isCompleted ? 0.3 : 1.0)
                }
                
                // Due date and notes
                if task.dueDate != nil || (task.notes?.isEmpty == false) {
                    VStack(alignment: .leading, spacing: 4) {
                        if !task.formattedDueDate.isEmpty {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(task.isOverdue ? Color.orange : textColor.opacity(0.7))
                                Text(task.formattedDueDate)
                                    .font(.caption)
                                    .foregroundColor(task.isOverdue ? Color.orange : textColor.opacity(0.7))
                            }
                        }
                        
                        if let notes = task.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(textColor.opacity(0.7))
                                .lineLimit(2)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor.opacity(0.3), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isDarkMode)
        .animation(.easeInOut(duration: 0.3), value: task.isCompleted)
    }
}

// MARK: - Add Task View
struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var themeManager: ThemeManager
    
    @State private var title = ""
    @State private var selectedCategory = TaskCategory.personalGoals
    @State private var notes = ""
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var selectedPriority = TaskPriority.medium
    
    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy, h:mm a"
        return formatter.string(from: dueDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AgrasandhaniTheme.Spacing.lg) {
                    // Header with Close Button
                    VStack(spacing: AgrasandhaniTheme.Spacing.sm) {
                        HStack {
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, AgrasandhaniTheme.Spacing.md)
                        .padding(.top, AgrasandhaniTheme.Spacing.sm)
                        
                        Image(systemName: "scroll.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                            .darkModeGlow()
                        
                        Text("Add Divine Entry")
                            .font(AgrasandhaniTheme.Typography.titleFont)
                            .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                        
                        Text("Record a new task in the sacred ledger")
                            .font(AgrasandhaniTheme.Typography.captionFont)
                            .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AgrasandhaniTheme.Spacing.md)
                    }
                    .padding(.bottom, AgrasandhaniTheme.Spacing.lg)
                    
                    // Form Card
                    VStack(spacing: AgrasandhaniTheme.Spacing.md) {
                        // Title Field
                        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.xs) {
                            HStack {
                                Image(systemName: "pencil.and.scribble")
                                    .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                                Text("Task Title")
                                    .font(AgrasandhaniTheme.Typography.captionFont)
                                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                            }
                            
                            TextField("What needs to be accomplished?", text: $title)
                                .textFieldStyle(.plain)
                                .padding(AgrasandhaniTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                                        .fill(AgrasandhaniTheme.Colors.secondaryBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                                                .stroke(AgrasandhaniTheme.Colors.divineAccent.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.xs) {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                                Text("Category")
                                    .font(AgrasandhaniTheme.Typography.captionFont)
                                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: AgrasandhaniTheme.Spacing.sm) {
                                ForEach(TaskCategory.allCases, id: \.self) { category in
                                    categoryButton(category, compact: false)
                                }
                            }
                        }
                        
                        // Priority Selection
                        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.xs) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                                Text("Priority")
                                    .font(AgrasandhaniTheme.Typography.captionFont)
                                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                            }
                            
                            VStack(spacing: AgrasandhaniTheme.Spacing.xs) {
                                HStack {
                                    priorityButton(TaskPriority.low, compact: false)
                                    priorityButton(TaskPriority.medium, compact: false)
                                }
                                HStack {
                                    priorityButton(TaskPriority.high, compact: false)
                                    priorityButton(TaskPriority.critical, compact: false)
                                }
                            }
                        }
                        
                        // Due Date Toggle
                        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.xs) {
                            HStack {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                                    Text("Set Due Date")
                                        .font(AgrasandhaniTheme.Typography.captionFont)
                                        .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $hasDueDate)
                                    .toggleStyle(.switch)
                            }
                            
                            if hasDueDate {
                                VStack(spacing: AgrasandhaniTheme.Spacing.sm) {
                                    HStack(spacing: AgrasandhaniTheme.Spacing.sm) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Date")
                                                .font(.caption2)
                                                .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                                            DatePicker("", selection: $dueDate, displayedComponents: [.date])
                                                .datePickerStyle(.compact)
                                                .labelsHidden()
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Time")
                                                .font(.caption2)
                                                .foregroundColor(AgrasandhaniTheme.Colors.secondaryText)
                                            DatePicker("", selection: $dueDate, displayedComponents: [.hourAndMinute])
                                                .datePickerStyle(.compact)
                                                .labelsHidden()
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    
                                    // Clean formatted display
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .font(.caption2)
                                            .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                                        
                                        Text(formattedSelectedDate)
                                            .font(.caption)
                                            .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, AgrasandhaniTheme.Spacing.sm)
                                    .padding(.vertical, AgrasandhaniTheme.Spacing.xs)
                                    .background(
                                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.small)
                                            .fill(AgrasandhaniTheme.Colors.divineAccent.opacity(0.1))
                                    )
                                }
                                .padding(AgrasandhaniTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                                        .fill(AgrasandhaniTheme.Colors.secondaryBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                                                .stroke(AgrasandhaniTheme.Colors.divineAccent.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        // Notes Field
                        VStack(alignment: .leading, spacing: AgrasandhaniTheme.Spacing.xs) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(AgrasandhaniTheme.Colors.divineAccent)
                                Text("Notes (Optional)")
                                    .font(AgrasandhaniTheme.Typography.captionFont)
                                    .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
                            }
                            
                            TextField("Additional details...", text: $notes, axis: .vertical)
                                .textFieldStyle(.plain)
                                .lineLimit(3...6)
                                .padding(AgrasandhaniTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                                        .fill(AgrasandhaniTheme.Colors.secondaryBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                                                .stroke(AgrasandhaniTheme.Colors.divineAccent.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(AgrasandhaniTheme.Spacing.lg)
                    .divineCard()
                }
                .padding(.horizontal, AgrasandhaniTheme.Spacing.md)
                .padding(.vertical, AgrasandhaniTheme.Spacing.lg)
            }
            
            // Action Buttons - Fixed at bottom
            VStack(spacing: AgrasandhaniTheme.Spacing.md) {
                Divider()
                    .background(AgrasandhaniTheme.Colors.divineAccent.opacity(0.3))
                
                HStack(spacing: AgrasandhaniTheme.Spacing.md) {
                    // Cancel Button
                    CancelButton {
                        dismiss()
                    }
                    
                    // Save Button
                    SaveButton(isEnabled: !title.isEmpty) {
                        addTask()
                    }
                }
                .padding(.horizontal, AgrasandhaniTheme.Spacing.lg)
                .padding(.bottom, AgrasandhaniTheme.Spacing.lg)
            }
            .background(AgrasandhaniTheme.Colors.primaryBackground)
        }
        .background(AgrasandhaniTheme.Colors.primaryBackground)
    }
    
    private func categoryButton(_ category: TaskCategory, compact: Bool = false) -> some View {
        let isSelected = selectedCategory == category
        @State var isHovered = false
        
        return Button {
            withAnimation(AgrasandhaniTheme.Animations.quickSpring) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: compact ? AgrasandhaniTheme.Spacing.xs : AgrasandhaniTheme.Spacing.sm) {
                Text(category.emoji)
                    .font(compact ? .caption : .body)
                Text(category.rawValue)
                    .font(compact ? .caption : AgrasandhaniTheme.Typography.smallFont)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Spacer()
            }
            .padding(compact ? AgrasandhaniTheme.Spacing.xs : AgrasandhaniTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.small)
                    .fill(backgroundColor(isSelected: isSelected, isHovered: isHovered))
                    .overlay(
                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.small)
                            .stroke(borderColor(isSelected: isSelected, isHovered: isHovered), lineWidth: 1)
                    )
            )
            .foregroundColor(textColor(isSelected: isSelected, isHovered: isHovered))
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    private func backgroundColor(isSelected: Bool, isHovered: Bool) -> Color {
        if isSelected {
            return AgrasandhaniTheme.Colors.divineAccent.opacity(0.3)
        } else if isHovered {
            return AgrasandhaniTheme.Colors.divineAccent.opacity(0.1)
        } else {
            return AgrasandhaniTheme.Colors.secondaryBackground
        }
    }
    
    private func borderColor(isSelected: Bool, isHovered: Bool) -> Color {
        if isSelected {
            return AgrasandhaniTheme.Colors.divineAccent
        } else if isHovered {
            return AgrasandhaniTheme.Colors.divineAccent.opacity(0.6)
        } else {
            return AgrasandhaniTheme.Colors.divineAccent.opacity(0.3)
        }
    }
    
    private func textColor(isSelected: Bool, isHovered: Bool) -> Color {
        if isSelected {
            return AgrasandhaniTheme.Colors.divineAccent
        } else {
            return AgrasandhaniTheme.Colors.primaryText
        }
    }
    
    private func priorityButton(_ priority: TaskPriority, compact: Bool = false) -> some View {
        let isSelected = selectedPriority == priority
        @State var isHovered = false
        
        return Button {
            withAnimation(AgrasandhaniTheme.Animations.quickSpring) {
                selectedPriority = priority
            }
        } label: {
            HStack(spacing: compact ? AgrasandhaniTheme.Spacing.xxs : AgrasandhaniTheme.Spacing.xs) {
                Circle()
                    .fill(priority.color)
                    .frame(width: compact ? 6 : 8, height: compact ? 6 : 8)
                Text(priority.name)
                    .font(compact ? .caption2 : AgrasandhaniTheme.Typography.smallFont)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .padding(.horizontal, compact ? AgrasandhaniTheme.Spacing.sm : AgrasandhaniTheme.Spacing.md)
            .padding(.vertical, compact ? AgrasandhaniTheme.Spacing.xs : AgrasandhaniTheme.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.full)
                    .fill(priorityBackgroundColor(priority: priority, isSelected: isSelected, isHovered: isHovered))
                    .overlay(
                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.full)
                            .stroke(priorityBorderColor(priority: priority, isSelected: isSelected, isHovered: isHovered), lineWidth: 1)
                    )
            )
            .foregroundColor(priorityTextColor(priority: priority, isSelected: isSelected, isHovered: isHovered))
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    private func priorityBackgroundColor(priority: TaskPriority, isSelected: Bool, isHovered: Bool) -> Color {
        if isSelected {
            return priority.color.opacity(0.25)
        } else if isHovered {
            return priority.color.opacity(0.1)
        } else {
            return AgrasandhaniTheme.Colors.secondaryBackground
        }
    }
    
    private func priorityBorderColor(priority: TaskPriority, isSelected: Bool, isHovered: Bool) -> Color {
        if isSelected {
            return priority.color
        } else if isHovered {
            return priority.color.opacity(0.6)
        } else {
            return AgrasandhaniTheme.Colors.divineAccent.opacity(0.3)
        }
    }
    
    private func priorityTextColor(priority: TaskPriority, isSelected: Bool, isHovered: Bool) -> Color {
        if isSelected {
            return priority.color
        } else {
            return AgrasandhaniTheme.Colors.primaryText
        }
    }
    
    private func addTask() {
        guard !title.isEmpty else { return }
        
        let newTask = Task(context: viewContext, title: title, category: selectedCategory)
        newTask.notes = notes.isEmpty ? nil : notes
        newTask.dueDate = hasDueDate ? dueDate : nil
        newTask.priorityEnum = selectedPriority
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving task: \(error)")
        }
    }
}

// MARK: - Custom Button Components
struct CancelButton: View {
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button("Cancel", action: action)
            .foregroundColor(AgrasandhaniTheme.Colors.primaryText)
            .padding(AgrasandhaniTheme.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                    .fill(isHovered ? AgrasandhaniTheme.Colors.secondaryBackground : AgrasandhaniTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                            .stroke(isHovered ? AgrasandhaniTheme.Colors.divineAccent.opacity(0.4) : AgrasandhaniTheme.Colors.secondaryText.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
    }
}

struct SaveButton: View {
    let isEnabled: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button("Add to Divine Ledger", action: action)
            .foregroundColor(.white)
            .padding(AgrasandhaniTheme.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AgrasandhaniTheme.CornerRadius.medium)
                    .fill(backgroundGradient)
            )
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1.0 : 0.6)
            .scaleEffect(isHovered && isEnabled ? 1.02 : 1.0)
            .shadow(color: isHovered && isEnabled ? AgrasandhaniTheme.Colors.divineAccent.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 2)
            .buttonStyle(.plain)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering && isEnabled
                }
            }
    }
    
    private var backgroundGradient: LinearGradient {
        if isHovered && isEnabled {
            return LinearGradient(
                gradient: Gradient(colors: [
                    AgrasandhaniTheme.Colors.divineAccent,
                    AgrasandhaniTheme.Colors.divineAccent.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [AgrasandhaniTheme.Colors.divineAccent, AgrasandhaniTheme.Colors.divineAccent]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
