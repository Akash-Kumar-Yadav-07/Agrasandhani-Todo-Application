# 🛠️ Agrasandhani MCP Server - API Reference

Technical documentation for developers working with the Agrasandhani MCP Server.

## 📋 MCP Tools Reference

### 1. `create_task`

**Description**: Create a new task in the Agrasandhani system with divine categorization and priority settings.

**Parameters**:
```typescript
interface CreateTaskParams {
  title: string;                    // Required - Task title
  notes?: string;                   // Optional - Task description/notes
  category?: TaskCategory;          // Optional - Task category (defaults to PERSONAL_GOALS)
  priority?: TaskPriority;          // Optional - Task priority (defaults to MEDIUM)
  dueDate?: string;                // Optional - ISO date string or natural language
  parentTaskID?: string;           // Optional - Parent task ID for subtasks
}
```

**Response Format**:
```typescript
{
  content: [{
    type: "text",
    text: string; // Formatted success message with task details
  }];
  isError?: false;
}
```

**Example**:
```json
{
  "name": "create_task",
  "arguments": {
    "title": "Complete morning meditation",
    "notes": "20 minutes of focused breathing",
    "category": "Spiritual",
    "priority": "High",
    "dueDate": "2024-01-15T06:00:00Z"
  }
}
```

---

### 2. `get_tasks`

**Description**: Retrieve tasks with advanced filtering and search capabilities.

**Parameters**:
```typescript
interface GetTasksParams {
  category?: TaskCategory;          // Filter by specific category
  priority?: TaskPriority;          // Filter by priority level
  isCompleted?: boolean;            // Filter by completion status
  parentTaskID?: string | null;     // Filter by parent relationship
  searchQuery?: string;             // Text search across title and notes
  isOverdue?: boolean;              // Show only overdue tasks
  dateRange?: {                     // Filter by due date range
    from: string;
    to: string;
  };
}
```

**Response Format**:
```typescript
{
  content: [{
    type: "text", 
    text: string; // Formatted task list with divine styling
  }];
  isError?: false;
}
```

**Example**:
```json
{
  "name": "get_tasks",
  "arguments": {
    "category": "Work Projects",
    "priority": "High",
    "isCompleted": false
  }
}
```

---

### 3. `update_task`

**Description**: Update any aspect of an existing task with cosmic validation.

**Parameters**:
```typescript
interface UpdateTaskParams {
  id: string;                       // Required - Task UUID
  title?: string;                   // Optional - New task title
  notes?: string;                   // Optional - New task notes
  category?: TaskCategory;          // Optional - New category
  priority?: TaskPriority;          // Optional - New priority
  isCompleted?: boolean;            // Optional - Completion status
  dueDate?: string | null;         // Optional - New due date (null to remove)
}
```

**Response Format**:
```typescript
{
  content: [{
    type: "text",
    text: string; // Success message with updated task details
  }];
  isError?: false;
}
```

**Example**:
```json
{
  "name": "update_task",
  "arguments": {
    "id": "uuid-here",
    "priority": "Critical",
    "notes": "Updated with new requirements"
  }
}
```

---

### 4. `delete_task`

**Description**: Remove a task and all associated subtasks from the divine ledger.

**Parameters**:
```typescript
interface DeleteTaskParams {
  id: string;                       // Required - Task UUID to delete
}
```

**Response Format**:
```typescript
{
  content: [{
    type: "text",
    text: string; // Confirmation message with deletion details
  }];
  isError?: false;
}
```

**Example**:
```json
{
  "name": "delete_task",
  "arguments": {
    "id": "uuid-here"
  }
}
```

---

### 5. `get_task_stats`

**Description**: Generate comprehensive productivity statistics and cosmic insights.

**Parameters**:
```typescript
interface GetTaskStatsParams {
  // No parameters required - returns all statistics
}
```

**Response Format**:
```typescript
{
  content: [{
    type: "text",
    text: string; // Detailed statistics with divine formatting
  }];
  isError?: false;
}
```

**Statistics Included**:
- Total tasks count
- Active vs completed breakdown
- Overdue tasks analysis
- Category distribution
- Priority level analysis
- Divine productivity insights

---

### 6. `get_task_details`

**Description**: Retrieve comprehensive details about a specific task including subtasks.

**Parameters**:
```typescript
interface GetTaskDetailsParams {
  id: string;                       // Required - Task UUID
}
```

**Response Format**:
```typescript
{
  content: [{
    type: "text",
    text: string; // Complete task details with hierarchical subtasks
  }];
  isError?: false;
}
```

**Example**:
```json
{
  "name": "get_task_details",
  "arguments": {
    "id": "uuid-here"
  }
}
```

---

### 7. `complete_task`

**Description**: Mark a task as completed with cosmic acknowledgment and timestamp.

**Parameters**:
```typescript
interface CompleteTaskParams {
  id: string;                       // Required - Task UUID to complete
}
```

**Response Format**:
```typescript
{
  content: [{
    type: "text",
    text: string; // Divine completion message with task details
  }];
  isError?: false;
}
```

**Example**:
```json
{
  "name": "complete_task", 
  "arguments": {
    "id": "uuid-here"
  }
}
```

---

### 8. `create_subtask`

**Description**: Create a hierarchical subtask under an existing parent task.

**Parameters**:
```typescript
interface CreateSubtaskParams {
  parentTaskID: string;             // Required - Parent task UUID
  title: string;                    // Required - Subtask title
  notes?: string;                   // Optional - Subtask description
  priority?: TaskPriority;          // Optional - Subtask priority
  dueDate?: string;                // Optional - Subtask due date
}
```

**Response Format**:
```typescript
{
  content: [{
    type: "text",
    text: string; // Success message showing parent-child relationship
  }];
  isError?: false;
}
```

**Example**:
```json
{
  "name": "create_subtask",
  "arguments": {
    "parentTaskID": "parent-uuid-here",
    "title": "Research meditation techniques",
    "priority": "Medium"
  }
}
```

---

## 🏷️ Data Types Reference

### TaskCategory Enum
```typescript
enum TaskCategory {
  PERSONAL_GOALS = 'Personal Goals',
  WORK_PROJECTS = 'Work Projects', 
  HEALTH_FITNESS = 'Health & Fitness',
  MEETINGS = 'Meetings',
  LEARNING = 'Learning',
  HOME_FAMILY = 'Home & Family',
  SPIRITUAL = 'Spiritual'
}
```

### TaskPriority Enum
```typescript
enum TaskPriority {
  LOW = 'Low',
  MEDIUM = 'Medium',
  HIGH = 'High', 
  CRITICAL = 'Critical'
}
```

### Task Interface
```typescript
interface Task {
  id: string;                       // UUID v4
  title: string;                    // Task title
  notes?: string;                   // Optional description
  category: TaskCategory;           // Divine category
  priority: TaskPriority;           // Priority level
  isCompleted: boolean;             // Completion status
  dueDate?: Date;                  // Optional due date
  createdAt: Date;                 // Creation timestamp
  updatedAt: Date;                 // Last update timestamp
  completedAt?: Date;              // Completion timestamp
  parentTaskID?: string;           // Parent task UUID
  isMainTask: boolean;             // True if no parent
  isSubTask: boolean;              // True if has parent
  isOverdue: boolean;              // Calculated overdue status
  subTasks?: Task[];               // Child tasks (populated in responses)
}
```

---

## 🚨 Error Handling

All tools can return error responses in this format:

```typescript
{
  content: [{
    type: "text",
    text: string; // Error message with divine guidance
  }];
  isError: true;
}
```

### Common Error Types

**1. Validation Errors**
```json
{
  "content": [{"type": "text", "text": "🚨 Divine validation failed: Task title is required for cosmic registration"}],
  "isError": true
}
```

**2. Not Found Errors**
```json
{
  "content": [{"type": "text", "text": "🔍 Task not found in the Divine Ledger. The cosmic ID may be incorrect."}],
  "isError": true
}
```

**3. Database Errors**
```json
{
  "content": [{"type": "text", "text": "💫 Database error: Unable to save task to the Divine Ledger. Please try again."}],
  "isError": true
}
```

---

## 🗄️ Database Schema

### JSON Structure
```json
{
  "tasks": Task[],
  "version": "1.0.0",
  "lastUpdated": "ISO-8601-datetime"
}
```

### Storage Location
- **Default**: `~/.agrasandhani/tasks.json`
- **Environment Variable**: `AGRASANDHANI_DB_PATH`
- **Format**: UTF-8 JSON with 2-space indentation

### Data Integrity
- **Atomic Operations** - All changes saved immediately
- **Backup on Error** - Failed operations don't corrupt data
- **Schema Validation** - Input validation before storage
- **Referential Integrity** - Parent-child relationships maintained

---

## 🔌 MCP Protocol Details

### Server Capabilities
```typescript
{
  capabilities: {
    tools: {}
  }
}
```

### Tool Registration
All 8 tools are automatically registered on server startup with:
- Name and description
- Input parameter schema  
- Usage examples
- Divine categorization

### Transport Layer
- **Protocol**: Model Context Protocol (MCP)
- **Transport**: StdioServerTransport
- **Format**: JSON-RPC over stdin/stdout
- **Error Handling**: Standard MCP error codes

---

## 🛠️ Development Setup

### Project Structure
```
agrasandhani-mcp/
├── src/
│   ├── index.ts          # Main server entry point
│   ├── database.ts       # JSON database implementation
│   ├── handlers.ts       # MCP tool handlers
│   ├── tools.ts          # Tool definitions
│   └── types.ts          # TypeScript interfaces
├── dist/                 # Built JavaScript output
├── package.json          # Node.js dependencies
├── tsconfig.json         # TypeScript configuration
└── README.md            # Project overview
```

### Build Process
```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Start server
npm start

# Development mode with auto-reload
npm run dev
```

### Environment Variables
- `AGRASANDHANI_DB_PATH` - Custom database file path
- `DEBUG` - Enable debug logging (1 or true)
- `NODE_ENV` - Environment (development/production)

---

## 🌟 Integration Examples

### Claude Desktop Configuration
```json
{
  "mcpServers": {
    "agrasandhani": {
      "command": "node",
      "args": ["/path/to/agrasandhani-mcp/dist/index.js"],
      "env": {
        "AGRASANDHANI_DB_PATH": "/custom/path/tasks.json",
        "DEBUG": "1"
      }
    }
  }
}
```

### Programmatic Usage
```typescript
import { AgrasandhaniDatabase } from './database.js';

const db = new AgrasandhaniDatabase();

// Create task
const task = db.createTask({
  title: 'API Documentation',
  category: TaskCategory.WORK_PROJECTS,
  priority: TaskPriority.HIGH
});

// Get tasks
const tasks = db.getTasks({ 
  category: TaskCategory.SPIRITUAL,
  isCompleted: false 
});

// Update task
const updated = db.updateTask(task.id, {
  isCompleted: true
});
```

### Custom MCP Client
```typescript
// Example MCP client request
const request = {
  method: 'tools/call',
  params: {
    name: 'create_task',
    arguments: {
      title: 'Learn TypeScript',
      category: 'Learning',
      priority: 'High'
    }
  }
};
```

---

## 🔒 Security Considerations

### Data Protection
- **Local Storage** - No cloud dependencies
- **File Permissions** - Database files created with restricted access  
- **Input Validation** - All parameters validated before processing
- **No External Networks** - Server operates entirely offline

### Safe Defaults
- **Non-destructive Operations** - Accidental deletion protection
- **Backup Strategy** - Automatic backup before major operations
- **Error Recovery** - Graceful handling of corrupted data
- **Rate Limiting** - Built-in protection against rapid operations

---

## 📊 Performance Notes

### Optimization Features
- **In-Memory Caching** - Database loaded once on startup
- **Efficient Filtering** - JavaScript array methods for fast searches
- **Lazy Loading** - Subtasks loaded only when needed
- **Minimal Dependencies** - Small footprint with essential packages

### Scale Limitations
- **Task Count** - Optimal performance up to ~10,000 tasks
- **Memory Usage** - Entire database loaded in memory
- **File I/O** - Synchronous writes may block on large datasets
- **Concurrency** - Single process, no concurrent write protection

---

**🌟 This API reference serves as your technical guide to the divine realm of Agrasandhani MCP Server development. May your code flow with cosmic harmony! 🕉️**