# 🌟 Agrasandhani MCP Server - Complete Usage Guide

Welcome to the divine realm of AI-powered task management! This guide will help you harness the cosmic power of the Agrasandhani MCP Server with Claude and other AI assistants.

## 🕉️ What is the Agrasandhani MCP Server?

The Agrasandhani MCP Server is a **Model Context Protocol** implementation that allows AI assistants like Claude to directly interact with your Agrasandhani task management system. Think of it as a bridge between AI and your divine productivity workflow.

### 🌈 Key Benefits
- **Natural Language Task Management** - Talk to Claude about your tasks in plain English
- **Intelligent Task Organization** - AI understands context and can suggest optimal categorization
- **Automated Productivity Insights** - Get divine analytics on your task completion patterns
- **Seamless Integration** - Works with your existing Agrasandhani SwiftUI app
- **Cross-Platform Compatibility** - JSON-based storage works everywhere

---

## 🚀 Getting Started

### Prerequisites
- Node.js 18+ installed
- Claude Desktop application (recommended)
- Your Agrasandhani MCP Server built and ready

### Quick Setup

1. **Build the Server** (if not already done):
   ```bash
   cd agrasandhani-mcp
   npm install
   npm run build
   ```

2. **Test the Server**:
   ```bash
   npm start
   # You should see: 🌟 Agrasandhani MCP Server started
   ```

3. **Configure Claude Desktop**:
   Add this to `~/Library/Application Support/Claude/claude_desktop_config.json`:
   ```json
   {
     "mcpServers": {
       "agrasandhani": {
         "command": "node",
         "args": ["/path/to/agrasandhani-mcp/dist/index.js"],
         "env": {
           "AGRASANDHANI_DB_PATH": "/path/to/your/tasks.json"
         }
       }
     }
   }
   ```

4. **Restart Claude Desktop** and you're ready for divine productivity!

---

## 🛠️ Available MCP Tools

The Agrasandhani MCP Server provides 8 powerful tools for comprehensive task management:

### 1. 🎯 `create_task` - Create Divine Tasks
**Purpose**: Create new main tasks or subtasks with cosmic categorization

**Example Usage**:
```
"Create a new task: 'Complete quarterly meditation practice' in the Spiritual category with high priority, due next Friday"
```

**Parameters**:
- `title` (required): Task title
- `notes` (optional): Detailed description
- `category` (optional): One of the 7 sacred categories
- `priority` (optional): Low, Medium, High, or Critical
- `dueDate` (optional): ISO date string or natural language
- `parentTaskID` (optional): For creating subtasks

### 2. 📋 `get_tasks` - Retrieve Divine Tasks
**Purpose**: List and filter tasks with advanced search capabilities

**Example Usage**:
```
"Show me all high priority tasks in the Work Projects category that are overdue"
```

**Filtering Options**:
- By category, priority, completion status
- Date ranges and overdue tasks  
- Text search across titles and notes
- Parent/child relationships

### 3. ✨ `update_task` - Modify Tasks
**Purpose**: Update any aspect of existing tasks

**Example Usage**:
```
"Change the priority of task 'Learn Sanskrit' to Critical and add a note about finding a good teacher"
```

### 4. 🗑️ `delete_task` - Remove Tasks
**Purpose**: Delete tasks and all associated subtasks

**Example Usage**:
```
"Delete the task 'Old project cleanup' and all its subtasks"
```

### 5. 📊 `get_task_stats` - Divine Analytics
**Purpose**: Get comprehensive statistics about your productivity

**Example Usage**:
```
"Give me detailed statistics about my task completion patterns"
```

**Returns**:
- Total, active, completed, and overdue task counts
- Breakdown by category and priority
- Productivity insights

### 6. 🔍 `get_task_details` - Deep Task Inspection
**Purpose**: Get complete details about a specific task

**Example Usage**:
```
"Show me all details about the task 'Morning yoga routine'"
```

### 7. ✅ `complete_task` - Mark Tasks Complete
**Purpose**: Mark tasks as completed with cosmic acknowledgment

**Example Usage**:
```
"Mark the task 'Daily meditation' as completed"
```

### 8. 🌱 `create_subtask` - Add Sub-Tasks
**Purpose**: Create hierarchical subtasks under existing main tasks

**Example Usage**:
```
"Under the task 'Learn web development', create a subtask 'Complete React tutorial' with medium priority"
```

---

## 🏷️ Sacred Categories System

The Agrasandhani system organizes tasks into 7 divine categories:

| Category | Icon | Purpose | Example Tasks |
|----------|------|---------|---------------|
| **Personal Goals** | 🎯 | Self-improvement & aspirations | Learn meditation, Read 12 books this year |
| **Work Projects** | 💼 | Professional tasks | Quarterly report, Client presentation |
| **Health & Fitness** | 💪 | Physical & mental wellness | Gym workout, Doctor appointment |
| **Meetings** | 🤝 | Scheduled gatherings | Team standup, Coffee with mentor |
| **Learning** | 📚 | Education & skill development | Online course, Language practice |
| **Home & Family** | 🏠 | Household & family tasks | Grocery shopping, Family dinner |
| **Spiritual** | 🕉️ | Meditation & spiritual practice | Morning prayers, Temple visit |

---

## ⚡ Priority Levels

Tasks can have 4 priority levels:

- 🟢 **Low** - Nice to have, flexible timing
- 🟡 **Medium** - Standard priority (default)
- 🟠 **High** - Important, needs attention soon  
- 🔴 **Critical** - Urgent, immediate action required

---

## 💬 Natural Language Examples

Here are practical examples of how to interact with your MCP server through Claude:

### Creating Tasks
```
You: "I need to prepare for my presentation next week. Create a high-priority task in Work Projects with a due date of next Wednesday."

Claude: ✨ Task created successfully! 
📋 "Prepare presentation" 
🏷️ Work Projects | 🟠 High Priority
📅 Due: Next Wednesday
```

### Managing Subtasks
```
You: "For my presentation task, I need subtasks for research, creating slides, and practicing delivery."

Claude: 🌱 Created 3 divine subtasks under "Prepare presentation":
1. 📚 Research topic thoroughly
2. 🎨 Create presentation slides  
3. 🎯 Practice delivery and timing
```

### Getting Insights
```
You: "How am I doing with my spiritual tasks this month?"

Claude: 🕉️ Divine Spiritual Category Analysis:
- 📊 Total: 8 tasks
- ✅ Completed: 5 (62.5%)
- 🔄 Active: 3
- ⚡ Average completion time: 3.2 days

Recent completions: Daily meditation (5 days), Temple visit, Scripture reading...
```

### Smart Filtering
```
You: "Show me all overdue tasks that aren't in the meetings category."

Claude: 📋 Overdue Tasks (excluding meetings):
🔴 Critical: Complete tax filing (overdue by 3 days)
🟠 High: Gym membership renewal (overdue by 1 day)
🟡 Medium: Update LinkedIn profile (overdue by 5 days)
```

---

## 🗂️ Data Storage & Integration

### Storage Location
- **Default**: `~/.agrasandhani/tasks.json`
- **Custom**: Set `AGRASANDHANI_DB_PATH` environment variable
- **Format**: JSON with full task hierarchy and metadata

### SwiftUI App Integration
The MCP server shares the same data model as your SwiftUI app:
- ✅ **Compatible** with Core Data structure
- 🔄 **Real-time sync** when using shared database
- 📱 **Cross-platform** data access

### Database Schema
```json
{
  "tasks": [
    {
      "id": "uuid",
      "title": "Task title",
      "notes": "Optional notes",
      "category": "Personal Goals",
      "priority": "Medium",
      "isCompleted": false,
      "dueDate": "2024-01-15T09:00:00Z",
      "createdAt": "2024-01-10T10:30:00Z",
      "updatedAt": "2024-01-10T10:30:00Z",
      "parentTaskID": null,
      "isMainTask": true,
      "isSubTask": false,
      "isOverdue": false,
      "subTasks": []
    }
  ],
  "version": "1.0.0",
  "lastUpdated": "2024-01-10T10:30:00Z"
}
```

---

## 🚨 Troubleshooting

### Common Issues

**1. MCP Server Won't Start**
```bash
# Check if dependencies are installed
npm install

# Rebuild if needed
npm run build

# Check for port conflicts
lsof -i :3000
```

**2. Claude Desktop Not Connecting**
- Verify the path in `claude_desktop_config.json` is correct
- Restart Claude Desktop completely
- Check Console.app for error messages

**3. Tasks Not Saving**
- Ensure write permissions to the database directory
- Check disk space available
- Verify `AGRASANDHANI_DB_PATH` if using custom location

**4. Import/Export Issues**
```bash
# Backup your tasks
cp ~/.agrasandhani/tasks.json ~/.agrasandhani/tasks_backup.json

# Reset database (careful!)
rm ~/.agrasandhani/tasks.json
```

### Debug Mode
```bash
# Run with detailed logging
DEBUG=1 npm start
```

---

## 🎨 Advanced Usage Patterns

### 1. Batch Task Creation
```
"I'm planning a vacation to Japan. Create tasks for: booking flights, getting visa, learning basic Japanese phrases, researching hotels in Tokyo, and packing checklist."
```

### 2. Project Management
```
"Create a main task called 'Launch personal blog' in Work Projects. Add subtasks for choosing platform, designing layout, writing first 5 posts, and setting up analytics."
```

### 3. Habit Tracking
```
"Create daily spiritual tasks for this week: morning meditation, evening gratitude journal, and reading one spiritual quote."
```

### 4. Goal Decomposition  
```
"I want to learn Spanish fluently. Break this down into actionable subtasks with realistic timelines."
```

### 5. Productivity Analytics
```
"Analyze my task completion patterns. Which categories am I procrastinating on? What priority level gets completed fastest?"
```

---

## 🕉️ Divine Productivity Philosophy

The Agrasandhani MCP Server embodies these sacred principles:

> **कर्मण्येवाधिकारस्ते मा फलेषु कदाचन**  
> *"You have the right to perform your actions, but you are not entitled to the fruits of action"*

### Core Principles:
1. **Dharmic Action** - Focus on the doing, not the outcome
2. **Cosmic Organization** - Every task has its divine place  
3. **Mindful Progress** - Quality over quantity in completion
4. **Sacred Balance** - Honor all 7 categories of life
5. **Divine Timing** - Respect natural rhythms and due dates

---

## 🌟 What Makes This Special

### AI-Powered Insights
Unlike traditional task managers, the MCP server enables:
- **Contextual Understanding** - AI grasps the meaning behind your tasks
- **Smart Suggestions** - Get recommendations for better organization
- **Natural Language** - No need to learn complex interfaces
- **Pattern Recognition** - AI helps identify productivity trends

### Spiritual Integration
- **Divine Theming** - Every interaction feels sacred and intentional  
- **Mindful Language** - Responses encourage contemplation
- **Cosmic Categories** - Tasks aligned with life's sacred aspects
- **Dharmic Reminders** - Focus on action over attachment to results

### Technical Excellence
- **Zero Vendor Lock-in** - Your data stays in portable JSON
- **Cross-Platform** - Works on any system with Node.js
- **Extensible** - Easy to add new tools and capabilities  
- **Reliable** - Robust error handling and data integrity

---

## 🤝 Getting Help

### Documentation
- **This Guide** - Complete usage instructions
- **README.md** - Technical setup and architecture
- **Code Comments** - Inline documentation in TypeScript files

### Support Channels
- **GitHub Issues** - Bug reports and feature requests
- **Code Review** - Examine the TypeScript source code
- **Community** - Share experiences with other Agrasandhani users

### Extending the Server
The MCP server is designed for extensibility:
```typescript
// Add new tools in src/tools.ts
// Implement handlers in src/handlers.ts  
// Extend database in src/database.ts
```

---

## 🎯 Best Practices

### Task Creation
- **Be Specific** - "Write blog post about meditation benefits" vs "Write blog"
- **Set Realistic Due Dates** - Honor your natural rhythms
- **Use Appropriate Categories** - Maintain cosmic balance across life areas
- **Meaningful Notes** - Add context for future reference

### Organization  
- **Main Tasks First** - Create parent tasks before subtasks
- **Logical Hierarchy** - Keep subtasks related and manageable
- **Regular Reviews** - Use stats to understand patterns
- **Sacred Balance** - Don't neglect any category for too long

### AI Interaction
- **Be Conversational** - "Help me organize my week" works better than commands
- **Provide Context** - "For my morning routine..." helps AI understand
- **Ask for Insights** - "What should I focus on today?"
- **Iterate Together** - Refine tasks through conversation

---

**🌟 May your divine productivity flow through cosmic harmony! 🕉️**

*The Agrasandhani MCP Server bridges the earthly realm of task management with the infinite possibilities of AI assistance. Use it mindfully, and let it guide you toward dharmic action and spiritual growth.*