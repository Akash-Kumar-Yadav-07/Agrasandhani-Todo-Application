#!/usr/bin/env node

/**
 * Agrasandhani MCP Server
 * Divine Task Management with Cosmic Organization
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ErrorCode,
  ListToolsRequestSchema,
  McpError,
} from '@modelcontextprotocol/sdk/types.js';
import { AgrasandhaniDatabase } from './database.js';
import { AgrasandhaniHandlers } from './handlers.js';
import { AGRASANDHANI_TOOLS } from './tools.js';

class AgrasandhaniServer {
  private server: Server;
  private db: AgrasandhaniDatabase;
  private handlers: AgrasandhaniHandlers;

  constructor() {
    this.server = new Server(
      {
        name: 'agrasandhani-mcp',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.db = new AgrasandhaniDatabase();
    this.handlers = new AgrasandhaniHandlers(this.db);
    this.setupHandlers();
  }

  private setupHandlers() {
    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: AGRASANDHANI_TOOLS,
      };
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'create_task':
            return await this.handlers.createTask(args || {});

          case 'get_tasks':
            return await this.handlers.getTasks(args || {});

          case 'update_task':
            return await this.handlers.updateTask(args || {});

          case 'delete_task':
            return await this.handlers.deleteTask(args || {});

          case 'get_task_stats':
            return await this.handlers.getTaskStats(args || {});

          case 'get_task_details':
            return await this.handlers.getTaskDetails(args || {});

          case 'complete_task':
            return await this.handlers.completeTask(args || {});

          case 'create_subtask':
            return await this.handlers.createSubtask(args || {});

          default:
            throw new McpError(
              ErrorCode.MethodNotFound,
              `Unknown tool: ${name}`
            );
        }
      } catch (error) {
        if (error instanceof McpError) {
          throw error;
        }
        
        throw new McpError(
          ErrorCode.InternalError,
          `Tool execution failed: ${error instanceof Error ? error.message : 'Unknown error'}`
        );
      }
    });

    // Error handling
    this.server.onerror = (error) => {
      console.error('[MCP Error]', error);
    };

    process.on('SIGINT', async () => {
      await this.cleanup();
      process.exit(0);
    });

    process.on('SIGTERM', async () => {
      await this.cleanup();
      process.exit(0);
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);

    // Send welcome message
    console.error('🌟 Agrasandhani MCP Server started');
    console.error('✨ Divine task management now available through MCP');
    console.error('🕉️ May your productivity flow with cosmic harmony');
  }

  private async cleanup() {
    console.error('🛑 Shutting down Agrasandhani MCP Server...');
    this.db.close();
    console.error('✨ Divine connection closed gracefully');
  }
}

// Start the server
async function main() {
  const server = new AgrasandhaniServer();
  await server.run();
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}