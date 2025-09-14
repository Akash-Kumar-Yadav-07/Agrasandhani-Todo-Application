/**
 * Database interface for Agrasandhani tasks
 * Uses JSON file storage for simplicity and cross-platform compatibility
 * In production, this could be replaced with SQLite or Core Data bridge
 */

import { Task, TaskCategory, TaskPriority, CreateTaskRequest, UpdateTaskRequest, TaskFilters, TaskStats } from './types.js';
import { randomUUID } from 'crypto';
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import path from 'path';
import os from 'os';

interface DatabaseSchema {
  tasks: Task[];
  version: string;
  lastUpdated: string;
}

export class AgrasandhaniDatabase {
  private dbPath: string;
  private data!: DatabaseSchema;

  constructor(dbPath?: string) {
    // Use a default path in user's home directory if not specified
    const defaultDir = path.join(os.homedir(), '.agrasandhani');
    const defaultPath = path.join(defaultDir, 'tasks.json');
    this.dbPath = dbPath || defaultPath;
    
    this.ensureDirectoryExists();
    this.loadData();
  }

  private ensureDirectoryExists() {
    const dir = path.dirname(this.dbPath);
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
    }
  }

  private loadData() {
    if (!existsSync(this.dbPath)) {
      this.data = {
        tasks: [],
        version: '1.0.0',
        lastUpdated: new Date().toISOString()
      };
      this.saveData();
    } else {
      try {
        const fileContent = readFileSync(this.dbPath, 'utf-8');
        this.data = JSON.parse(fileContent, (key, value) => {
          // Parse date strings back to Date objects
          if (key === 'createdAt' || key === 'updatedAt' || key === 'completedAt' || key === 'dueDate') {
            return value ? new Date(value) : undefined;
          }
          return value;
        });
      } catch (error) {
        console.error('Failed to load database, creating new one:', error);
        this.data = {
          tasks: [],
          version: '1.0.0',
          lastUpdated: new Date().toISOString()
        };
      }
    }
  }

  private saveData() {
    this.data.lastUpdated = new Date().toISOString();
    const jsonData = JSON.stringify(this.data, null, 2);
    writeFileSync(this.dbPath, jsonData, 'utf-8');
  }

  // Create a new task
  createTask(request: CreateTaskRequest): Task {
    const id = randomUUID();
    const now = new Date();
    
    const task: Task = {
      id,
      title: request.title,
      notes: request.notes,
      category: request.category || TaskCategory.PERSONAL_GOALS,
      priority: request.priority || TaskPriority.MEDIUM,
      isCompleted: false,
      dueDate: request.dueDate ? new Date(request.dueDate) : undefined,
      createdAt: now,
      updatedAt: now,
      parentTaskID: request.parentTaskID,
      isMainTask: !request.parentTaskID,
      isSubTask: Boolean(request.parentTaskID),
      isOverdue: false
    };

    // Calculate if overdue
    if (task.dueDate) {
      task.isOverdue = task.dueDate < now && !task.isCompleted;
    }

    this.data.tasks.push(task);
    this.saveData();

    return this.enrichTask(task);
  }

  // Get a single task by ID
  getTask(id: string): Task | null {
    const task = this.data.tasks.find(t => t.id === id);
    return task ? this.enrichTask({ ...task }) : null;
  }

  // Get all tasks with optional filtering
  getTasks(filters?: TaskFilters): Task[] {
    let tasks = [...this.data.tasks];

    if (filters) {
      if (filters.category !== undefined) {
        tasks = tasks.filter(t => t.category === filters.category);
      }

      if (filters.priority !== undefined) {
        tasks = tasks.filter(t => t.priority === filters.priority);
      }

      if (filters.isCompleted !== undefined) {
        tasks = tasks.filter(t => t.isCompleted === filters.isCompleted);
      }

      if (filters.parentTaskID !== undefined) {
        if (filters.parentTaskID === null) {
          tasks = tasks.filter(t => !t.parentTaskID);
        } else {
          tasks = tasks.filter(t => t.parentTaskID === filters.parentTaskID);
        }
      }

      if (filters.searchQuery) {
        const query = filters.searchQuery.toLowerCase();
        tasks = tasks.filter(t => 
          t.title.toLowerCase().includes(query) ||
          (t.notes && t.notes.toLowerCase().includes(query))
        );
      }

      if (filters.isOverdue) {
        const now = new Date();
        tasks = tasks.filter(t => 
          t.dueDate && t.dueDate < now && !t.isCompleted
        );
      }

      if (filters.dateRange) {
        const from = new Date(filters.dateRange.from);
        const to = new Date(filters.dateRange.to);
        tasks = tasks.filter(t => 
          t.dueDate && t.dueDate >= from && t.dueDate <= to
        );
      }
    }

    // Sort by creation date (newest first)
    tasks.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

    return tasks.map(t => this.enrichTask(t));
  }

  // Update a task
  updateTask(id: string, updates: UpdateTaskRequest): Task | null {
    const taskIndex = this.data.tasks.findIndex(t => t.id === id);
    if (taskIndex === -1) return null;

    const task = this.data.tasks[taskIndex];
    const now = new Date();

    if (updates.title !== undefined) task.title = updates.title;
    if (updates.notes !== undefined) task.notes = updates.notes;
    if (updates.category !== undefined) task.category = updates.category;
    if (updates.priority !== undefined) task.priority = updates.priority;
    if (updates.dueDate !== undefined) {
      task.dueDate = updates.dueDate ? new Date(updates.dueDate) : undefined;
    }

    if (updates.isCompleted !== undefined) {
      task.isCompleted = updates.isCompleted;
      if (updates.isCompleted) {
        task.completedAt = now;
      } else {
        task.completedAt = undefined;
      }
    }

    task.updatedAt = now;

    // Recalculate derived properties
    if (task.dueDate) {
      task.isOverdue = task.dueDate < now && !task.isCompleted;
    } else {
      task.isOverdue = false;
    }

    this.data.tasks[taskIndex] = task;
    this.saveData();

    return this.enrichTask({ ...task });
  }

  // Delete a task (and all its subtasks)
  deleteTask(id: string): boolean {
    const initialLength = this.data.tasks.length;
    
    // Remove the task and all its subtasks recursively
    this.data.tasks = this.data.tasks.filter(t => 
      t.id !== id && t.parentTaskID !== id
    );

    // Handle nested subtasks (subtasks of subtasks)
    let changed = true;
    while (changed) {
      const beforeLength = this.data.tasks.length;
      const taskIds = new Set(this.data.tasks.map(t => t.id));
      
      this.data.tasks = this.data.tasks.filter(t => 
        !t.parentTaskID || taskIds.has(t.parentTaskID)
      );
      
      changed = this.data.tasks.length < beforeLength;
    }

    if (this.data.tasks.length < initialLength) {
      this.saveData();
      return true;
    }

    return false;
  }

  // Get task statistics
  getStats(): TaskStats {
    const tasks = this.data.tasks;
    const now = new Date();

    const total = tasks.length;
    const active = tasks.filter(t => !t.isCompleted).length;
    const completed = tasks.filter(t => t.isCompleted).length;
    const overdue = tasks.filter(t => 
      t.dueDate && t.dueDate < now && !t.isCompleted
    ).length;

    const byCategory: Record<TaskCategory, number> = {
      [TaskCategory.PERSONAL_GOALS]: 0,
      [TaskCategory.WORK_PROJECTS]: 0,
      [TaskCategory.HEALTH_FITNESS]: 0,
      [TaskCategory.MEETINGS]: 0,
      [TaskCategory.LEARNING]: 0,
      [TaskCategory.HOME_FAMILY]: 0,
      [TaskCategory.SPIRITUAL]: 0,
    };

    const byPriority: Record<TaskPriority, number> = {
      [TaskPriority.LOW]: 0,
      [TaskPriority.MEDIUM]: 0,
      [TaskPriority.HIGH]: 0,
      [TaskPriority.CRITICAL]: 0,
    };

    tasks.forEach(task => {
      byCategory[task.category] = (byCategory[task.category] || 0) + 1;
      byPriority[task.priority] = (byPriority[task.priority] || 0) + 1;
    });

    return {
      total,
      active,
      completed,
      overdue,
      byCategory,
      byPriority
    };
  }

  // Get subtasks for a task
  getSubTasks(parentId: string): Task[] {
    return this.getTasks({ parentTaskID: parentId });
  }

  // Get main tasks (no parent)
  getMainTasks(filters?: Omit<TaskFilters, 'parentTaskID'>): Task[] {
    return this.getTasks({ ...filters, parentTaskID: null as any });
  }

  private enrichTask(task: Task): Task {
    // Add subtasks if this is a main task
    if (!task.parentTaskID) {
      task.subTasks = this.getSubTasks(task.id);
    }

    return task;
  }

  close() {
    // Save final state before closing
    this.saveData();
  }
}