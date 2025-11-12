---
title: 09 - Add the 'ServiceNow Create Incident' tool to your agent
description: Add the ServiceNow Create Incident workflow as a callable tool in the Agent Loop.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 10/12/2025
author: leonglaz
ms.author: leonglaz
---

In this module we will take the ServiceNow Create Incident workflow and add it as a tool in our Agent Loop workflow.


1. Return to the list of workflows in the Logic Apps by clicking on the Workflows link at the top of the page

    ![Return to workflows](./images/09_01_return_to_workflows.png "return to workflows")

1. Open the `demo-conversational-agent` workflow

    ![Open Agent Workflow](./images/09_02_open_agent_workflow.png "open agent workflow")

1. Add a new tool.
    - Click on the `+`

        ![Add a tool](./images/09_04_add_a_tool.png "add a tool")

1. Search and select the `Call workflow in this logic app`

    ![Add Call workflow](./images/09_05_add_action_call_workflow_in_this_logic_app.png "add call workflow")

1. Configure the **Call workflow in this logic app** action
    - **Workflow Name** - `tool-ServiceNow-CreateIncident`

    ![Configure Call Workflow](./images/09_06_configure_call_workflow.png "configure call workflow")

1. Configure the Tool action.
    - **NOTE** The way you name your tool and provide a description has a significant impact on your Agent Loop (and LLM) will discover and call your particular tool. Provide unique and descriptive terms to improve accuracy during runtime. 
    - Rename the tool to `Create Service Now Incident`
    - **Description:** `This tool will log a ServiceNow Incident`
    - **Agent Parameters**
        
        for each agent parameter click `+ Create Parameter` 
        - **Name:** `Assignment Group`

          **Type:** `String`

          **Description:** `The Assignment Group in ServiceNow that the ticket should be assigned to`

        - **Name:** `Description`

          **Type:** `String`

          **Description:** `The user provided description of the issue being logged`    

        - **Name:** `ResolutionSteps`

          **Type:** `String`

          **Description:** `The steps recommended to resolve the incident`                       

        - **Name:** `Severity`

          **Type:** `Integer`

          **Description:** `The Severity of the incident`      

          ![Configure Tool](./images/09_07_configure_tool.png "configure tool")

1. Configure the inputs parameters for the call to the logic app.

    **NOTE** when you select a parameter to configure you will now see a third source for mapping your inputs. The agent indicates a parameter that the agent can provide.

    ![Agent Parameters](./images/09_08_configure_assignment_group.png "agent parameters")

    - **Assignment Group:** (agent parameter) `Agent Parameters`-> `AssignmentGroup`

      ![Assignment Group Agent Parameter](./images/09_08_configure_assignment_group_selected.png "assignment group agent parameter")
    
    - **Description:** (agent parameter) `Agent Parameters`-> `AssignmentGroup`
    - **FailureDateTime:** `utcNow()`
    - **ResolutionSteps:** (agent parameter) `Agent Parameters`-> `ResolutionSteps`
    - **Severity:** (agent parameter) `Agent Parameters`-> `Severity`

    ![Configure Call Workflow Parameters](./images/09_10_configure_call_workflow_parameters.png "configure call workflow parameters")

1. Save your workflow

    ![Save Workflow](./images/09_11_save_workflow.png "save workflow")

## Test your agent

1. Click `Chat` to start your workflow and initiate the agent session.

    ![Chat Workflow](./images/09_12_run_workflow.png "chat workflow")

    This will open the chat interface where you will see list of all your previous conversations with this agent.

    Let's create a new chat and start the process over again:
    Click `+ New Chat`


1. Enter your issue for the agent to take action on:

    Similar to the last execution, the agent has first presented its system instructions and the initial user instruction has been provided resulting in the agent providing more detailed instructions on what it requires and what steps it will take. In the following steps we will provide a similar prompt to the one we tested in [Module 7 - Create Agent Loop Workflow](07_create_agent_loop_workflow.md) but now the agent will have a tool enabling it to log the ServiceNow Incident on behalf of the user.

    - Enter the following prompt:
      ```
      my database mysqldev001 appears to be offline  
      ```
        ![Prompt Issue Description](./images/09_15_workflow_run_user_prompt_1.png "prompt issue description")

    As per the system instructions, the Assignment Group is required to proceed.
    - Enter the `Database` in the chat

    Let's review the response....
    - First, the agent details the step by step plan of what it will do

      ![Agent Response - Part 1 - The Plan](./images/09_15_workflow_run_user_prompt_2_plan.png "agent response part1 the plan")

    - Next, the agent retrieves the operational run book, locates the corresponding issue and presents back a more detailed plan with step by step resolution instructions, estimated resolution time and severity 

      ![Agent Response - Part 2 - Operational Runbook Details](./images/09_15_workflow_run_user_prompt_2_runbook_details.png "agent response part 2 operational runbook details")

    - Finally, the agent will call ServiceNow and create the incident ticket and return the Incident Ticket Number, details that will be included in the ticket and finishes off by providing a list of next steps.

      ![Agent Response - Part 3 - ServiceNow Incident](./images/09_15_workflow_run_user_prompt_2_servicenow_incident_creation.png "agent response part 3 servicenow incident")

1. Validate your Incident in ServiceNow.
  - Navigate to your ServiceNow developer portal
  - Use the Incident Ticket Number from the Agent's response to search for the incident in ServiceNow

    ![ServiceNow Incident Details](./images/09_17_servnicenow_incident_details.png "servicenow incident details")

> **Tip:** If you do not see the **Description** field in your ServiceNow incident, you may need to configure the Incident Properties in your ServiceNow instance to display it. 
