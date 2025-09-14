/**
 * MCP Tool Handlers for Agrasandhani Task Management
 */

import { AgrasandhaniDatabase } from './database.js';
import { TaskCategory, TaskPriority, CreateTaskRequest, UpdateTaskRequest } from './types.js';

export class AgrasandhaniHandlers {
  constructor(private db: AgrasandhaniDatabase) {}

  async createTask(args: any) {
    try {
      const request: CreateTaskRequest = {
        title: args.title,
        notes: args.notes,
        category: this.parseCategory(args.category),
        priority: this.parsePriority(args.priority),
        dueDate: args.dueDate,
        parentTaskID: args.parentTaskId
      };

      const task = this.db.createTask(request);
      
      return {
        content: [
          {
            type: "text",
            text: `✨ Task created successfully in the Divine Ledger!\n\n` +
                  `📋 **${task.title}**\n` +
                  `🏷️ Category: ${task.category}\n` +
                  `⚡ Priority: ${this.formatPriority(task.priority)}\n` +
                  `${task.dueDate ? `📅 Due: ${task.dueDate.toLocaleDateString()}\n` : ''}` +
                  `${task.parentTaskID ? `🔗 Subtask of: ${task.parentTaskID}\n` : ''}` +
                  `🆔 Task ID: ${task.id}\n\n` +
                  `The divine forces are aligned for productivity! 🌟`
          }
        ]
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text", 
            text: `❌ Failed to create task: ${error instanceof Error ? error.message : 'Unknown error'}`
          }
        ],
        isError: true
      };
    }
  }

  async getTasks(args: any) {
    try {
      const filters: any = {};
      
      if (args.category) filters.category = this.parseCategory(args.category);
      if (args.priority) filters.priority = this.parsePriority(args.priority);
      if (args.completed !== undefined) filters.isCompleted = args.completed;
      if (args.overdue) filters.isOverdue = true;
      if (args.search) filters.searchQuery = args.search;
      if (args.parentTaskId === 'main') filters.parentTaskID = null;
      else if (args.parentTaskId) filters.parentTaskID = args.parentTaskId;
      if (args.dateFrom && args.dateTo) {
        filters.dateRange = { from: args.dateFrom, to: args.dateTo };
      }

      const tasks = this.db.getTasks(filters);
      
      if (tasks.length === 0) {
        return {
          content: [
            {
              type: "text",
              text: "🕊️ The Divine Ledger shows no tasks matching your criteria.\n\nPerhaps it's time to create some divine entries! ✨"
            }
          ]
        };
      }

      const taskList = tasks.map(task => {
        const indent = task.isSubTask ? '  └─ ' : '';
        const status = task.isCompleted ? '✅' : '⭕';
        const priority = this.getPriorityEmoji(task.priority);
        const overdue = task.isOverdue ? ' 🔥 OVERDUE' : '';
        const dueInfo = task.dueDate ? ` (Due: ${task.dueDate.toLocaleDateString()})` : '';
        
        return `${indent}${status} ${priority} **${task.title}**${dueInfo}${overdue}\n` +
               `${indent}   🏷️ ${task.category} | 🆔 ${task.id}` +
               (task.notes ? `\n${indent}   📝 ${task.notes}` : '') +
               (task.subTasks && task.subTasks.length > 0 ? `\n${indent}   📁 ${task.subTasks.length} subtask(s)` : '');
      }).join('\n\n');

      return {
        content: [
          {
            type: "text",
            text: `📋 **Divine Ledger Tasks** (${tasks.length} found)\n\n${taskList}\n\n` +
                  `🌟 May divine productivity guide your journey!`
          }
        ]
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `❌ Failed to retrieve tasks: ${error instanceof Error ? error.message : 'Unknown error'}`
          }
        ],
        isError: true
      };
    }
  }

  async updateTask(args: any) {
    try {
      const updates: UpdateTaskRequest = {};
      
      if (args.title !== undefined) updates.title = args.title;
      if (args.notes !== undefined) updates.notes = args.notes === '' ? null : args.notes;
      if (args.category !== undefined) updates.category = this.parseCategory(args.category);
      if (args.priority !== undefined) updates.priority = this.parsePriority(args.priority);
      if (args.completed !== undefined) updates.isCompleted = args.completed;
      if (args.dueDate !== undefined) {
        updates.dueDate = args.dueDate === 'null' ? null : args.dueDate;
      }

      const task = this.db.updateTask(args.taskId, updates);
      
      if (!task) {
        return {
          content: [
            {
              type: "text",
              text: `❌ Task not found: ${args.taskId}\n\nThe divine ledger holds no record of this task.`
            }
          ],
          isError: true
        };
      }

      return {
        content: [
          {
            type: "text",
            text: `✨ Task updated in the Divine Ledger!\n\n` +
                  `📋 **${task.title}**\n` +
                  `🏷️ Category: ${task.category}\n` +
                  `⚡ Priority: ${this.formatPriority(task.priority)}\n` +
                  `${task.isCompleted ? '✅ Status: Completed\n' : '⭕ Status: Active\n'}` +
                  `${task.dueDate ? `📅 Due: ${task.dueDate.toLocaleDateString()}\n` : ''}` +
                  `🆔 Task ID: ${task.id}\n\n` +
                  `The cosmic forces acknowledge your dedication! 🌟`
          }
        ]
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `❌ Failed to update task: ${error instanceof Error ? error.message : 'Unknown error'}`
          }
        ],
        isError: true
      };
    }
  }

  async deleteTask(args: any) {
    try {
      const success = this.db.deleteTask(args.taskId);
      
      if (!success) {
        return {
          content: [
            {
              type: "text",
              text: `❌ Task not found: ${args.taskId}\n\nThe divine ledger holds no record of this task.`
            }
          ],
          isError: true
        };
      }

      return {
        content: [
          {
            type: "text",
            text: `🗑️ **Task deleted from the Divine Ledger**\n\n` +
                  `The task and all its subtasks have been removed from existence.\n` +
                  `May this clearing bring you divine focus! ✨\n\n` +
                  `*Task ID: ${args.taskId}*`
          }
        ]
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `❌ Failed to delete task: ${error instanceof Error ? error.message : 'Unknown error'}`
          }
        ],
        isError: true
      };
    }
  }

  async getTaskStats(args: any) {
    try {
      const stats = this.db.getStats();
      
      const categoryStats = Object.entries(stats.byCategory)
        .map(([cat, count]) => `  ${this.getCategoryEmoji(cat as TaskCategory)} ${cat}: ${count}`)
        .join('\n');

      const priorityStats = Object.entries(stats.byPriority)
        .map(([pri, count]) => `  ${this.getPriorityEmoji(Number(pri) as TaskPriority)} ${this.formatPriority(Number(pri) as TaskPriority)}: ${count}`)
        .join('\n');

      return {
        content: [
          {
            type: "text",
            text: `📊 **Divine Ledger Statistics**\n\n` +
                  `📋 **Overall Status:**\n` +
                  `  📝 Total Tasks: ${stats.total}\n` +
                  `  ⭕ Active: ${stats.active}\n` +
                  `  ✅ Completed: ${stats.completed}\n` +
                  `  🔥 Overdue: ${stats.overdue}\n\n` +
                  `🏷️ **By Category:**\n${categoryStats}\n\n` +
                  `⚡ **By Priority:**\n${priorityStats}\n\n` +
                  `🌟 Divine productivity flows through organized action!`
          }
        ]
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `❌ Failed to get statistics: ${error instanceof Error ? error.message : 'Unknown error'}`
          }
        ],
        isError: true
      };
    }
  }

  async getTaskDetails(args: any) {
    try {
      const task = this.db.getTask(args.taskId);
      
      if (!task) {
        return {
          content: [
            {
              type: "text",
              text: `❌ Task not found: ${args.taskId}\n\nThe divine ledger holds no record of this task.`
            }
          ],
          isError: true
        };
      }

      let details = `📋 **${task.title}**\n\n` +
                   `🆔 **ID:** ${task.id}\n` +
                   `🏷️ **Category:** ${this.getCategoryEmoji(task.category)} ${task.category}\n` +
                   `⚡ **Priority:** ${this.getPriorityEmoji(task.priority)} ${this.formatPriority(task.priority)}\n` +
                   `${task.isCompleted ? '✅ **Status:** Completed' : '⭕ **Status:** Active'}\n` +
                   `📅 **Created:** ${task.createdAt.toLocaleDateString()}\n`;

      if (task.dueDate) {
        details += `⏰ **Due Date:** ${task.dueDate.toLocaleDateString()}${task.isOverdue ? ' 🔥 OVERDUE' : ''}\n`;
      }

      if (task.completedAt) {
        details += `✅ **Completed:** ${task.completedAt.toLocaleDateString()}\n`;
      }

      if (task.notes) {
        details += `\n📝 **Notes:**\n${task.notes}\n`;
      }

      if (task.parentTaskID) {
        details += `\n🔗 **Parent Task:** ${task.parentTaskID}\n`;
      }

      if (task.subTasks && task.subTasks.length > 0) {
        details += `\n📁 **Subtasks (${task.subTasks.length}):**\n`;
        task.subTasks.forEach(subtask => {
          const status = subtask.isCompleted ? '✅' : '⭕';
          details += `  ${status} ${subtask.title} (${subtask.id})\n`;
        });
      }

      details += `\n🌟 May divine focus guide your journey!`;

      return {
        content: [
          {
            type: "text",
            text: details
          }
        ]
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `❌ Failed to get task details: ${error instanceof Error ? error.message : 'Unknown error'}`
          }
        ],
        isError: true
      };
    }
  }

  async completeTask(args: any) {
    return this.updateTask({ taskId: args.taskId, completed: true });
  }

  async createSubtask(args: any) {
    try {
      // Get parent task to inherit category and priority if not specified
      const parentTask = this.db.getTask(args.parentTaskId);
      if (!parentTask) {
        return {
          content: [
            {
              type: "text",
              text: `❌ Parent task not found: ${args.parentTaskId}\n\nThe divine ledger holds no record of this task.`
            }
          ],
          isError: true
        };
      }

      const request: CreateTaskRequest = {
        title: args.title,
        notes: args.notes,
        category: parentTask.category, // Inherit parent's category
        priority: args.priority ? this.parsePriority(args.priority) : parentTask.priority,
        dueDate: args.dueDate,
        parentTaskID: args.parentTaskId
      };

      const subtask = this.db.createTask(request);
      
      return {
        content: [
          {
            type: "text",
            text: `✨ Subtask created in the Divine Ledger!\n\n` +
                  `📋 **${subtask.title}**\n` +
                  `🔗 Under: **${parentTask.title}**\n` +
                  `🏷️ Category: ${subtask.category}\n` +
                  `⚡ Priority: ${this.formatPriority(subtask.priority)}\n` +
                  `${subtask.dueDate ? `📅 Due: ${subtask.dueDate.toLocaleDateString()}\n` : ''}` +
                  `🆔 Subtask ID: ${subtask.id}\n\n` +
                  `Divine hierarchy strengthens your organization! 🌟`
          }
        ]
      };
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `❌ Failed to create subtask: ${error instanceof Error ? error.message : 'Unknown error'}`
          }
        ],
        isError: true
      };
    }
  }

  // Helper methods
  private parseCategory(category?: string): TaskCategory {
    if (!category) return TaskCategory.PERSONAL_GOALS;
    
    const categoryMap: Record<string, TaskCategory> = {
      'personal goals': TaskCategory.PERSONAL_GOALS,
      'work projects': TaskCategory.WORK_PROJECTS,
      'health & fitness': TaskCategory.HEALTH_FITNESS,
      'meetings': TaskCategory.MEETINGS,
      'learning': TaskCategory.LEARNING,
      'home & family': TaskCategory.HOME_FAMILY,
      'spiritual': TaskCategory.SPIRITUAL
    };
    
    return categoryMap[category.toLowerCase()] || TaskCategory.PERSONAL_GOALS;
  }

  private parsePriority(priority?: string): TaskPriority {
    if (!priority) return TaskPriority.MEDIUM;
    
    const priorityMap: Record<string, TaskPriority> = {
      'low': TaskPriority.LOW,
      'medium': TaskPriority.MEDIUM,
      'high': TaskPriority.HIGH,
      'critical': TaskPriority.CRITICAL
    };
    
    return priorityMap[priority.toLowerCase()] || TaskPriority.MEDIUM;
  }

  private formatPriority(priority: TaskPriority): string {
    const map = {
      [TaskPriority.LOW]: 'Low',
      [TaskPriority.MEDIUM]: 'Medium', 
      [TaskPriority.HIGH]: 'High',
      [TaskPriority.CRITICAL]: 'Critical'
    };
    return map[priority];
  }

  private getPriorityEmoji(priority: TaskPriority): string {
    const map = {
      [TaskPriority.LOW]: '🟢',
      [TaskPriority.MEDIUM]: '🟡',
      [TaskPriority.HIGH]: '🟠',
      [TaskPriority.CRITICAL]: '🔴'
    };
    return map[priority];
  }

  private getCategoryEmoji(category: TaskCategory): string {
    const map = {
      [TaskCategory.PERSONAL_GOALS]: '🎯',
      [TaskCategory.WORK_PROJECTS]: '💼',
      [TaskCategory.HEALTH_FITNESS]: '💪',
      [TaskCategory.MEETINGS]: '🤝',
      [TaskCategory.LEARNING]: '📚',
      [TaskCategory.HOME_FAMILY]: '🏠',
      [TaskCategory.SPIRITUAL]: '🕉️'
    };
    return map[category];
  }
}