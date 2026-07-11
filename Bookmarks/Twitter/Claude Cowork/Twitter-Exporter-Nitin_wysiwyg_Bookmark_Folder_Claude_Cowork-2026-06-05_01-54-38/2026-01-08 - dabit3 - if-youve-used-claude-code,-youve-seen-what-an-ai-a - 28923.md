---
title: "If you've used Claude Code, you've seen what an AI agent can actually do: read files, run commands,..."
author: "nader dabit"
username: "@dabit3"
date: "2026-01-08"
tweet_url: "https://x.com/dabit3/status/2009131298250428923"
tweet_type: "original"
likes: 8817
retweets: 1055
replies: 169
bookmarks: 22985
views: 4004505
has_media: false
extraction_quality: full
article_id: "2009042873145282561"
tags: ["twitter-bookmark", "claude", "mcp", "agents"]
---

# If you've used Claude Code, you've seen what an AI agent can actually do: read files, run commands,...

> **Source:** [@dabit3](https://x.com/dabit3) · 2026-01-08 · 👍 8817 · 💬 169 · 🔖 22985 · 👁 4004505

> 🔗 [View tweet on X](https://x.com/dabit3/status/2009131298250428923)

## Article Content

If you've used Claude Code, you've seen what an AI agent can actually do: read files, run commands, edit code, figure out the steps to accomplish a task.

And you know it doesn't just help you write code, it takes ownership of problems and works through them the way a thoughtful engineer would.

The [Claude Agent SDK](https://platform.claude.com/docs/en/agent-sdk/overview)

 is the same engine, yours to point at whatever problem you want, so you can easily build agents of your own.

It's the infrastructure behind Claude Code, exposed as a library. You get the agent loop, the built-in tools, the context management, basically everything you'd otherwise have to build yourself.

This guide walks through building a code review agent from scratch. By the end, you'll have something that can analyze a codebase, find bugs and security issues, and return structured feedback.

More importantly, you'll understand how the SDK works so you can build whatever you actually need.

### What we're building

Our code review agent will:

1. Analyze a codebase for bugs and security issues
2. Read files and search through code autonomously
3. Provide structured, actionable feedback
4. Track its progress as it works

### The stack

• ****Runtime**** - [Claude Code CLI](https://code.claude.com/docs/en/cli-reference)

• ****SDK**** - [@anthropic-ai/claude-agent-sdk](https://github.com/anthropics/claude-agent-sdk-typescript)

• ****Language**** - TypeScript 
• ****Model**** - Claude Opus 4.5

### What the SDK gives you

If you've built agents with the raw API, you know the pattern: call the model, check if it wants to use a tool, execute the tool, feed the result back, repeat until done. This can get tedious when building anything non-trivial.

The SDK handles that loop:

```typescript
// Without the SDK: You manage the loop
let response = await client.messages.create({...});
while (response.stop_reason === "tool_use") {
  const result = yourToolExecutor(response.tool_use);
  response = await client.messages.create({ tool_result: result, ... });
}

// With the SDK: Claude manages it
for await (const message of query({ prompt: "Fix the bug in auth.py" })) {
  console.log(message); // Claude reads files, finds bugs, edits code
}
```

You also get working tools out of the box:

• ****Read - ****read any file in the working directory
• ****Write - ****create new files
• ****Edit - ****make precise edits to existing files
• ****Bash - ****run terminal commands
• ****Glob - ****find files by pattern
• ****Grep - ****search file contents with regex
• ****WebSearch - ****search the web
• ****WebFetch - ****fetch and parse web pages

You don't have to implement any of this yourself.

### Prerequisites

1. Node.js 18+ installed
2. An Anthropic API key ([get one here](https://console.anthropic.com/)

)

### Getting started

****Step 1: Install Claude Code CLI****

The Agent SDK uses Claude Code as its runtime:

```bash
npm install -g @anthropic-ai/claude-code
```

After installing, run ****claude**** in your terminal and follow the prompts to authenticate.

****Step 2: Create your project****

```bash
mkdir code-review-agent && cd code-review-agent
npm init -y
npm install @anthropic-ai/claude-agent-sdk
npm install -D typescript @types/node ```tsx

Step 3: Set your API key

```bash
export ANTHROPIC_API_KEY=your-api-key
```

### Your first agent

Create ****agent.ts****:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

async function main() {
  for await (const message of query({
    prompt: "What files are in this directory?",
    options: {
      model: "opus",
      allowedTools: ["Glob", "Read"],
      maxTurns: 250
    }
  })) {
    if (message.type === "assistant") {
      for (const block of message.message.content) {
        if ("text" in block) {
          console.log(block.text);
        }
      }
    }
    
    if (message.type === "result") {
      console.log("\nDone:", message.subtype);
    }
  }
}

main();
```

Run it:

```bash
npx tsx agent.```ts

Claude will use the ****Glob**** tool to list files and tell you what it found.

### Understanding the message stream

The ****query() ****function returns an async generator that streams messages as Claude works. Here are the key message types:

```typescript
for await (const message of query({ prompt: "..." })) {
  switch (message.type) {
    case "system":
      // Session initialization info
      if (message.subtype === "init") {
        console.log("Session ID:", message.session_id);
        console.log("Available tools:", message.tools);
      }
      break;
      
    case "assistant":
      // Claude's responses and tool calls
      for (const block of message.message.content) {
        if ("text" in block) {
          console.log("Claude:", block.text);
        } else if ("name" in block) {
          console.log("Tool call:", block.name);
        }
      }
      break;
      
    case "result":
      // Final result
      console.log("Status:", message.subtype); // "success" or error type
      console.log("Cost:", message.total_cost_usd);
      break;
  }
}
```

### Building a code review agent

Now let's build something useful. Create ****review-agent.ts****:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

async function reviewCode(directory: string) {
  console.log(`\n🔍 Starting code review for: ${directory}\n`);
  
  for await (const message of query({
    prompt: `Review the code in ${directory} for:
1. Bugs and potential crashes
2. Security vulnerabilities  
3. Performance issues
4. Code quality improvements

Be specific about file names and line numbers.`,
    options: {
      model: "opus",
      allowedTools: ["Read", "Glob", "Grep"],
      permissionMode: "bypassPermissions", // Auto-approve read operations
      maxTurns: 250
    }
  })) {
    // Show Claude's analysis as it happens
    if (message.type === "assistant") {
      for (const block of message.message.content) {
        if ("text" in block) {
          console.log(block.text);
        } else if ("name" in block) {
          console.log(`\n📁 Using ${block.name}...`);
        }
      }
    }
    
    // Show completion status
    if (message.type === "result") {
      if (message.subtype === "success") {
        console.log(`\n✅ Review complete! Cost: $${message.total_cost_usd.toFixed(4)}`);
      } else {
        console.log(`\n❌ Review failed: ${message.subtype}`);
      }
    }
  }
}

// Review the current directory
reviewCode(".");
```

****Testing It Out****

Create a file with some intentional issues. Create ****example.ts****:

```typescript
function processUsers(users: any) {
  for (let i = 0; i <= users.length; i++) { // Off-by-one error
    console.log(users[i].name.toUpperCase()); // No null check
  }
}

function connectToDb(password: string) {
  const connectionString = `postgres://admin:${password}@localhost/db`;
  console.log("Connecting with:", connectionString); // Logging sensitive data
}

async function fetchData(url) { // Missing type annotation
  const response = await fetch(url);
  return response.json(); // No error handling
}
```

Run the review:

```bash
npx tsx review-agent.```ts

Claude will identify the bugs, security issues, and suggest fixes.

### Adding Structured Output

For programmatic use, you'll want structured data. The SDK supports JSON Schema output:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

const reviewSchema = {
  type: "object",
  properties: {
    issues: {
      type: "array",
      items: {
        type: "object",
        properties: {
          severity: { type: "string", enum: ["low", "medium", "high", "critical"] },
          category: { type: "string", enum: ["bug", "security", "performance", "style"] },
          file: { type: "string" },
          line: { type: "number" },
          description: { type: "string" },
          suggestion: { type: "string" }
        },
        required: ["severity", "category", "file", "description"]
      }
    },
    summary: { type: "string" },
    overallScore: { type: "number" }
  },
  required: ["issues", "summary", "overallScore"]
};

async function reviewCodeStructured(directory: string) {
  for await (const message of query({
    prompt: `Review the code in ${directory}. Identify all issues.`,
    options: {
      model: "opus",
      allowedTools: ["Read", "Glob", "Grep"],
      permissionMode: "bypassPermissions",
      maxTurns: 250,
      outputFormat: {
        type: "json_schema",
        schema: reviewSchema
      }
    }
  })) {
    if (message.type === "result" && message.subtype === "success") {
      const review = message.structured_output as {
        issues: Array<{
          severity: string;
          category: string;
          file: string;
          line?: number;
          description: string;
          suggestion?: string;
        }>;
        summary: string;
        overallScore: number;
      };
      
      console.log(`\n📊 Code Review Results\n`);
      console.log(`Score: ${review.overallScore}/100`);
      console.log(`Summary: ${review.summary}\n`);
      
      for (const issue of review.issues) {
        const icon = issue.severity === "critical" ? "🔴" :
                     issue.severity === "high" ? "🟠" :
                     issue.severity === "medium" ? "🟡" : "🟢";
        console.log(`${icon} [${issue.category.toUpperCase()}] ${issue.file}${issue.line ? `:${issue.line}` : ""}`);
        console.log(`   ${issue.description}`);
        if (issue.suggestion) {
          console.log(`   💡 ${issue.suggestion}`);
        }
        console.log();
      }
    }
  }
}

reviewCodeStructured(".");
```

### Handling permissions

By default, the SDK asks for approval before executing tools. You can customize this:

Permission modes

```typescript
options: {
  // Standard mode - prompts for approval
  permissionMode: "default",
  
  // Auto-approve file edits
  permissionMode: "acceptEdits",
  
  // No prompts (use with caution)
  permissionMode: "bypassPermissions"
}
```

****Custom permission handler****

For fine-grained control, use ****canUseTool****:

```typescript
options: {
  canUseTool: async (toolName, input) => {
    // Allow all read operations
    if (["Read", "Glob", "Grep"].includes(toolName)) {
      return { behavior: "allow", updatedInput: input };
    }
    
    // Block writes to certain files
    if (toolName === "Write" && input.file_path?.includes(".env")) {
      return { behavior: "deny", message: "Cannot modify .env files" };
    }
    
    // Allow everything else
    return { behavior: "allow", updatedInput: input };
  }
}
```

### Creating subagents

For complex tasks, you can create specialized subagents:

```typescript
import { query, AgentDefinition } from "@anthropic-ai/claude-agent-sdk";

async function comprehensiveReview(directory: string) {
  for await (const message of query({
    prompt: `Perform a comprehensive code review of ${directory}. 
Use the security-reviewer for security issues and test-analyzer for test coverage.`,
    options: {
      model: "opus",
      allowedTools: ["Read", "Glob", "Grep", "Task"], // Task enables subagents
      permissionMode: "bypassPermissions",
      maxTurns: 250,
      agents: {
        "security-reviewer": {
          description: "Security specialist for vulnerability detection",
          prompt: `You are a security expert. Focus on:
- SQL injection, XSS, CSRF vulnerabilities
- Exposed credentials and secrets
- Insecure data handling
- Authentication/authorization issues`,
          tools: ["Read", "Grep", "Glob"],
          model: "sonnet"
        } as AgentDefinition,
        
        "test-analyzer": {
          description: "Test coverage and quality analyzer",
          prompt: `You are a testing expert. Analyze:
- Test coverage gaps
- Missing edge cases
- Test quality and reliability
- Suggestions for additional tests`,
          tools: ["Read", "Grep", "Glob"],
          model: "haiku" // Use faster model for simpler analysis
        } as AgentDefinition
      }
    }
  })) {
    if (message.type === "assistant") {
      for (const block of message.message.content) {
        if ("text" in block) {
          console.log(block.text);
        } else if ("name" in block && block.name === "Task") {
          console.log(`\n🤖 Delegating to: ${(block.input as any).subagent_type}`);
        }
      }
    }
  }
}

comprehensiveReview(".");
```

### Session management

For multi-turn conversations, capture and resume sessions:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

async function interactiveReview() {
  let sessionId: string | undefined;
  
  // Initial review
  for await (const message of query({
    prompt: "Review this codebase and identify the top 3 issues",
    options: {
      model: "opus",
      allowedTools: ["Read", "Glob", "Grep"],
      permissionMode: "bypassPermissions",
      maxTurns: 250
    }
  })) {
    if (message.type === "system" && message.subtype === "init") {
      sessionId = message.session_id;
    }
    // ... handle messages
  }
  
  // Follow-up question using same session
  if (sessionId) {
    for await (const message of query({
      prompt: "Now show me how to fix the most critical issue",
      options: {
        resume: sessionId, // Continue the conversation
        allowedTools: ["Read", "Glob", "Grep"],
        maxTurns: 250
      }
    })) {
      // Claude remembers the previous context
    }
  }
}
```

### Using hooks

Hooks let you intercept and customize agent behavior:

```typescript
import { query, HookCallback, PreToolUseHookInput } from "@anthropic-ai/claude-agent-sdk";

// Hook callbacks receive three arguments:
// 1. input - details about the event (tool name, arguments, etc.)
// 2. toolUseId - correlates PreToolUse and PostToolUse events for the same call
// 3. context - contains AbortSignal for cancellation
const auditLogger: HookCallback = async (input, toolUseId, { signal }) => {
  if (input.hook_event_name === "PreToolUse") {
    const preInput = input as PreToolUseHookInput;
    console.log(`[AUDIT] ${new Date().toISOString()} - ${preInput.tool_name}`);
  }
  return {}; // Return empty object to allow the operation
};

const blockDangerousCommands: HookCallback = async (input, toolUseId, { signal }) => {
  if (input.hook_event_name === "PreToolUse") {
    const preInput = input as PreToolUseHookInput;
    if (preInput.tool_name === "Bash") {
      const command = (preInput.tool_input as any).command || "";
      if (command.includes("rm -rf") || command.includes("sudo")) {
        return {
          hookSpecificOutput: {
            hookEventName: "PreToolUse",
            permissionDecision: "deny",  // Block the tool from executing
            permissionDecisionReason: "Dangerous command blocked"
          }
        };
      }
    }
  }
  return {};
};

for await (const message of query({
  prompt: "Clean up temporary files",
  options: {
    model: "opus",
    allowedTools: ["Bash", "Glob"],
    maxTurns: 50,
    hooks: {
      // PreToolUse fires before each tool executes
      // Other hooks: PostToolUse, Stop, SessionStart, SessionEnd, etc.
      PreToolUse: [
        // Each entry has an optional matcher (regex) and an array of callbacks
        // No matcher = runs for ALL tool calls
        { hooks: [auditLogger] },
        
        // matcher: 'Bash' = only runs when tool_name matches 'Bash'
        // Use regex for multiple tools: 'Bash|Write|Edit'
        { matcher: "Bash", hooks: [blockDangerousCommands] }
      ]
    }
  }
})) {
  if (message.type === "assistant") {
    for (const block of message.message.content) {
      if ("text" in block) {
        console.log(block.text);
      }
    }
  }
}
```

### Custom tool calling

Tools are how agents interact with the world - reading files, calling APIs, querying databases, running code. The SDK includes built-in tools for common operations (filesystem, shell, web), but most agents will need custom tools to access your own systems.

****The raw API pattern****

Without the SDK, you manage the tool loop yourself:

```typescript
// 1. Define tools with their schemas
const tools = [{
  name: "get_weather",
  description: "Get current weather for a city",
  input_schema: {
    type: "object",
    properties: {
      city: { type: "string", description: "City name" }
    },
    required: ["city"]
  }
}];

// 2. Write an executor for each tool
function executeTool(name: string, input: any): string {
  if (name === "get_weather") {
    return fetchWeatherAPI(input.city);
  }
  throw new Error(`Unknown tool: ${name}`);
}

// 3. Run the agent loop
const messages = [{ role: "user", content: "What's the weather in Tokyo?" }];

let response = await client.messages.create({
  model: "claude-opus-4-5-20251101",
  tools,
  messages
});

while (response.stop_reason === "tool_use") {
  messages.push({ role: "assistant", content: response.content });
  
  const toolResults = response.content
    .filter(block => block.type === "tool_use")
    .map(toolUse => ({
      type: "tool_result",
      tool_use_id: toolUse.id,
      content: executeTool(toolUse.name, toolUse.input)
    }));
  
  messages.push({ role: "user", content: toolResults });
  response = await client.messages.create({ model, tools, messages });
}

const textBlock = response.content.find(block => block.type === "text");
if (textBlock && textBlock.type === "text") {
  console.log("Final response:", textBlock.text);
}
```

****Key points:****

- C****laude decides**** when to use tools based on the user's request and tool descriptions
- ****You execute**** the tools and return results
- ****The loop continues ****until Claude has enough information (`stop_reason: "end_turn"`)
- ****Message history grows ****with each iteration - the API is stateless, so every request needs the full conversation

****What the SDK handles****

When you use built-in tools like `allowedTools: ["Read", "Glob"]`, the SDK manages all of this automatically - definitions, execution, and the loop.

For custom tools, you need a way to define them so the SDK can do the same. That's what MCP provides.

### Adding custom tools with MCP

Extend Claude with custom tools using Model Context Protocol:

```typescript
import { query, tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

// Create your custom MCP server
const customServer = createSdkMcpServer({
  name: "code-metrics",
  version: "1.0.0",
  tools: [
    // Define a custom tool using the `tool` helper
    // Arguments: name, description, input schema, handler function
    tool(
      "analyze_complexity",
      "Calculate cyclomatic complexity for a file",
      {
        // Zod schema defines what inputs the tool accepts
        filePath: z.string().describe("Path to the file to analyze")
      },
      // Handler function - runs when Claude calls the tool
      async (args) => {
        // In real implementation, calculate actual complexity 
        const complexity = Math.floor(Math.random() * 20) + 1;
        
        // Return format required by MCP - array of content blocks
        return {
          content: [{
            type: "text",
            text: `Cyclomatic complexity for ${args.filePath}: ${complexity}`
          }]
        };
      }
    )
  ]
});

async function analyzeCode(filePath: string) {
  for await (const message of query({
    prompt: `Analyze the complexity of ${filePath}`,
    options: {
      model: "opus",
      
      // Register the custom MCP server
      // The key ("code-metrics") becomes part of the tool name
      mcpServers: {
        "code-metrics": customServer
      },
      
      // Specify which tools Claude can use
      // MCP tools follow the pattern: mcp__<server-name>__<tool-name>
      allowedTools: ["Read", "mcp__code-metrics__analyze_complexity"],
      
      // Maximum number of back-and-forth turns before stopping
      maxTurns: 50
    }
  })) {
    // Handle assistant messages (Claude's responses and tool calls)
    if (message.type === "assistant") {
      for (const block of message.message.content) {
        // Text blocks contain Claude's written responses
        if ("text" in block) {
          console.log(block.text);
        }
      }
    }
    
    // Handle the final result when the agent loop completes
    if (message.type === "result") {
      console.log("Done:", message.subtype); // "success" or an error type
    }
  }
}

analyzeCode("main.ts");
```

### Cost tracking

Track API costs for billing:

```typescript
for await (const message of query({ prompt: "..." })) {
  if (message.type === "result" && message.subtype === "success") {
    console.log("Total cost:", message.total_cost_usd);
    console.log("Token usage:", message.usage);
    
    // Per-model breakdown (useful with subagents)
    for (const [model, usage] of Object.entries(message.modelUsage)) {
      console.log(`${model}: $${usage.costUSD.toFixed(4)}`);
    }
  }
}
```

### Production code review agent

Here's a production-ready agent that ties everything together:

```typescript
import { query, AgentDefinition } from "@anthropic-ai/claude-agent-sdk";

interface ReviewResult {
  issues: Array<{
    severity: "low" | "medium" | "high" | "critical";
    category: "bug" | "security" | "performance" | "style";
    file: string;
    line?: number;
    description: string;
    suggestion?: string;
  }>;
  summary: string;
  overallScore: number;
}

const reviewSchema = {
  type: "object",
  properties: {
    issues: {
      type: "array",
      items: {
        type: "object",
        properties: {
          severity: { type: "string", enum: ["low", "medium", "high", "critical"] },
          category: { type: "string", enum: ["bug", "security", "performance", "style"] },
          file: { type: "string" },
          line: { type: "number" },
          description: { type: "string" },
          suggestion: { type: "string" }
        },
        required: ["severity", "category", "file", "description"]
      }
    },
    summary: { type: "string" },
    overallScore: { type: "number" }
  },
  required: ["issues", "summary", "overallScore"]
};

async function runCodeReview(directory: string): Promise<ReviewResult | null> {
  console.log(`\n${"=".repeat(50)}`);
  console.log(`🔍 Code Review Agent`);
  console.log(`📁 Directory: ${directory}`);
  console.log(`${"=".repeat(50)}\n`);

  let result: ReviewResult | null = null;

  for await (const message of query({
    prompt: `Perform a thorough code review of ${directory}.

Analyze all source files for:
1. Bugs and potential runtime errors
2. Security vulnerabilities
3. Performance issues
4. Code quality and maintainability

Be specific with file paths and line numbers where possible.`,
    options: {
      model: "opus",
      allowedTools: ["Read", "Glob", "Grep", "Task"],
      permissionMode: "bypassPermissions",
      maxTurns: 250,
      outputFormat: {
        type: "json_schema",
        schema: reviewSchema
      },
      agents: {
        "security-scanner": {
          description: "Deep security analysis for vulnerabilities",
          prompt: `You are a security expert. Scan for:
- Injection vulnerabilities (SQL, XSS, command injection)
- Authentication and authorization flaws
- Sensitive data exposure
- Insecure dependencies`,
          tools: ["Read", "Grep", "Glob"],
          model: "sonnet"
        } as AgentDefinition
      }
    }
  })) {
    // Progress updates
    if (message.type === "assistant") {
      for (const block of message.message.content) {
        if ("name" in block) {
          if (block.name === "Task") {
            console.log(`🤖 Delegating to: ${(block.input as any).subagent_type}`);
          } else {
            console.log(`📂 ${block.name}: ${getToolSummary(block)}`);
          }
        }
      }
    }

    // Final result
    if (message.type === "result") {
      if (message.subtype === "success" && message.structured_output) {
        result = message.structured_output as ReviewResult;
        console.log(`\n✅ Review complete! Cost: $${message.total_cost_usd.toFixed(4)}`);
      } else {
        console.log(`\n❌ Review failed: ${message.subtype}`);
      }
    }
  }

  return result;
}

function getToolSummary(block: any): string {
  const input = block.input || {};
  switch (block.name) {
    case "Read": return input.file_path || "file";
    case "Glob": return input.pattern || "pattern";
    case "Grep": return `"${input.pattern}" in ${input.path || "."}`;
    default: return "";
  }
}

function printResults(result: ReviewResult) {
  console.log(`\n${"=".repeat(50)}`);
  console.log(`📊 REVIEW RESULTS`);
  console.log(`${"=".repeat(50)}\n`);
  
  console.log(`Score: ${result.overallScore}/100`);
  console.log(`Issues Found: ${result.issues.length}\n`);
  console.log(`Summary: ${result.summary}\n`);
  
  const byCategory = {
    critical: result.issues.filter(i => i.severity === "critical"),
    high: result.issues.filter(i => i.severity === "high"),
    medium: result.issues.filter(i => i.severity === "medium"),
    low: result.issues.filter(i => i.severity === "low")
  };
  
  for (const [severity, issues] of Object.entries(byCategory)) {
    if (issues.length === 0) continue;
    
    const icon = severity === "critical" ? "🔴" :
                 severity === "high" ? "🟠" :
                 severity === "medium" ? "🟡" : "🟢";
    
    console.log(`\n${icon} ${severity.toUpperCase()} (${issues.length})`);
    console.log("-".repeat(30));
    
    for (const issue of issues) {
      const location = issue.line ? `${issue.file}:${issue.line}` : issue.file;
      console.log(`\n[${issue.category}] ${location}`);
      console.log(`  ${issue.description}`);
      if (issue.suggestion) {
        console.log(`  💡 ${issue.suggestion}`);
      }
    }
  }
}

// Run the review
async function main() {
  const directory = process.argv[2] || ".";
  const result = await runCodeReview(directory);
  
  if (result) {
    printResults(result);
  }
}

main().catch(console.error);
```

Run it:

```bash
npx tsx review-agent.ts ./src
```

### What's next

The code review agent covers the essentials: query(), allowedTools, structured output, subagents, and permissions.

If you want to go deeper:

More capabilities

- [File checkpointing](https://platform.claude.com/docs/en/agent-sdk/file-checkpointing)

 - track and revert file changes
- [Skills](https://platform.claude.com/docs/en/agent-sdk/skills)

 - package reusable capabilities

Production deployment

- [Hosting](https://platform.claude.com/docs/en/agent-sdk/hosting)

 - deploy in containers and CI/CD
- [Secure deployment](https://platform.claude.com/docs/en/agent-sdk/secure-deployment)

- sandboxing and credential management

Full reference

- [TypeScript SDK reference](https://platform.claude.com/docs/en/agent-sdk/typescript)
- [Python SDK reference](https://platform.claude.com/docs/en/agent-sdk/python)

> This guide covers V1 of the SDK. [V2](https://platform.claude.com/docs/en/agent-sdk/typescript-v2-preview)
> 
>  is currently in development. I will update this guide with V2 once it's released and stable.
> 
> If you're interested in building verifiable agents, check out the work we're doing at [@eigencloud](https://x.com/@eigencloud)
> 
>  [here](https://developers.eigencloud.xyz/?utm_source=x&utm_medium=social&utm_campaign=claude_sdk_tutorial)
> 
> .

> 📄 Original article URL: https://x.com/i/article/2009042873145282561

---

## Commentary from Other Bookmarks

### @dabit3 (nader dabit) — 2026-01-08

> I learned and used the Claude Agent SDK today to build an agent. I genuinely think this will be one of the most useful skillets to have in this new world.
> 
> Documented the TLDR here in this tutorial to get you started.

[→ View quote tweet](https://x.com/dabit3/status/2009139688959852701)

