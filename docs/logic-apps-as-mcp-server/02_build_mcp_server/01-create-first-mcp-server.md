---
title: 01 - Build your first MCP Server in Azure Logic Apps
description: Learn how to enable logic app as MCP server and create your first tool.
description: An overview of the lesson that helps you build Azure Logic Apps as MCP servers.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 11/17/2025
author: DevArjun23
ms.author: archidda
---

In this module, you will learn how to build your first MCP server using Azure Logic Apps by enabling MCP server features, adding MCP tools, and using them in an agent.

We will be following this official documentation from MS Learn: [Set up Standard logic apps as remote MCP servers (Preview)](https://learn.microsoft.com/en-us/azure/logic-apps/set-up-model-context-protocol-server-standard#create-an-app-registration)

## Prerequisites

- An Azure account and subscription. If you don't have a subscription, [sign up for a free Azure account](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).
- Existing Logic Apps Standard workflow app (or create one): [Create a single-tenant workflow app](https://learn.microsoft.com/azure/logic-apps/create-single-tenant-workflows-azure-portal).
- An Azure account and subscription. If you don't have a subscription, [sign up for a free Azure account](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).

## Build MCP Server

While the UX is not available, we will manually change the configuration to enable MCP server endpoints.

### Step 1 - Enable MCP server endpoints

1. Open your Logic Apps Standard resource and select Developement Tools.
   ![Screenshot shows the workflow blade in a Logic App Standard resource.](media/01-create-first-mcp-server/gotokudu.png)
1. Select Advanced Tools and then Go.
1. A Kudu site will open for your logic app.
1. Click on Debug Console on the top bar and select CMD.
1. Select Site
1. Select wwwroot
1. Find the `host.json` file and edit it by clicking on the pencil icon.
   ![Screenshot shows the pencil icon for host.json file.](media/01-create-first-mcp-server/hostjson.png)

### Step 2 - Update the host.json file

1. In host.json file, we need to add the a boolean property to enable MCP server endpoints with value `true`. This is a master switcht to enable or disable everything about your MCP Server. Its JSON path is "$.extensions.workflow.mcpserverendpoints.enable"

```json
{
  "version": "2.0",
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle.Workflows",
    "version": "[1.*, 2.0.0)"
  },
  "extensions": {
    "workflow": {
      "McpServerEndpoints": {
        "enable": true
    }
  }
}
```

By default it will support both OAuth and ApiKey for authentication.

Optionally, if you wanted your app to ony support either OAuth, ApiKey, or Anonymous (no auth, not recommended), then you can explicitly set it.

```json
{
  "version": "2.0",
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle.Workflows",
    "version": "[1.*, 2.0.0)"
  },
  "extensions": {
    "workflow": {
      "McpServerEndpoints": {
        "enable": true,
        "authentication": {
          "type": "ApiKey"
        }
      }
    }
  }
}
```

Your Logic app is now enabled as an MCP server.

### Step 3 - App Registration and Easy Auth setup.
Follow the steps from MS Learn to create Microsoft Entra App Registration and configure your logic app's Easy Auth.
- [Create an app registration](https://learn.microsoft.com/en-us/azure/logic-apps/set-up-model-context-protocol-server-standard#create-an-app-registration)
- [Set up Easy Auth for your MCP server](https://learn.microsoft.com/en-us/azure/logic-apps/set-up-model-context-protocol-server-standard#set-up-easy-auth-for-your-mcp-server)

1. Open your Logic Apps Standard resource and select Authentication under Settings.
1. Select Add identity provider.
1. Select Microsoft.
1. Under App registration type, select 

### Step 4 - Add workflows as MCP tool.
