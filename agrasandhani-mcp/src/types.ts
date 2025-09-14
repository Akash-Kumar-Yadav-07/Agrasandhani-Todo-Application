/**
 * Agrasandhani Task Management Types
 * Matching the Swift Core Data model
 */

export enum TaskCategory {
  PERSONAL_GOALS = 'Personal Goals',
  WORK_PROJECTS = 'Work Projects', 
  HEALTH_FITNESS = 'Health & Fitness',
  MEETINGS = 'Meetings',
  LEARNING = 'Learning',
  HOME_FAMILY = 'Home & Family',
  SPIRITUAL = 'Spiritual'
}

export enum TaskPriority {
  LOW = 0,
  MEDIUM = 1,
  HIGH = 2,
  CRITICAL = 3
}

export interface Task {
  id: string;
  title: string;
  notes?: string;
  category: TaskCategory;
  priority: TaskPriority;
  isCompleted: boolean;
  dueDate?: Date;
  createdAt: Date;
  updatedAt: Date;
  completedAt?: Date;
  parentTaskID?: string; // For hierarchical structure
  
  // Computed properties
  isMainTask: boolean;
  isSubTask: boolean;
  isOverdue: boolean;
  subTasks?: Task[];
}

export interface CreateTaskRequest {
  title: string;
  notes?: string;
  category?: TaskCategory;
  priority?: TaskPriority;
  dueDate?: string; // ISO string
  parentTaskID?: string;
}

export interface UpdateTaskRequest {
  title?: string;
  notes?: string;
  category?: TaskCategory;
  priority?: TaskPriority;
  isCompleted?: boolean;
  dueDate?: string | null; // ISO string or null to remove
}

export interface TaskFilters {
  category?: TaskCategory;
  priority?: TaskPriority;
  isCompleted?: boolean;
  isOverdue?: boolean;
  dateRange?: {
    from: string; // ISO string
    to: string;   // ISO string
  };
  searchQuery?: string;
  parentTaskID?: string; // Get subtasks of a specific task
}

export interface TaskStats {
  total: number;
  active: number;
  completed: number;
  overdue: number;
  byCategory: Record<TaskCategory, number>;
  byPriority: Record<TaskPriority, number>;
}