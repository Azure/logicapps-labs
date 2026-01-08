---
title: 05 - Connect your agents with A2A protocol
description: Learn how to integrate Azure Logic Apps conversational agents with external services using the A2A protocol and the A2A Python SDK.
ms.service: azure-logic-apps
author: nikhilsira
ms.author: nikhilsira
ms.topic: tutorial
ms.date: 08/27/2025
---

In this module, you learn how to integrate Azure Logic Apps conversational agents with external services by using the Agent-to-Agent (A2A) protocol and the A2A Python SDK.

When you finish this module, you'll achieve the goals and complete the tasks in the following list:

- Understand how conversational agents in Azure Logic Apps align with the A2A protocol for interoperability.
- Discover agents using the agent card and understand its structure and purpose.
- Use A2A-compliant APIs to send messages, retrieve tasks, and stream responses.
- Authenticate with agents using API keys or Easy Auth, previously known as App Service Authentication.
- Connect to an Azure Logic Apps agent using the official Python SDK and perform basic interactions.

## Prerequisites

- An Azure account and subscription. If you don't have a subscription, [sign up for a free Azure account](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).

- A Standard logic app resource and a conversational agent workflow with the model that you set up in previous modules.

  If you don't have this workflow, see [Create your first conversational agent](01-create-first-conversational-agent.mdx).

## Communicate between agents and clients with the A2A protocol

Conversational agent workflows in Azure Logic Apps support the [A2A protocol](https://a2a-protocol.org/latest/), which provides seamless integration with other AI agents and client applications. This protocol provides a common language that breaks down silos and fosters interoperability in an environment where various teams and vendors use diverse frameworks to build agents. 
	
Conversational agents expose an API surface that abstracts away specific Azure Logic Apps constructs like workflows and runs, focusing on conversational units, or messages, and tasks instead. By using the A2A protocol, a conversational agent provides the following benefits:

| Benefit | Description |
|---------|-------------|
| Interoperability | Aligns with A2A protocol for compatibility with other platforms. |
| Authentication options | Supports API key and OAuth. |
| Multi-turn conversations | Supports back-and-forth interactions. |
| Conversational memory | Maintains context across sessions. |
| Real-time streaming | Provides live status updates. |

### Goals

- Easily incorporate Azure Logic Apps agents into multi-agent solutions.
- Replace code-heavy agents with minimal changes.

## Trigger parameters and authentication for conversational agents

In this section we will review the trigger parameters and authentication methods involing Azure Logic Apps conversational agents.

### Review trigger parameters for the conversational agent workflow

| Parameter | Description |
|-----------|-------------|
| **Agent URL** | The URL through which all communication happens with a conversational agent and serves as the entry point for all A2A-compliant API calls, such as `message/send`, `tasks/get`, and `message/stream`. This URL directly maps to the A2A server endpoint in the [A2A specification](https://a2a-protocol.org/latest/specification/#2-core-concepts-summary) |
| **Agent API key** | The API or developer key that the `X-API-Key` header requires for any communication with the agent. |
| **Name** | The agent name that you provide. Appears in the agent card's `name` property, described in a later section. |
| **Description** | The agent description that you provide. Appears in the agent card's `description` property, described in a later section. |

![Screenshot shows Azure portal and designer with example conversational agent workflow.](./media/05-connect-agents-a2a-protocol/when-a-new-chat-session-started-trigger.png)

### Review supported authentication

Azure Logic Apps conversational agents support two authentication methods:

- **API key-based authentication**: This is the default method. The API key (also referred to as the developer key) must be included in the X-API-Key header for any communication with the agent.
- **App Service authentication (EasyAuth)**: If EasyAuth is configured on the logic app, it takes precedence over API key-based authentication. This method is typically used when OAuth flows or on-behalf-of (OBO) scenarios are required, such as interacting with connectors that require user context (explained in [Add user context to your tools](./04-add-user-context-to-tools.mdx).

## Learn about agent discovery and agent cards

In Azure Logic Apps, each conversational agent exposes an *agent card* that acts as a digital business card and is essential to discovering the agent and initiating interactions. The agent card is a JSON document that's defined by the [A2A specification](https://a2a-protocol.org/latest/specification/#5-agent-discovery-the-agent-card).

You can find the JSON document for the agent card hosted at the [well-known URI](https://www.rfc-editor.org/rfc/rfc8615.html) endpoint:

 `<agent-url>/.well-known/agent-card.json`

> :::note
> You can access the agent card by using the API key or Easy Auth authentication described previously.

### Agent card includes:
- Agent name
- Service endpoint
- Description
- Authentication methods
- Skills and capabilities

> :::note
> The agent card is generated automatically for every conversational agent. Any default values can be overridden in the trigger description.

Here is a sample agent-card.json for the weather agent:

```json
{
  "protocolVersion": "0.3.0",
  "name": "Weather Agent",
  "description": "An agent that fetches the weather forecast for any given location",
  "url": "https://test-agent-app.azurewebsites.net/api/agents/WeatherAgent",
  "version": "08584457010294671865",
  "capabilities": {
    "streaming": true,
    "pushNotification": false,
    "stateTransitionHistory": false
  },
  "defaultInputModes": [
    "application/json"
  ],
  "defaultOutputModes": [
    "application/json"
  ],
  "skills": [
    {
      "id": "08584457010294671865",
      "name": "WeatherAgent",
      "description": "An agent that fetches the weather forecast for any given location",
      "tags": []
    }
  ]
}
```

## Azure Logic Apps agent APIs

The [A2A specification](https://a2a-protocol.org/latest/specification/) dictates the APIs follow the [JSON-RPC 2.0 transport protocol](https://www.a2aprotocol.org/en/docs/json-rpc-2-0) and are suitable for external A2A clients:

- [`message/send`](https://a2a-protocol.org/latest/specification/#71-messagesend): Sends a message to an agent to initiate a new interaction or to continue an existing one. This method is suitable for synchronous request/response interactions or when client-side polling (using tasks/get) is acceptable for monitoring longer-running tasks.
- [`tasks/get`](https://a2a-protocol.org/latest/specification/#73-tasksget): Retrieves the current state (including status, artifacts, and optionally history) of a previously initiated task. This is typically used for polling the status of a task initiated with message/send, or for fetching the final state of a task after being notified via a push notification or after an SSE stream has ended.
- [`message/stream`](https://a2a-protocol.org/latest/specification/#72-messagestream): Sends a message to an agent to initiate/continue a task AND subscribes the client to real-time updates for that task via Server-Sent Events (SSE). Azure Logic Apps conversational agents support streaming.

> :::note
> Our internal chat client (described in [Create your First Conversational Agent](./01-create-first-conversational-agent.mdx)) uses the message/stream API for communicating with the conversational agent.
> Chat clients prefer streaming over polling APIs for the following reasons:
> - Faster feedback and reduced Wait time.
> - Improved perception of transparency and trust.
> - Enhanced user experience for long or complex Outputs.

## Connect to an Azure Logic Apps agent from the A2A Python SDK

In addition to communicating with the agent via the internal chat client, we can communicate with an Azure Logic Apps conversational agents from external chat clients and SDKs.

This section shows how to use the [A2A Python SDK](https://github.com/a2aproject/a2a-python) to connect to an Azure Logic Apps agent using an API key, fetch the agent card, send a message, and poll for task results.

```python
import logging
from typing import Any
from uuid import uuid4
import httpx
from a2a.client import A2ACardResolver, A2AClient
from a2a.types import (
    AgentCard,
    Task,
    MessageSendParams,
    SendMessageRequest,
    SendMessageSuccessResponse,
    GetTaskRequest,
    TaskQueryParams,
    GetTaskSuccessResponse,
)
from a2a.utils.constants import (
    AGENT_CARD_WELL_KNOWN_PATH,
)

async def initialize_a2a_client(httpx_client: httpx.AsyncClient, agent_url: str, api_key: str, logger: logging.Logger) -> A2AClient:
    resolver = A2ACardResolver(
        httpx_client=httpx_client,
        base_url=agent_url,
    )
    logger.info(
        f'Attempting to fetch public agent card from: {agent_url}{AGENT_CARD_WELL_KNOWN_PATH}'
    )
    headers = {
        'X-Api-Key': api_key
    }
    _public_card = (await resolver.get_agent_card(http_kwargs={"headers": headers}))

    logger.info('Successfully fetched public agent card:')
    
    logger.info(_public_card.model_dump_json(indent=2, exclude_none=True))
    logger.info('\nUsing PUBLIC agent card for client initialization.')
    client = A2AClient(httpx_client=httpx_client, agent_card=_public_card)
    logger.info('A2AClient initialized.')
    return client, headers

async def main(agent_url: str, api_key: str) -> None:
    # Configure logging to show INFO level messages
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)  # Get a logger instance

    async with httpx.AsyncClient() as httpx_client:

        # Initialize the A2A client
        client, headers = await initialize_a2a_client(httpx_client, agent_url, api_key, logger)

        # <-- [start:send message]

        send_message_payload: dict[str, Any] = {
            'message': {
                'role': 'user',
                'parts': [
                    {'kind': 'text', 'text': 'What is the weather like in Seattle?'}
                ],
                'messageId': uuid4().hex,
            },
        }
        request = SendMessageRequest(
            id=str(uuid4()), params=MessageSendParams(**send_message_payload)
        )

        send_message_response = await client.send_message(request, http_kwargs={"headers": headers})
        print("Send Message Response:")
        logger.info(send_message_response.model_dump_json(indent=2, exclude_none=True))

        # --<-- [end:send message]

        await asyncio.sleep(5)

        # <-- [start:get task]

        if isinstance(send_message_response.root, SendMessageSuccessResponse):
            if isinstance(send_message_response.root.result, Task):
                task = send_message_response.root.result
                get_task_request = GetTaskRequest(
                    id=str(uuid4()),
                    params=TaskQueryParams(id=task.id)  # Use the taskId from the response,
                )

        get_task_response = await client.get_task(get_task_request, http_kwargs={"headers": headers})

        print("Get Task Response:")
        print(get_task_response.model_dump_json(indent=2, exclude_none=True))

        # --<-- [end:get task]


if __name__ == '__main__':
    import asyncio
    agent_url = '<enter-your-agent-url-here>' # e.g. https://your-logic-app-name.azurewebsites.net/api/Agents/WeatherAgent
    api_key = "<enter-your-api-key-here>" # e.g. the value of the Agent API key for your Logic App Agent

    asyncio.run(main(agent_url, api_key))
```

Now, let's break down the this sample code and understand how it was implemented.

### Step 1: Import the necessary modules from the A2A Python SDK

```python
import logging
from typing import Any
from uuid import uuid4
import httpx
from a2a.client import A2ACardResolver, A2AClient
from a2a.types import (
    AgentCard,
    Task,
    MessageSendParams,
    SendMessageRequest,
    SendMessageSuccessResponse,
    GetTaskRequest,
    TaskQueryParams,
    GetTaskSuccessResponse,
)
from a2a.utils.constants import (
    AGENT_CARD_WELL_KNOWN_PATH,
    EXTENDED_AGENT_CARD_PATH,
)
```

### Step 2: Passing in the Agent URL and Agent API key

Replace the **agent_url** and **api_key** with the Azure Logic Apps Agent URL and Agent API key seen in the Agent trigger

```python
if __name__ == '__main__':
    import asyncio
    
    agent_url = '<enter-your-agent-url-here>' # e.g. https://your-logic-app-name.azurewebsites.net/api/Agents/WeatherAgent
    api_key = "<enter-your-api-key-here>" # e.g. the value of the Agent API key for your Azure Logic App Agent

    asyncio.run(main(agent_url, api_key))
```

### Step 3: Initialize the A2A client

The A2A client is initialized using the agent URL and API key we passed into the function **initialize_a2a_client** function. This internally fetches the agent card from the Agent URL by appending the 'Well-Known' Agent card path **/.well-known/agent-card.json**

```python
async def initialize_a2a_client(httpx_client: httpx.AsyncClient, agent_url: str, api_key: str, logger: logging.Logger) -> A2AClient:
    resolver = A2ACardResolver(
        httpx_client=httpx_client,
        base_url=agent_url,
    )
    logger.info(
        f'Attempting to fetch public agent card from: {agent_url}{AGENT_CARD_WELL_KNOWN_PATH}'
    )
    headers = {
        'X-Api-Key': api_key
    }
    _public_card = (await resolver.get_agent_card(http_kwargs={"headers": headers}))

    logger.info('Successfully fetched public agent card:')
    
    logger.info(_public_card.model_dump_json(indent=2, exclude_none=True))
    logger.info('\nUsing PUBLIC agent card for client initialization.')
    client = A2AClient(httpx_client=httpx_client, agent_card=_public_card)
    logger.info('A2AClient initialized.')
    return client, headers
```

Sample output:

```json
{
  "capabilities": {
    "stateTransitionHistory": false,
    "streaming": true
  },
  "defaultInputModes": [
    "application/json"
  ],
  "defaultOutputModes": [
    "application/json"
  ],
  "description": "An agent that fetches the weather forecast for any given location",
  "name": "Weather Agent",
  "preferredTransport": "JSONRPC",
  "protocolVersion": "0.3.0",
  "skills": [
    {
      "description": "An agent that fetches the weather forecast for any given location",
      "id": "08584456976585663423",
      "name": "WeatherAgent",
      "tags": []
    }
  ],
  "url": "https://test-agent-app.azurewebsites.net/api/agents/WeatherAgent",
  "version": "08584456976585663423"
}
```

### Step 4: Send a message

This section internally uses the **message/send** API to send a message to the Azure Logic Apps conversational agent.

```python
# <-- [start:send message]

send_message_payload: dict[str, Any] = {
    'message': {
        'role': 'user',
        'parts': [
            {'kind': 'text', 'text': 'What is the weather like in Seattle?'}
        ],
        'messageId': uuid4().hex,
    },
}
request = SendMessageRequest(
    id=str(uuid4()), params=MessageSendParams(**send_message_payload)
)

send_message_response = await client.send_message(request, http_kwargs={"headers": headers})
print("Send Message Response:")
logger.info(send_message_response.model_dump_json(indent=2, exclude_none=True))

# --<-- [end:send message]
```

Sample output (Note that the agent returns a task object with a **submitted** status and the contextId here maps to the logic app workflow run Id):

```json
{
  "id": "a6c77e4f-18b2-4e9a-b242-cb0ee90e5cc0",
  "jsonrpc": "2.0",
  "result": {
    "contextId": "08584454976335162897442324792CU00",
    "id": "08584454976335169641388432536_08584454976335162897442324792CU00",
    "kind": "task",
    "status": {
      "state": "submitted",
      "timestamp": "8/25/2025 8:07:32 AM"
    }
  }
}
```

### Step 5: Polling for task and getting Agent response

This section internally uses the **tasks/get** API to get the task from the message we sent previously using the taskId from the agent response.

```python
# <-- [start:get task]

if isinstance(send_message_response.root, SendMessageSuccessResponse):
    if isinstance(send_message_response.root.result, Task):
        task = send_message_response.root.result
        get_task_request = GetTaskRequest(
            id=str(uuid4()),
            params=TaskQueryParams(id=task.id)  # Use the taskId from the response,
        )

get_task_response = await client.get_task(get_task_request, http_kwargs={"headers": headers})

print("Get Task Response:")
print(get_task_response.model_dump_json(indent=2, exclude_none=True))

# --<-- [end:get task]
```

Sample output:

We can see the agent returned the task object with the final assistant message: **Right now in Seattle, the weather is clear:\n\n- **Temperature**: 68°F (feels like 67°F)\n- **Humidity**: 70%\n- **Wind**: 2 mph\n- **Visibility**: 9.9 miles\n- **Cloud Cover**: Minimal (7%)\n- **UV Index**: Low (0)\n\nNo precipitation is expected for at least 2 hours.**

```json
{
  "id": "20f6ab40-bf90-45b0-a1aa-30e96d7a0af9",
  "jsonrpc": "2.0",
  "result": {
    "contextId": "08584454976335162897442324792CU00",
    "history": [
      {
        "contextId": "08584454976335162897442324792CU00",
        "kind": "message",
        "messageId": "4b23483dd98d43b78d82cbd4f1b4c780",
        "metadata": {
          "timestamp": "8/25/2025 8:07:36 AM"
        },
        "parts": [
          {
            "kind": "text",
            "text": "Right now in Seattle, the weather is clear:\n\n- **Temperature**: 68°F (feels like 67°F)\n- **Humidity**: 70%\n- **Wind**: 2 mph\n- **Visibility**: 9.9 miles\n- **Cloud Cover**: Minimal (7%)\n- **UV Index**: Low (0)\n\nNo precipitation is expected for at least 2 hours."
          }
        ],
        "role": "agent",
        "taskId": "08584454976335169641388432536_08584454976335162897442324792CU00"
      },
      {
        "contextId": "08584454976335162897442324792CU00",
        "kind": "message",
        "messageId": "e3f0c616b79344c4a7b74b221c7e7077",
        "metadata": {
          "timestamp": "8/25/2025 8:07:34 AM"
        },
        "parts": [
          {
            "kind": "text",
            "text": "What is the weather like in Seattle?"
          }
        ],
        "role": "user",
        "taskId": "08584454976335169641388432536_08584454976335162897442324792CU00"
      }
    ],
    "id": "08584454976335169641388432536_08584454976335162897442324792CU00",
    "kind": "task",
    "status": {
      "message": {
        "kind": "message",
        "messageId": "4b23483dd98d43b78d82cbd4f1b4c780",
        "metadata": {
          "timestamp": "8/25/2025 8:07:36 AM"
        },
        "parts": [
          {
            "kind": "text",
            "text": "Right now in Seattle, the weather is clear:\n\n- **Temperature**: 68°F (feels like 67°F)\n- **Humidity**: 70%\n- **Wind**: 2 mph\n- **Visibility**: 9.9 miles\n- **Cloud Cover**: Minimal (7%)\n- **UV Index**: Low (0)\n\nNo precipitation is expected for at least 2 hours."
          }
        ],
        "role": "agent"
      },
      "state": "completed",
      "timestamp": "8/25/2025 8:07:37 AM"
    }
  }
}
```

## Communicating with an Azure Logic Apps workflow that uses a OBO connections

This section shows how to use the [A2A Python SDK](https://github.com/a2aproject/a2a-python) to connect to an Azure Logic Apps agent using dynamic connections (OBO) as described in - [Add user context to tools](./04-add-user-context-to-tools.mdx).

Use this POST call to get the developer key:

``` http
POST https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/connections/{connectionName}/listDynamicConnectionKeys?api-version=2015-08-01-preview
```

> :::note
> This developer key is recommended for development use only. Configure Easy Auth and use the chat client for production purposes as described in the extension module -  [Add user context to tools](./04-add-user-context-to-tools.mdx).

In addition to the API key shown in the previous section, we need to pass in the developer key in the **x-ms-obo-userToken** header to communicate with dynamic connections.

Replace the **developer_api_key** with the developer API key we got in response to the above POST call.

```python
import logging
from typing import Any
from uuid import uuid4
import httpx
from a2a.client import A2ACardResolver, A2AClient
from a2a.types import (
    AgentCard,
    Task,
    MessageSendParams,
    SendMessageRequest,
    SendMessageSuccessResponse,
    GetTaskRequest,
    TaskQueryParams,
    GetTaskSuccessResponse,
)
from a2a.utils.constants import (
    AGENT_CARD_WELL_KNOWN_PATH,
)

async def initialize_a2a_client(httpx_client: httpx.AsyncClient, agent_url: str, api_key: str, developer_api_key: str, logger: logging.Logger) -> A2AClient:
    resolver = A2ACardResolver(
        httpx_client=httpx_client,
        base_url=agent_url,
    )
    logger.info(
        f'Attempting to fetch public agent card from: {agent_url}{AGENT_CARD_WELL_KNOWN_PATH}'
    )
    headers = {
        'X-Api-Key': api_key,
        'x-ms-obo-userToken': "Key " + developer_api_key
    }
    _public_card = (await resolver.get_agent_card(http_kwargs={"headers": headers}))

    logger.info('Successfully fetched public agent card:')
    
    logger.info(_public_card.model_dump_json(indent=2, exclude_none=True))
    logger.info('\nUsing PUBLIC agent card for client initialization.')
    client = A2AClient(httpx_client=httpx_client, agent_card=_public_card)
    logger.info('A2AClient initialized.')
    return client, headers

async def main(agent_url: str, api_key: str, developer_api_key: str) -> None:
    # Configure logging to show INFO level messages
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)  # Get a logger instance

    async with httpx.AsyncClient() as httpx_client:

        # Initialize the A2A client
        client, headers = await initialize_a2a_client(httpx_client, agent_url, api_key, developer_api_key, logger)

        # <-- [start:send message]

        send_message_payload: dict[str, Any] = {
            'message': {
                'role': 'user',
                'parts': [
                    {'kind': 'text', 'text': 'What is the weather like in Seattle? Send it over email as well.'}
                ],
                'messageId': uuid4().hex,
            },
        }
        request = SendMessageRequest(
            id=str(uuid4()), params=MessageSendParams(**send_message_payload)
        )

        send_message_response = await client.send_message(request, http_kwargs={"headers": headers})
        print("Send Message Response:")
        logger.info(send_message_response.model_dump_json(indent=2, exclude_none=True))

        # --<-- [end:send message]

        await asyncio.sleep(5)

        # <-- [start:get task]

        if isinstance(send_message_response.root, SendMessageSuccessResponse):
            if isinstance(send_message_response.root.result, Task):
                task = send_message_response.root.result
                get_task_request = GetTaskRequest(
                    id=str(uuid4()),
                    params=TaskQueryParams(id=task.id)  # Use the taskId from the response,
                )

        get_task_response = await client.get_task(get_task_request, http_kwargs={"headers": headers})

        print("Get Task Response:")
        print(get_task_response.model_dump_json(indent=2, exclude_none=True))

        # --<-- [end:get task]


if __name__ == '__main__':
    import asyncio
    developer_api_key = '<enter-your-developer-key-here>' # e.g the value of the developer key returned by the POST call mentioned in this section. 
    agent_url = '<enter-your-agent-url-here>' # e.g. https://your-logic-app-name.azurewebsites.net/api/Agents/WeatherAgent
    api_key = "<enter-your-api-key-here>" # e.g. the value of the Agent API key for your Logic App Agent
    asyncio.run(main(agent_url, api_key, developer_api_key))
```

When interacting with the tool for the first time you would get an **auth-required** response from the agent in the **tasks/get** API. You can click on the link to authenticate and continue to send messages to the agent.

Sample response:

```json
{
  "id": "980f7753-208f-4042-a9a6-69c6820638b1",
  "jsonrpc": "2.0",
  "result": {
    "contextId": "08584446506408000428674715049CU00",
    "history": [
      {
        "contextId": "08584446506408000428674715049CU00",
        "kind": "message",
        "messageId": "a922d27a6a1f4e91854028364a31b944",
        "metadata": {
          "timestamp": "9/4/2025 3:24:11 AM"
        },
        "parts": [
          {
            "kind": "text",
            "text": "Please authenticate using links: [\r\n  {\r\n    \"ApiDetails\": {\r\n      \"ApiDisplayName\": \"Office 365 Outlook\",\r\n      \"ApiIconUri\": \"https://conn-afd-prod-endpoint-bmc9bqahasf3grgk.b01.azurefd.net/v1.0.1763/1.0.1763.4311/office365/icon.png\",\r\n      \"ApiBrandColor\": \"#0078D4\"\r\n    },\r\n    \"Link\": \"https://logic-apis-northeurope.consent.azure-apim.net/login?data=eyJMb2dpbklkIjoibG9naWMtYXBpcy1ub3J0aGV1cm9wZV9vZmZpY2UzNjVfdG9rZW4iLCJTZXNzaW9uSWQiOiIiLCJMb2dSdW50aW1lUG9saWN5SWQiOm51bGwsIkxvZ0Nvbm5lY3Rpb25JZCI6IjU4MmM1MTY5ZDA5NzQyOWE5MzIzY2FjNTlmYTE5MTIxIiwiTG9nQ29ubmVjdG9ySWQiOiJvZmZpY2UzNjUiLCJMb2dFbnZpcm9ubWVudElkIjoiOWQ1MWQxZmZjOWY3NzU3MiIsIkxvZ0FjY291bnROYW1lIjoibG9naWMtYXBpcy1ub3J0aGV1cm9wZSIsIkV4cGlyYXRpb25UaW1lIjoiMjAyNS0wOS0wNFQwNDoyNDoxMS4yNDEzODQ3WiIsIkRhdGEiOiIrVWMwMFAvV1g5TDRZOCtjTmV6akQ5dGFPamgreUtBanE1cEtnaXBCN01jUUFJR3AvcjNaTEJTcGNFajRITFRpdWtEdTdQUkZoWThQOEx2KzlTdTd5a05RaTE1V1RYY0JpSGpBbkcvN1pibTEvSjNOeFhmK1phaVlaOW1SeWZJdG5DSGxRWndrY0VoNWlYOXBMVDdhTFF3SlRId1RFY1RJRDVOUnA0bHZRS2xUdlgrTlRlREk4MlVUR3FEZEFNcWNkYUd6UWhKaGZQcUg2cjB2MCtWcC9tUW91MXNCeENzVFJZdkQ2NFVkVGxoeFR3VnbmloakxHWmVwOVdRR3VGMmY0ZTN2b2dLZEVOVW5aV2JuN3p5cDZPMXpwNnNKSGoxN3pRR2pXZWhxSUo3d01XT3pyS2RidVFGRy9WVDFWNmVZUjhGTU45dkdMWkZnN0lHNHBhendRZmFvVlJSdkc4SEUxYUdPQjlvT09PcVFZZkx0NlBwaHdDQ3p4ZWhtNmROSEkvUGY2MThIc0MwVEIrMThLckJSZnowcDVyYkxhOC9uUjA1ay83eG1vYU9zVUVTSkdVT3hxbUJHWXVOdnBDbXZkZ0JsZE02cHVUeDFiQnhCOVV5R1JFUmtXUGRsMnBETnJTbXZ1MER6SExPTjVUaEtIUmsvSEI3VFdZRzloanI5NWRITmN2dFZRWDAza21CSit6TW1TZ1Y0cXl6c3djeVVsTzBaODBaRU5rTmFGSFFIbHdrSktVZnd4UjA5c29hbmJvZVFEQ3VzSmY0S3BpeEE1S1JNL1RnNmVhSVBKaU16cjhSMnF0cUZPMjlvQmJURk5vQjhpVVZrb1RZNmZuVTFzaHJPNmhjMklFSUdwaS9CbCszWlhkU3FJWStFcVhLQnVKVWZJT0VaZ1JKcUI5Ulh3eWZCVFdqVE40WVNzSHFUWExGZUdjV3UwNnB0dnBHaEczbCsvL29iSzJuREhVMWtTVkpXMm1JeWd4emVFL3UwZDB4VFZDVW1Wb1pyNW9FVGt0Wk9PVkQ3NWpKWXBlYk9YcVhUUy81YXU1dkwrNDdSQzMrT2thK01WOUxPd3d5UDAxU3p2TjV1UVlvYkRkZTQ4eVV3bmtnN2FjVWFYRUFFNzZVcjhmdjBzVDZEcHI5V3orL3o4Z2x0REg1bzY1U1NWQnp2RFgvaUVhTzNNeWVyaGFVMG51UXVuVEFJR0NGK2RyTkNuU0NodkZxNmZzR05sNFdtNEFSRFNXcFN0VlJ5amhTSEF6S0pYeTRqVjhjUk1rbXptSE43UEFCNDBIL0RENis0S1JxNHUwNmtlZnJCQVhTQ0lYMjZPVzJ1RFZPeHkxNHVwZkEwVzhlZ3BDMzBSK0Y5N3F0UXFuWkxDU0dwWnRSbWRMUWRXMDBjYUJwcTE0SXZLWTRJdlZCTUVHIn0\",\r\n    \"FirstPartyLoginUri\": null,\r\n    \"DisplayName\": null,\r\n    \"Status\": \"Unauthenticated\"\r\n  }\r\n]."
          }
        ],
        "role": "agent",
        "taskId": "08584446506409532476968735089_08584446506408000428674715049CU00"
      },
      {
        "contextId": "08584446506408000428674715049CU00",
        "kind": "message",
        "messageId": "16dce52f30a349e0b36f6eac3b435fbd",
        "metadata": {
          "timestamp": "9/4/2025 3:24:11 AM"
        },
        "parts": [
          {
            "kind": "text",
            "text": "What is the weather like in Seattle? Send it over email as well."
          }
        ],
        "role": "user",
        "taskId": "08584446506409532476968735089_08584446506408000428674715049CU00"
      }
    ],
    "id": "08584446506409532476968735089_08584446506408000428674715049CU00",
    "kind": "task",
    "status": {
      "message": {
        "kind": "message",
        "messageId": "a922d27a6a1f4e91854028364a31b944",
        "metadata": {
          "timestamp": "9/4/2025 3:24:11 AM"
        },
        "parts": [
          {
            "kind": "text",
            "text": "Please authenticate using links: [\r\n  {\r\n    \"ApiDetails\": {\r\n      \"ApiDisplayName\": \"Office 365 Outlook\",\r\n      \"ApiIconUri\": \"https://conn-afd-prod-endpoint-bmc9bqahasf3grgk.b01.azurefd.net/v1.0.1763/1.0.1763.4311/office365/icon.png\",\r\n      \"ApiBrandColor\": \"#0078D4\"\r\n    },\r\n    \"Link\": \"https://logic-apis-northeurope.consent.azure-apim.net/login?data=eyJMb2dpbklkIjoibG9naWMtYXBpcy1ub3J0aGV1cm9wZV9vZmZpY2UzNjVfdG9rZW4iLCJTZXNzaW9uSWQiOiIiLCJMb2dSdW50aW1lUG9saWN5SWQiOm51bGwsIkxvZ0Nvbm5lY3Rpb25JZCI6IjU4MmM1MTY5ZDA5NzQyOWE5MzIzY2FjNTlmYTE5MTIxIiwiTG9nQ29ubmVjdG9ySWQiOiJvZmZpY2UzNjUiLCJMb2dFbnZpcm9ubWVudElkIjoiOWQ1MWQxZmZjOWY3NzU3MiIsIkxvZ0FjY291bnROYW1lIjoibG9naWMtYXBpcy1ub3J0aGV1cm9wZSIsIkV4cGlyYXRpb25UaW1lIjoiMjAyNS0wOS0wNFQwNDoyNDoxMS4yNDEzODQ3WiIsIkRhdGEiOiIrVWMwMFAvV1g5TDRZOCtjTmV6akQ5dGFPamgreUtBanE1cEtnaXBCN01jUUFJR3AvcjNaTEJTcGNFajRITFRpdWtEdTdQUkZoWThQOEx2KzlTdTd5a05RaTE1V1RYY0JpSGpBbkcvN1pibTEvSjNOeFhmK1phaVlaOW1SeWZJdG5DSGxRWndrY0VoNWlYOXBMVDdhTFF3SlRId1RFY1RJRDVOUnA0bHZRS2xUdlgrTlRlREk4MlVUR3FEZEFNcWNkYUd6UWhKaGZQcUg2cjB2MCtWcC9tUW91MXNCeENzVFJZdkQ2NFVkVGxoeFR3VnbmloakxHWmVwOVdRR3VGMmY0ZTN2b2dLZEVOVW5aV2JuN3p5cDZPMXpwNnNKSGoxN3pRR2pXZWhxSUo3d01XT3pyS2RidVFGRy9WVDFWNmVZUjhGTU45dkdMWkZnN0lHNHBhendRZmFvVlJSdkc4SEUxYUdPQjlvT09PcVFZZkx0NlBwaHdDQ3p4ZWhtNmROSEkvUGY2MThIc0MwVEIrMThLckJSZnowcDVyYkxhOC9uUjA1ay83eG1vYU9zVUVTSkdVT3hxbUJHWXVOdnBDbXZkZ0JsZE02cHVUeDFiQnhCOVV5R1JFUmtXUGRsMnBETnJTbXZ1MER6SExPTjVUaEtIUmsvSEI3VFdZRzloanI5NWRITmN2dFZRWDAza21CSit6TW1TZ1Y0cXl6c3djeVVsTzBaODBaRU5rTmFGSFFIbHdrSktVZnd4UjA5c29hbmJvZVFEQ3VzSmY0S3BpeEE1S1JNL1RnNmVhSVBKaU16cjhSMnF0cUZPMjlvQmJURk5vQjhpVVZrb1RZNmZuVTFzaHJPNmhjMklFSUdwaS9CbCszWlhkU3FJWStFcVhLQnVKVWZJT0VaZ1JKcUI5Ulh3eWZCVFdqVE40WVNzSHFUWExGZUdjV3UwNnB0dnBHaEczbCsvL29iSzJuREhVMWtTVkpXMm1JeWd4emVFL3UwZDB4VFZDVW1Wb1pyNW9FVGt0Wk9PVkQ3NWpKWXBlYk9YcVhUUy81YXU1dkwrNDdSQzMrT2thK01WOUxPd3d5UDAxU3p2TjV1UVlvYkRkZTQ4eVV3bmtnN2FjVWFYRUFFNzZVcjhmdjBzVDZEcHI5V3orL3o4Z2x0REg1bzY1U1NWQnp2RFgvaUVhTzNNeWVyaGFVMG51UXVuVEFJR0NGK2RyTkNuU0NodkZxNmZzR05sNFdtNEFSRFNXcFN0VlJ5amhTSEF6S0pYeTRqVjhjUk1rbXptSE43UEFCNDBIL0RENis0S1JxNHUwNmtlZnJCQVhTQ0lYMjZPVzJ1RFZPeHkxNHVwZkEwVzhlZ3BDMzBSK0Y5N3F0UXFuWkxDU0dwWnRSbWRMUWRXMDBjYUJwcTE0SXZLWTRJdlZCTUVHIn0\",\r\n    \"FirstPartyLoginUri\": null,\r\n    \"DisplayName\": null,\r\n    \"Status\": \"Unauthenticated\"\r\n  }\r\n]."
          }
        ],
        "role": "agent"
      },
      "state": "auth-required",
      "timestamp": "9/4/2025 3:24:11 AM"
    }
  }
}
```

## Related content
- [Latest A2A protocol Specification](https://a2a-protocol.org/latest/specification/)
- [A2A Python SDK reference](https://a2a-protocol.org/latest/sdk/python/api/)
- [Module 01 — Create First Conversational Agent](./01-create-first-conversational-agent.mdx)
- [Module 03 - Connect your tools to external services](./03-connect-tools-external-services.md)
