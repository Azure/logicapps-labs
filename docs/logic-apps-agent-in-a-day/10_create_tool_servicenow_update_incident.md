---
title: 10 - Create the 'ServiceNow Update Incident' tool
description: Build a stateful workflow tool to update ServiceNow incidents and enable agent work note recording.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 10/12/2025
author: leonglaz
ms.author: leonglaz
---

In this module we will create a stateful workflow to update an existing ServiceNow incident and prepare it for agent use.


## Create the Stateful Workflow
1. Search for and navigate to the Logic Apps service

    ![Search and Navigate to the Logic Apps Service](./images/10_01_search_bar_logic_apps.png "search and navigate to logics apps")


1. Open the Logic App created earlier 

    ![Open Logic App](./images/10_02_logic_apps_list.png "open logic app")

1. Create a new workflow
    - Click `Workflows -> Workflows` from the menu on the left
    - Click `+ Add -> Add`

      ![Create New Workflow](./images/10_03_create_new_workflow.png "create new workflow")

1. Create a new stateful workflow with:
    
    - **Workflow name:** `tool-ServiceNow-UpdateIncident`
    - Select the radio button for the `Stateful` workflow type
    - Click `Create`

    

1. Open the workflow visual editor by clicking on the `tool-ServiceNow-UpdateIncident` link (if the workflow isn't automatically opened after the create completes)

    ![Open Workflow](./images/10_05_open_workflow.png "Open Workflow" )

## Configure Workflow 

<details>
<summary>
    🚀 <b>Create Workflow using existing workflow.json</b> (expand for details)

  - 📄 -  provides a preconfigured workflow definition
  - 🕐 - This option saves you time creating the tools allowing more time to explore and interact with the agent.
</summary>

## Configure Worflow using existing workflow.json
1. Select the `Code` Option in the **Tools**

    ![Tools - Code](./images/10_01_01_tools_code_menu.png "tools code menu")

1. Paste the contents of the `workflow.json` file into the editor

 
    ```JSON
    {
        "definition": {
            "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
            "contentVersion": "1.0.0.0",
            "actions": {
                "List_Records": {
                    "type": "ApiConnection",
                    "inputs": {
                        "host": {
                            "connection": {
                                "referenceName": "service-now"
                            }
                        },
                        "method": "get",
                        "path": "/api/now/v2/table/@{encodeURIComponent('incident')}",
                        "queries": {
                            "sysparm_display_value": false,
                            "sysparm_exclude_reference_link": true,
                            "sysparm_query": "number=@{triggerBody()?['TicketNumber']}"
                        }
                    },
                    "runAfter": {}
                },
                "Update_Record": {
                    "type": "ApiConnection",
                    "inputs": {
                        "host": {
                            "connection": {
                                "referenceName": "service-now"
                            }
                        },
                        "method": "put",
                        "body": {
                            "state": "2",
                            "work_notes": "@triggerBody()?['Notes']"
                        },
                        "path": "/api/now/v2/table/@{encodeURIComponent('incident')}/@{encodeURIComponent(first(body('List_Records')?['result'])['sys_id'])}",
                        "queries": {
                            "sysparm_display_value": false,
                            "sysparm_exclude_reference_link": true
                        }
                    },
                    "runAfter": {
                        "List_Records": [
                            "SUCCEEDED"
                        ]
                    }
                },
                "Response": {
                    "type": "Response",
                    "kind": "Http",
                    "inputs": {
                        "statusCode": 200,
                        "body": {
                            "status": "Ticket {@{triggerBody()?['TicketNumber']}} has been updated successfully"
                        }
                    },
                    "runAfter": {
                        "Update_Record": [
                            "SUCCEEDED"
                        ]
                    }
                }
            },
            "outputs": {},
            "triggers": {
                "When_an_HTTP_request_is_received": {
                    "type": "Request",
                    "kind": "Http",
                    "inputs": {
                        "schema": {
                            "type": "object",
                            "properties": {
                                "TicketNumber": {
                                    "type": "string"
                                },
                                "Notes": {
                                    "type": "string"
                                }
                            }
                        }
                    }
                }
            }
        },
        "kind": "Stateful"
    }
    ```


1. Click the `Save` button to save the changes to the workflow

    ![Save Changes](./images/10_01_02_save_code.png "save changes")

    The follwoing message will appear once the changes have been successfully saved:
    
    ![Save Success](./images/10_01_03_save_success_status.png "save success")

1. Click on the `Designer` option in the **Tools** menu to review the workflow using the designer.

    ![Review Workflow using Designer](./images/10_01_04_workflow_designer_review.png "review workflow using designer")
</details>

<details>
<summary>
    📋 <b>Create Workflow using the Logic Apps Workflow Designer</b>  (expand for details)
    
- ✅ - provides step by step instructions for configuring the workflow using the designer. 
- ✏️ - Use this option if you want more practice using the Logic Apps Designer 
</summary>

## Configure Workflow using designer
1. Configure the workflow trigger to accept an HTTP Request
    - Click on `Add Trigger`
    - Select the `Request` action located in the **Built-in tools** group

        ![Add Trigger - Request Action](./images/10_06_add_trigger_request_action.png "add trigger request action")
        
    - Select the `When a HTTP request is received`

        ![Select Action When a HTTP Request is Received](./images/10_07_add_action_when_a_http_request_is_received.png "select when a HTTP request is received")

1. Configure the `When a HTTP request is received` action:
    - **Request Body JSON Schema**
        ```JSON
       {
            "type": "object",
            "properties": {
                "TicketNumber": {
                    "type": "string"
                },
                "Notes": {
                    "type": "string"
                }
            }
       }
       ```

1. Look up the internal identifier for the **Incident** in ServiceNow

    - Add a new action. Click `+ Add an action`

        ![Add an action](./images/10_08_add_a_action.png "add a action")

    - Select the `ServiceNow - List Records` action

        ![Select Action ServiceNow List Records](./images/10_09_action_servicenow_list_records.png "servicenow list records")

1. Configure the List Records Action as follows
    - **Record Type:** `Incident`
    - **Advanced Parameters** (click `Show all`)
    - **Query:** `number=@{triggerBody()?['TicketNumber']}`

        (**note:** notice that the ServiceNow connection was automatically selected for the action)

        ![ServiceNow List Action Configuration](./images/10_10_servicenow_list_records_configuration.png "servicenow list records configuration")

1. Add the **Update Record** action to update the work notes on the incident in ServiceNow
    - Click on the `+` -> `Add an Action`
    - Search for `ServiceNow` Connector and select the `Update Record` Action

        ![ServiceNow Update Action](./images/10_11_search_action_sevicenow_update_activity.png "servicenow update action")

1. Configure the **Update Record** action
    - **Record Type:** `Incident`
    - **System ID:** *(using the expression (fx) editor)* `first(body('List_Records')?['result'])['sys_id']`
    - **State:** *(Advanced Parameter)* `2`
    - **Work Notes:** *(Advanced Parameter)* `@{triggerBody()?['Notes']}`

        ![ServiceNow Update Action Config](./images/10_12_update_activity_config.png "servicenow update action config")

1. Add the **Response** action to return a status message to the calling process
    - Click on the `+` -> `Add an Action`
    - Search for and select the `Response` action

      ![Search Action Response](./images/10_11_search_activity_response.png "search action response")

1. Configure the **Response** action
    - **Body:** 
        ```
        {
            "status": "Ticket {@{triggerBody()?['TicketNumber']}} has been updated successfully"
        }
        ```
      ![Response Action Config](./images/10_13_response_activity_config.png "response action config")

1. Save your workflow

    ![Save Workflow](./images/10_14_save_workflow.png "save workflow")
</details>