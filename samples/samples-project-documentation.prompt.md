# Logic Apps Documentation Generation Prompt

## Goal
Create comprehensive documentation for an Azure Logic Apps Standard workspace to prepare it for source control submission. The documentation should enable new developers to understand, set up, and run the project locally.

## Required Actions
You must perform these three tasks in order:

1. **Document Overview Generation**: Create workspace-level documentation explaining the project's purpose
2. **Cloud Settings Generation**: Create a sanitized configuration template removing sensitive values
3. **Local Setup Generation**: Create developer setup instructions for local development

## Project Context
- **Target Platform**: Azure Logic Apps Standard
- **Development Environment**: Local development with VS Code
- **Workspace Structure**: LogicApps folder contains individual workflow folders, each with a `workflow.json` file
- **Configuration Files**: `local.settings.json`, `connections.json`, `parameters.json`, `host.json`

---

# Task 1: Document Overview Generation

## Objective
Create or update a `README.md` file at the workspace root level that serves as the primary project documentation.

## File Location
- Target file: `README.md` (at the workspace root, same level as the LogicApps folder)
- Action: Create if missing, update if exists

## Content Requirements

### Required Sections (in order):
1. **Project Title**: Derive from workspace folder name, clean up special characters, remove suffixes like "sample"
2. **Overview**: High-level project description understandable by both developers and business users
3. **Prerequisites**: List required Azure services based on connectors found in workflows
4. **Deployment Instructions**: 
   - If `Deployment` folder exists: provide instructions for using it
   - Otherwise: reference standard Logic Apps deployment from VS Code
5. **Workflows**: Document each workflow found in the LogicApps folder

### Workflow Documentation Requirements
For each workflow folder in LogicApps (folders containing `workflow.json`):

**Workflow Analysis Instructions:**
- Parse the `workflow.json` file to understand the workflow structure
- Identify triggers, actions, and control flow
- Extract connector information from the actions
- Analyze the workflow's business purpose from action names and structure

**Required Content per Workflow:**
1. **Purpose Description**: Based on workflow name and actions analysis
2. **Mermaid Diagram**: 
   - Show the complete workflow flow
   - Use subgraphs for loops, conditions, and scoped blocks
   - Include trigger, main actions, and decision points
   - Format: ```mermaid followed by flowchart TD syntax
   - Diagram should be comprehensive but not overly complex
   - Include all major steps, conditions, and loops
   - Make sure that group structures are using `subgraph` syntax for clarity
   - Diagram should use the default color scheme for clarity
3. **Connections Table**: Extract from workflow actions
    - Connector Type should be one of the following, based on their connection reference group in connections.json:
        - agentConnections > Agent
        - apiManagementConnections > API Management
        - ManagedAPIConnections > Azure
        - ServiceProviderConnections > Service Provider
        - functionConnections > Azure Function
    - Use the connection displayName for connection name
**Connections Table Format:**
```
|Connection Name|Connector Name|Connector Type|
|---|---|---|
|connectionName|connectorDisplayName|connectorType|
```

## Document Template Structure
```markdown
# [Project Title - Clean workspace name]

[High-level project description that explains the business purpose and value]

## Prerequisites

The following Azure services are required for this project:

- [Service 1] - [Brief purpose]
- [Service 2] - [Brief purpose]
- [Additional services based on connectors found]

## Deployment Instructions

[Include deployment instructions - check for Deployment folder or reference VS Code deployment]

## Workflows

### [Workflow Name 1]

[Description of workflow purpose and business function]

#### Process Flow

```mermaid
flowchart TD
    [Detailed workflow diagram using mermaid syntax]
```

#### Required Connections

|Connection Name|Connector Name|Connector Type|
|---|---|---|
|[connection1]|[connector1]|[type1]|
|[connection2]|[connector2]|[type2]|

[Repeat for each workflow]
```

---

# Task 2: Cloud Settings Generation

## Objective
Create a sanitized version of `local.settings.json` that can be safely committed to source control.

## File Operations
- **Source**: `LogicApps/local.settings.json`
- **Target**: `LogicApps/cloud.settings.json`
- **Action**: Create new file based on local.settings.json

## Processing Rules

### Values to Copy Unchanged
Copy these keys with their exact values if they exist:
```json
{
  "AzureWebJobsStorage": "[keep original value]",
  "APP_KIND": "[keep original value]", 
  "FUNCTIONS_WORKER_RUNTIME": "[keep original value]",
  "FUNCTIONS_INPROC_NET8_ENABLED": "[keep original value]"
}
```

### Values to Sanitize
For all other keys, replace the actual value with a descriptive placeholder:

**Sanitization Format:**
- Connection strings: `"<Add [service name] connection string>"`
- URLs/Endpoints: `"<Add [service name] endpoint URL>"`
- Keys/Secrets: `"<Add [service name] access key>"`
- Paths: `"<Add local path to [resource]>"`
- Generic: `"<Add [description of what this value should contain]>"`

**Example:**
```json
{
  "serviceBus_ConnectionString": "<Add Service Bus namespace connection string>",
  "cosmosDb_accountEndpoint": "<Add Cosmos DB account endpoint URL>",
  "apiKey_OpenAI": "<Add OpenAI API key>"
}
```

---

# Task 3: Local Setup Generation

## Objective
Create comprehensive setup instructions for local development.

## File Operations
- **Target**: `LogicApps/README.md` 
- **Action**: 
   - Create new file with local setup instructions. 
   - Replace the full content of the existing README.md file in the LogicApps folder, if it exists.

## Content Requirements

### Structure and Sections
Use this exact template structure:

```markdown
# Local Development Setup

This guide provides step-by-step instructions for setting up local development environment for this Logic Apps Standard project.

## Overview

The `local.settings.json` file contains configuration settings required for local development. This file should **never** be committed to source control as it contains sensitive connection strings and local-specific paths.

## Quick Setup Steps

### 1. Create local.settings.json
```bash
# Navigate to the LogicApps folder
cd LogicApps

# Copy the template file
copy cloud.settings.json local.settings.json
```

### 2. Configure Required Settings

Update the following values in your `local.settings.json` file:

| Setting Key | Description | Where to Find | Example |
|-------------|-------------|---------------|---------|
| [Key1] | [Description] | [Source/Portal location] | `[sample value]` |
| [Key2] | [Description] | [Source/Portal location] | `[sample value]` |

### 3. Pre-configured Values (Do Not Modify)

These values are already set correctly and should remain unchanged:
- `AzureWebJobsStorage`
- `APP_KIND` 
- `FUNCTIONS_WORKER_RUNTIME`
- `FUNCTIONS_INPROC_NET8_ENABLED`

## Detailed Configuration Guide

[Include specific instructions based on the actual configuration requirements found in cloud.settings.json]

### Connection String Format Examples

**Service Bus:**
```
Endpoint=sb://[namespace].servicebus.windows.net/;SharedAccessKeyName=[keyname];SharedAccessKey=[key]
```

**Cosmos DB:**
```
AccountEndpoint=https://[account].documents.azure.com:443/;AccountKey=[key];
```

## Sample Configuration

Your completed `local.settings.json` should look similar to this:

```json
[Include a sample configuration with realistic but fake values]
```

## Verification Steps

1. **Test Local Run**: Use VS Code Azure Logic Apps extension to start the local runtime
2. **Check Connections**: Verify all connections are working in the Logic Apps Designer
3. **Test Workflows**: Run a simple test of each workflow to ensure proper configuration

## Important Security Notes

- ⚠️ **Never commit `local.settings.json` to source control**
- 🔐 **Use proper Azure RBAC permissions instead of connection strings when possible**
- 🔄 **Rotate keys regularly and update local settings accordingly**

## Troubleshooting

### Common Issues

**File Path Issues (Windows):**
- Ensure paths use double backslashes (`\\`) or forward slashes (`/`)
- Example: `C:\\projects\\myapp` or `C:/projects/myapp`

**Connection Failures:**
- Verify connection strings are complete and unmodified
- Check firewall settings for local development
- Ensure Azure resources allow access from your IP

**Runtime Issues:**
- Verify .NET and Azure Functions Core Tools are installed
- Check VS Code Azure Logic Apps extension is up to date
- Review terminal output for specific error messages

### Getting Help

[Include project-specific troubleshooting tips based on the services used]


---

## Additional Instructions for AI Agent

### Analysis Requirements
When generating documentation, you must:

1. **Read and Parse Files**: 
   - Analyze `workflow.json` files to understand actual workflow structure
   - Parse `local.settings.json` to identify configuration requirements
   - Check for `connections.json` to understand connector dependencies

2. **Extract Connector Information**:
   - Look for connector types in workflow actions (e.g., "Http", "ServiceBus", "CosmosDB")
   - Identify connection references in workflow definitions
   - Map connections to their corresponding Azure services

3. **Generate Accurate Diagrams**:
   - Parse workflow JSON structure to create accurate mermaid diagrams
   - Include all major steps, conditions, and loops
   - Use proper mermaid syntax for flowcharts

4. **Service Detection**:
   - Identify required Azure services from connector usage
   - Determine external dependencies (APIs, databases, etc.)
   - List authentication requirements

### Validation Checklist
Before completing documentation generation, verify:

- [ ] All workflow files have been analyzed
- [ ] Mermaid diagrams accurately represent workflow flow
- [ ] All connectors are documented in connection tables
- [ ] Security-sensitive values are properly sanitized in cloud.settings.json
- [ ] Local setup instructions match actual configuration requirements
- [ ] Prerequisites list includes all required Azure services

### Output Quality Standards
- Use clear, professional language suitable for technical documentation
- Ensure all code blocks use proper syntax highlighting
- Provide specific, actionable instructions
- Include realistic examples that developers can follow
- Maintain consistent formatting throughout all generated documents

