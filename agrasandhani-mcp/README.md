# 🌟 Agrasandhani MCP Server

A **Model Context Protocol (MCP)** server for the divine Agrasandhani Task Management application. This server enables AI assistants like Claude to interact seamlessly with your tasks, following the sacred principles of cosmic organization.

## ✨ Features

- **🎯 Divine Task Management**: Create, read, update, and delete tasks with cosmic categories
- **📋 Hierarchical Organization**: Support for main tasks and subtasks with proper indentation
- **🏷️ Sacred Categories**: Personal Goals, Work Projects, Health & Fitness, Meetings, Learning, Home & Family, Spiritual
- **⚡ Priority Levels**: Low, Medium, High, Critical with visual indicators
- **📊 Cosmic Statistics**: Comprehensive task analytics and insights
- **🔍 Advanced Filtering**: Search by category, priority, status, dates, and more
- **🕉️ Divine Theming**: Maintains the spiritual essence of Agrasandhani

## 🚀 Installation

```bash
cd agrasandhani-mcp
npm install
npm run build
```

## 🌟 Usage

### As a Standalone Server
```bash
npm start
```

### With Claude Desktop (Recommended)

Add to your Claude Desktop configuration (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "agrasandhani": {
      "command": "node",
      "args": ["/path/to/agrasandhani-mcp/dist/index.js"],
      "env": {
        "AGRASANDHANI_DB_PATH": "/path/to/your/tasks.db"
      }
    }
  }
}
```

### Development Mode
```bash
npm run dev
```

## 🛠️ Available Tools

### Core Task Management
- **`create_task`** - Create new tasks with divine categorization
- **`get_tasks`** - Retrieve tasks with powerful filtering options
- **`update_task`** - Modify existing tasks following cosmic principles
- **`delete_task`** - Remove tasks from the divine ledger
- **`get_task_details`** - Get comprehensive task information

### Advanced Operations
- **`complete_task`** - Mark tasks as completed with cosmic acknowledgment
- **`create_subtask`** - Add subtasks under existing parent tasks
- **`get_task_stats`** - Retrieve divine productivity statistics

## 📋 Task Categories

The divine categorization system includes:

- 🎯 **Personal Goals** - Self-improvement and personal aspirations
- 💼 **Work Projects** - Professional tasks and career development
- 💪 **Health & Fitness** - Physical and mental wellness activities
- 🤝 **Meetings** - Scheduled appointments and gatherings
- 📚 **Learning** - Educational pursuits and skill development
- 🏠 **Home & Family** - Household and family-related tasks
- 🕉️ **Spiritual** - Meditation, prayer, and spiritual practices

## ⚡ Priority Levels

- 🟢 **Low** - Tasks that can be done when time permits
- 🟡 **Medium** - Standard priority tasks (default)
- 🟠 **High** - Important tasks requiring attention
- 🔴 **Critical** - Urgent tasks requiring immediate action

## 🗄️ Database

The MCP server uses SQLite for task storage, maintaining compatibility with the SwiftUI app's Core Data structure. The database includes:

- **Hierarchical task relationships** using parent-child IDs
- **Full-text search** capabilities across titles and notes
- **Optimized indexing** for fast filtering and retrieval
- **Data integrity** with foreign key constraints

## 📖 Example Usage

### Creating a Task
```
Create a new task: "Meditate for 20 minutes" in the Spiritual category with high priority, due tomorrow at 6 AM.
```

### Getting Tasks
```
Show me all high priority tasks in the Work Projects category that are not completed.
```

### Task Statistics
```
Give me a comprehensive overview of all my tasks with statistics by category and priority.
```

### Creating Subtasks
```
Under the task "Launch new product", create a subtask "Design user interface mockups" with medium priority.
```

## 🔧 Configuration

### Environment Variables

- **`AGRASANDHANI_DB_PATH`** - Custom database file path (defaults to `~/.agrasandhani/tasks.db`)

### Database Location

By default, the database is stored at:
- **macOS**: `~/Library/Application Support/Agrasandhani/tasks.db`  
- **Custom**: Set via `AGRASANDHANI_DB_PATH` environment variable

## 🌟 Integration with Agrasandhani App

This MCP server is designed to work alongside your SwiftUI Agrasandhani app:

1. **Shared Data Model** - Uses the same Core Data structure and relationships
2. **Consistent Categories** - Maintains the divine categorization system
3. **Hierarchical Tasks** - Full support for parent-child task relationships
4. **Priority System** - Compatible with the app's priority levels
5. **Real-time Sync** - Changes made through MCP are reflected in the app

## 🚨 Important Notes

- **Database Compatibility** - Ensure both the MCP server and SwiftUI app use the same database file
- **Concurrent Access** - SQLite handles concurrent reads, but be cautious with simultaneous writes
- **Backup Strategy** - Regular backups of your task database are recommended
- **Data Format** - All dates are stored in ISO format for consistency

## 🕉️ Divine Philosophy

This MCP server embodies the spiritual essence of Agrasandhani:

> *"कर्मण्येवाधिकारस्ते मा फलेषु कदाचन"*  
> *"You have the right to perform your actions, but you are not entitled to the fruits of action"*

The server facilitates divine productivity through organized action, cosmic categorization, and spiritual awareness in task management.

## 📄 License

MIT - May divine forces guide your productivity journey! ✨

---

🌟 **Agrasandhani MCP Server** - Where AI meets Divine Task Management 🕉️