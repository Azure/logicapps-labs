---
title: 11 - Add the 'ServiceNow Update Incident' tool to your agent
description: Add the ServiceNow Update Incident workflow as a tool for logging work notes via the Agent Loop.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 10/12/2025
author: leonglaz
ms.author: leonglaz
---

In this module we will take the ServiceNow Update Incident workflow and add it as a tool in our Agent Loop workflow.


1. Return to the list of workflows in the Logic Apps by clicking on the Workflows link at the top of the page

    ![Return to workflows](./images/11_01_return_to_workflows.png "return to workflows")

1. Open the `demo-conversational-agent` workflow

    ![Open Agent Workflow](./images/11_02_open_agent_workflow.png "open agent workflow")

1. Add a new tool.
    - Click on the `+`

        ![Add a tool](./images/11_04_add_a_tool.png "add a tool")

1. Search and select the `Call workflow in this logic app`

    ![Add Call workflow](./images/11_05_add_action_call_workflow_in_this_logic_app.png "add call workflow")

1. Configure the **Call workflow in this logic app** action
    - Rename action to `tool-update-servicenow-incident`
    - **Workflow Name** - `tool-ServiceNow-UpdateIncident`
    - click **Show all**

    ![Configure Call Workflow](./images/11_06_configure_call_workflow.png "configure call workflow")

1. Configure the Tool action
    - Rename the tool to `Update Service Now Incident`
    - **Description:** `This tool will update a ServiceNow Incident`
    - **Agent Parameters**
        
        for each agent parameter click `+ Create Parameter` 
        - **Name:** `Notes`

          **Type:** `String`

          **Description:** `Notes to be added to the incident`

        - **Name:** `Ticket Number`

          **Type:** `String`

          **Description:** `The ServiceNow Ticket Number`


          ![Configure Tool](./images/11_07_configure_tool.png "configure tool")

1. Configure the inputs parameters for the call to the logic app.
    - **TicketNumber:** `@{agentParameters('Ticket Number')}`
    - **Notes:** `@{agentParameters('Notes')}`

    ![Configure Call Workflow Parameters](./images/11_10_configure_call_workflow_parameters.png "configure call workflow parameters")

1. Save your workflow

    ![Save Workflow](./images/09_11_save_workflow.png "save workflow")

## Test your agent

1. Click `Chat` switch back to the Agent chat session.

    ![Chat Workflow](./images/09_12_run_workflow.png "chat workflow")


1. This will open the Agent chat component. Note that all the previous chat sessions are present. Start a new chat session by clicking `+ New Chat`

    ![Chat History](./images/11_11_chat_history_session.png "Chat history")


1. Enter the your issue for the agent to action:

    In this session we will:
    - Ask the agent to help coordinate the resolution for their issue
    - The agent will 
        - retrieve the Operation Run and find the corresponding entry
        - will log the incident in ServiceNow
    - We provide updates on our progress of the Incident
    - The agent will
        - Update work notes in ServiceNow

    1.  Enter the following prompt to have the agent log the incident
        ```
        my database mysqldev001 appears to be offline  
        ```
      
        ![Prompt 1 Response - Incident Created](./images/11_12_prompt_response_incident_created.png "prompt 1 response incident created")

        (**note** the agent may prompt you for the assignment group or the date the incident occurred.)
   
        ![Prompt 1 Response - Incident Created](./images/11_12_prompt_response_incident_created_2.png "prompt 1 response incident created")

    1. Enter the following prompt to have the agent update the ticket with the work notes.
        ```
        Database team has provided an update that the database has been rebooted and functionality should be restored in 15 mins
        ```
        (**note** the agent has leveraged the Update ServiceNow Incident Tool to update our Incident with the work notes)


        ![Prompt 2 Response - Incident Updated](./images/11_13_prompt_response_incident_updated.png "prompt 2 incident updated")

1. Validate your Incident in ServiceNow.
  - Navigate to your ServiceNow developer portal
  - Use the Incident Ticket Number from the Agent's response to search for the incident in ServiceNow
   - Note the update has been captured in the work notes for the incident.
    ![ServiceNow Updated Incident](./images/11_14_servicenow_updated_incident.png "servicenow updated incident")
