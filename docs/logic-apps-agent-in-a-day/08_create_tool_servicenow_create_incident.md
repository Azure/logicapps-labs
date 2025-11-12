---
title: 08 - Create the 'ServiceNow Create Incident' tool
description: Build a stateful workflow tool that creates ServiceNow incidents for agent-driven automation.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 10/12/2025
author: leonglaz
ms.author: leonglaz
---

In this module we will create a stateful workflow to create a ServiceNow incident. Our Agent Loop will leverage this workflow as a tool when processing user requests.


## Create Stateful Workflow

1. Create a new workflow:

    - Navigate to the  **Workflows -> Workflows**  section of your Logic app
    - Click `+ Add -> Add`

        ![Add Workflow](./images/08_01_create_new_workflow.png "add workflow")

2. Create a new stateful workflow with:
    
    - **Workflow name:** `tool-ServiceNow-CreateIncident`
    - Select the radio button for the `Stateful` workflow type
    - Click `Create`

    ![Create Stateful Workflow](./images/08_02_create_new_stateful_workflow.png "create new stateful workflow")

3. Open the workflow visual editor by clicking on the `tool-ServiceNow-CreateIncident` link

    ![Open Workflow](./images/08_03_open_workflow_tool_create_service_now_incident.png "Open Workflow" )

## Configure Workflow
1. Configure the workflow trigger to accept an HTTP Request
    - Click on `Add Trigger`
    - Select the `Request` action located in the **Built-in tools** group

        ![Add Trigger - Request Action](./images/08_04_add_action_when_a_http_request_is_received.png "add trigger request action")
        
    - Select the `When a HTTP request is received`

        ![Select Action When a HTTP Request is Received](./images/08_05_add_trigger_request_action.png "select when a HTTP request is received")

1. Configure the `When a HTTP request is received` action:
    - **Request Body JSON Schema**
        ```JSON
        {
            "type": "object",
            "properties": {
                "AssignmentGroup": {
                "type": "string"
                },
                "Description": {
                "type": "string"
                },
                "FailureDateTime": {
                "type": "string"
                },
                "ResolutionSteps": {
                "type": "string"
                },
                "Severity": {
                "type": "string"
                }
            }
        } 
       ```

1. Look up the internal identifier for the **Assignment Group** in ServiceNow. The Assignment Group is the group of the team that will be responsible for resolving the particular incident. By assigning, this value during ticket creation, we can ensure that it is assigned appropriately.

    - Add a new action. Click `+ Add an action`

        ![Add an action](./images/08_07_add_a_action.png "add a action")

    - Select the `ServiceNow - List Records` action

        ![Select Action ServiceNow List Records](./images/08_08_action_servicenow_list_records.png "servicenow list records")

1. Configure the `ServiceNow - List Records` action. 

    - Configure the Connection:
        - **Connection Name:** `connServiceNowDev`
        - **Authentication Type:** `Use Oauth2`
        - **Instance Name:**  [obtained from Module 2]
            - example: `devXXXXXX` 
            - can also be found in the URL of your developer instance https://[instance name].service-now.com
    - **ClientId:**  [obtained from Module 2 - ]
            - example: 924168e8304a2210cc58c3f34c9b62f3
        - Click `Sign in` 

        ![Configure ServiceNow Connection](./images//08_09_servicenow_connection_configuration.png)

    - **NOTE** you **may** receive the following error. 

        ![ServiceNow Connection Error - Invalid Redirect URI](./images/08_10_servicenow_connection_error_invalid_redirect_uri.png "servicenow connection error invalid redirect uri")

        If you receive this error you will need to:
        - Copy the URL into a text editor
        - note the `redirect_uri` parameter in the query string  
            - redirect_uri=https%3a%2f%2flogic-apis-canadacentral.consent.azure-apim.net%2fredirect
        - convert the URL Encoded ASCII characters back as follows
            - Replace %3a with :
            - Replace %2f with /
        - in the above example we would have resolved to https://logic-apis-canadacentral.consent.azure-apim.net/redirect 

            - Update the Application Registration entry created in the [Module 4 - Prerequisites - ServiceNow setup](04_servicenow_dev_sandbox.md).
        Add the Redirect URL

        ![ServiceNow Connection Error - Invalid Redirect URI](./images/08_10_servicenow_connection_error_invalid_redirect_uri.png "servicenow connection error invalid redirect uri")

    - Close the browser popup window

    - Click the `Sign In` button  again 
        
        **Note** please check for errors in the upper right hand corner of your browser. Some browsers may block popups.
    
        ![ServiceNow Connection - Sign In](./images/08_11_servicenow_connection_sign_in_after_error.png "service now connection sign in")
    
1. Click `Allow` granting Logic Apps permission to connect to your ServiceNow instance 

    ![Service Now Grant Permissions](./images/08_12_servicenow_connection_all_permissions.png "service now grant permissions")

1. Configure the List Records Action as follows
    - **Record Type:** `Group`
    - **Advanced Parameters** (click `Show all`)
    - **Query:** `name=@{triggerBody()?['AssignmentGroup']}`

    ![ServiceNow List Action Configuration](./images/08_14_servicenow_list_records_configuraiton.png "servicenow list records configuration")

1. Add a new action

1. Select the `ServiceNow - Create Record` action

    ![Service Now - Create Record Action](./images/08_15_add_an_action_servicenow_create_item.png "servicenow create record action")

1. Configure the Create Record action as follows:
    - **Record Type:** `Incident`
    - **Advanced Parameters:**
        - you can show selected advanced parameters by clicking on the dropdown and select each parameter individually
        - **Short Description:**
            ```
            The following error occurred and needs to be investigated: @{triggerBody()?['Description']} 
            ```
        - **Assignment Group:** 
            ```
            @{first(body('List_Records')?['result'])['sys_id']}
            ```
        - **Description:** 
            ```
            The following workflow failed and needs to be investigated:

            Error Message: @{triggerBody()?['Description']}

            Additional Information: @{triggerBody()?['FailureDateTime']}
            Resolution Steps (from Operation Manual):
            @{triggerBody()?['ResolutionSteps']}
            ```
        - **Severity:** 
            ```
            @{triggerBody()?['Severity']}
            ```
        ![Configure ServiceNow Create Record](./images/08_16_configure_servicenow_create_record.png "configure servicenow create record")

1. Add the `Request (Built-in) -> Response` action

    ![Add Action Response](./images/08_17_add_action_response.png "Add action response")

1. Configure the Response action as follows:
    - **Status Code:** 200
    - **Body:**
        ```JSON
        {
            "TicketNumber": "@{body('Create_Record')?['result']?['number']}"
        }
        ```
    - **Response Body JSON Schema**
        ```JSON
        {
            "type": "object",
            "properties": {
                "TicketNumber": {
                    "type": "string"
                }
            }
        }
        ```
    
    ![Configure Action Response](./images/08_18_configure_action_response.png)

1. Click `Save` to save the changes made to the workflow

    ![Save Workflow](./images/08_19_save_worklow_tool_service_now_create_incident.png "save workflow")

    You should see a notification once the workflow is saved.

    ![Save Workflow Confirmation](./images/08_20_save_worklow_confirmation.png "save workflow confirmation")



