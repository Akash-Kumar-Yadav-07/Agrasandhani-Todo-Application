/**
 * MCP Tools for Agrasandhani Task Management
 */

import { Tool } from '@modelcontextprotocol/sdk/types.js';

export const AGRASANDHANI_TOOLS: Tool[] = [
  {
    name: "create_task",
    description: "Create a new task in Agrasandhani. Supports both main tasks and subtasks with divine categorization.",
    inputSchema: {
      type: "object",
      properties: {
        title: {
          type: "string",
          description: "The task title (required)"
        },
        notes: {
          type: "string",
          description: "Optional detailed notes or description for the task"
        },
        category: {
          type: "string",
          enum: ["Personal Goals", "Work Projects", "Health & Fitness", "Meetings", "Learning", "Home & Family", "Spiritual"],
          description: "Task category following divine organization principles"
        },
        priority: {
          type: "string", 
          enum: ["low", "medium", "high", "critical"],
          description: "Task priority level"
        },
        dueDate: {
          type: "string",
          description: "Due date in ISO format (YYYY-MM-DDTHH:mm:ss.sssZ)"
        },
        parentTaskId: {
          type: "string",
          description: "ID of parent task to create this as a subtask"
        }
      },
      required: ["title"]
    }
  },

  {
    name: "get_tasks",
    description: "Retrieve tasks with optional filtering. Perfect for divine task organization and management.",
    inputSchema: {
      type: "object",
      properties: {
        category: {
          type: "string",
          enum: ["Personal Goals", "Work Projects", "Health & Fitness", "Meetings", "Learning", "Home & Family", "Spiritual"],
          description: "Filter by specific category"
        },
        priority: {
          type: "string",
          enum: ["low", "medium", "high", "critical"],
          description: "Filter by priority level"
        },
        completed: {
          type: "boolean",
          description: "Filter by completion status (true for completed, false for active)"
        },
        overdue: {
          type: "boolean",
          description: "Show only overdue tasks"
        },
        search: {
          type: "string",
          description: "Search in task titles and notes"
        },
        parentTaskId: {
          type: "string",
          description: "Get subtasks of a specific parent task (use 'main' for main tasks only)"
        },
        dateFrom: {
          type: "string",
          description: "Filter tasks due from this date (ISO format)"
        },
        dateTo: {
          type: "string", 
          description: "Filter tasks due until this date (ISO format)"
        }
      }
    }
  },

  {
    name: "update_task",
    description: "Update an existing task. Supports all task properties following divine principles.",
    inputSchema: {
      type: "object",
      properties: {
        taskId: {
          type: "string",
          description: "ID of the task to update (required)"
        },
        title: {
          type: "string",
          description: "New task title"
        },
        notes: {
          type: "string",
          description: "New task notes (use empty string to clear)"
        },
        category: {
          type: "string",
          enum: ["Personal Goals", "Work Projects", "Health & Fitness", "Meetings", "Learning", "Home & Family", "Spiritual"],
          description: "New task category"
        },
        priority: {
          type: "string",
          enum: ["low", "medium", "high", "critical"],
          description: "New priority level"
        },
        completed: {
          type: "boolean",
          description: "Mark task as completed or active"
        },
        dueDate: {
          type: "string",
          description: "New due date in ISO format (use 'null' to remove due date)"
        }
      },
      required: ["taskId"]
    }
  },

  {
    name: "delete_task",
    description: "Delete a task and all its subtasks. Use with caution - this action cannot be undone.",
    inputSchema: {
      type: "object",
      properties: {
        taskId: {
          type: "string",
          description: "ID of the task to delete (required)"
        }
      },
      required: ["taskId"]
    }
  },

  {
    name: "get_task_stats",
    description: "Get comprehensive statistics about all tasks including divine categorization insights.",
    inputSchema: {
      type: "object",
      properties: {}
    }
  },

  {
    name: "get_task_details",
    description: "Get detailed information about a specific task including its subtasks and hierarchy.",
    inputSchema: {
      type: "object",
      properties: {
        taskId: {
          type: "string",
          description: "ID of the task to retrieve (required)"
        }
      },
      required: ["taskId"]
    }
  },

  {
    name: "complete_task",
    description: "Mark a task as completed. For hierarchical tasks, this intelligently handles parent-child relationships.",
    inputSchema: {
      type: "object",
      properties: {
        taskId: {
          type: "string",
          description: "ID of the task to complete (required)"
        }
      },
      required: ["taskId"]
    }
  },

  {
    name: "create_subtask",
    description: "Create a subtask under an existing parent task. Follows divine hierarchical organization.",
    inputSchema: {
      type: "object",
      properties: {
        parentTaskId: {
          type: "string",
          description: "ID of the parent task (required)"
        },
        title: {
          type: "string",
          description: "Subtask title (required)"
        },
        notes: {
          type: "string",
          description: "Optional subtask notes"
        },
        priority: {
          type: "string",
          enum: ["low", "medium", "high", "critical"],
          description: "Subtask priority (defaults to parent's priority if not specified)"
        },
        dueDate: {
          type: "string",
          description: "Due date in ISO format"
        }
      },
      required: ["parentTaskId", "title"]
    }
  }
];