---
title: 01 - Manage API key for your MCP Server in Azure Logic Apps
description: Learn how to manage the API Key for your MCP server in Azure Logic Apps. Retrieve an expiring APIKey using primary or secondary access key and also learn how to rotate it.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 11/17/2025
author: DevArjun23
ms.author: archidda
---

In this module, you will learn how to manage the API Key for your MCP server in Azure Logic Apps. Retrieve an expiring APIKey using primary or secondary access key and also learn how to rotate it.

We will use open source HTTP client [Bruno](https://www.usebruno.com/) for this lab.

### 1. Retrieve API Key for MCP Server 🔑

To obtain an API key, call the following endpoint with the query parameter `getApikey=true`

**REST** Endpoint: POST /listMcpServerUrl

**POST** <https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{RGName}/providers/Microsoft.Web/sites/{LAName}/hostruntime/runtime/webhooks/workflow/api/management/listMcpServerUrl?api-version=2021-02-01&getApikey=true>

#### ✅ Request Body (JSON) - Optional

Request Body is optional and can take 2 properties

```json
{
    "keyType": "primary",
    "notAfter": "2025-11-14T10:04:24Z"
}
```

#### 📌 Notes:

- **keyType:** Determines which access key (primary or secondary) is used to generate the API key. If not specified, primary is used as default.
- **notAfter:** Sets the expiration time for the API key. If not specified, the API Key expires in 24 hours from the request.

#### ✅ Response (JSON)

```json
{
  "value": "https://{LAName}.azurewebsites.net/api/mcp",
  "method": "POST",
  "basePath": "https://{LAName}.azurewebsites.net/api/mcp",
  "headers": {
      "X-API-Key": "sanitized"
  }
}
```

### 2. Regenerating the Access Key 🔁

To invalidate all API keys generated from a specific access key, regenerate the access key using:
Endpoint: POST /regenerateMcpServerAccessKey
**POST** https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{RGName}/providers/Microsoft.Web/sites/{LAName}/hostruntime/runtime/webhooks/workflow/api/management/regenerateMcpServerAccessKey?api-version=2021-02-01 

#### ✅ Request Body (JSON)

```json
{
    "keyType": "primary"
}
```

#### ✅ Response : 200

This returns empty JSON if operation is successful.

#### 📌 Notes

- **keyType:** Required property that determines which access key (primary or secondary) is to be rotated.
- This action immediately invalidates all API keys derived from the specified access key.
-	Use this when rotating credentials or responding to a security event.

### 3. Usage

When you configure the MCP Server in hosts with MCP Clients like VS Code, you can provide the api key in the header `X-API-Key`. Here are some examples:

#### Agent Loop

Use the API Key Auth type when you try to add MCP Server to Agent Loop. Check out
[02 - Add BYO MCP tools to your agent](../../logicapps-ai-course/06_extend_agent_functionality_mcp/02-add-byo-mcp-tools.mdx)

#### VS Code: (mcp.json)

![VS Code usage](media\VSCodeUsage.png)

#### Claude Code

- To read-	[Connect Claude Code to tools via MCP - Anthropic](https://code.claude.com/docs/en/mcp)

**Command:**
`claude mcp add --transport http MyKeybasedLogicAppMcpServer https://arjun-wcus-mcpserver.azurewebsites.net/api/mcp --header "X-API-Key:*sanitized*"`

