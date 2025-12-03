---
title: 01 - Build MCP Server in Azure Logic Apps
description: Learn how to enable logic app as MCP server and create tools.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 11/17/2025
author: DevArjun23
ms.author: archidda
---

In this module, you will learn how to build your first MCP server using Azure Logic Apps by enabling MCP server features, adding MCP tools, and using them in an agent.

There are 2 ways to create MCP server.

1. **Manually** by enabling the MCP Server Endpoints, creating Entra App Registration, configuring Easy Auth, and creating the tools you need. The offcial documentation can be found at MS Learn: [Set up Standard logic apps as remote MCP servers (Preview)](https://learn.microsoft.com/en-us/azure/logic-apps/set-up-model-context-protocol-server-standard#create-an-app-registration)
2. **Automatically** from the Azure API Center resource. The offcial documentation can be found at MS Learn: [Create and register MCP servers in API Center based on Azure Logic Apps (preview)](https://learn.microsoft.com/en-us/azure/logic-apps/create-mcp-server-api-center)

In this lab, we will use the API Center approach so all the necessary resources are provisioned for us.

## Prerequisites

- An Azure account and subscription. If you don't have a subscription, [sign up for a free Azure account](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).
- Existing Logic Apps Standard workflow app (or create one): [Create a single-tenant workflow app](https://learn.microsoft.com/azure/logic-apps/create-single-tenant-workflows-azure-portal).
- Existing API Center (or create one): [Create API center resource](https://learn.microsoft.com/en-us/azure/api-center/set-up-api-center).

## Create and Register an MCP Server

1. Start with a logic app with no workflows and no easy auth configured.
1. Follow the steps from 1 through 4.b mentioned in [Create an MCP Server and tools](https://learn.microsoft.com/en-us/azure/logic-apps/create-mcp-server-api-center#create-an-mcp-server-and-tools).
   1. Add MCP Server name and description as applicable.
1. For step 4.c, we will select Microsoft Teams connector and the action "Post message in a chat or channel".
1. Complete the parameters setup that needs user or model inputs. This will help send a message to either a group chat, channel from your user.
1. Select Register

    ![Tools Parameters Configured](media/02-create-first-mcp-server/mcptoolparameters.png)

1. In the notifications, you can confirm that the tools are saved, logic app setup is completed for auth configuration and MCP Server registered successfully in the APIC resource.

    ![MCPServerRegistered](media/02-create-first-mcp-server/mcpregisterednotification.png)

   1. Your MCP server is now created and registered.

### Get MCP Server URL

To get the MCP Server URL, there are 2 ways-

1. Call the API manually from HTTP client like Bruno
   - **Http Method:** POST
   - **URL:** https://management.azure.com/subscriptions/{subId}/resourceGroups/{RGName}/providers/Microsoft.Web/sites/{LAName}/hostruntime/runtime/webhooks/workflow/api/management/listMcpServers?api-version=2021-02-01
   - Sample response

        ```json
        {
          "value": [
            {
              "url": "https://1029-mcpserver1.azurewebsites.net/api/mcpservers/teamsmcp/mcp",
              "name": "teamsmcp",
              "description": "This is an MCP Server to send message over Microsoft teams.",
              "tools": [
                {
                  "name": "Post_message_in_a_chat_or_channel"
                }
              ]
            }
          ]
        }
        ```

1. From API Center: [Find and view your MCP server](https://learn.microsoft.com/en-us/azure/logic-apps/create-mcp-server-api-center#find-and-view-your-mcp-server)
