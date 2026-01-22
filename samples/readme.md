# Logic Apps Samples

You can use this folder to share Logic Apps sample.

## List of Samples

- [**Sample Logic Apps Workspace**](./sample-logicapp-workspace/): This is a simple request response project, just to exemplify the required structure.
- [**AI Loan Agent**](./ai-loan-agent-sample/): AI-powered loan approval system that automates the evaluation of vehicle loan applications using Azure Logic Apps Standard and Azure OpenAI.
- [**AI Product Return Agent**](./product-return-agent-sample/): AI-powered product return system that automates the evaluation of return requests using Azure Logic Apps Standard and Azure OpenAI. Features autonomous decision-making with policy validation, refund calculations, and human escalation.
- [**Transaction Repair Agent**](./transaction-repair-agent/): Conversational AI agent that helps operations teams diagnose and repair failed work orders through natural chat interaction. Built with Azure Logic Apps Standard and Azure OpenAI, featuring guided workflows, approval management, and ITSM audit logging.

## How to contribute

Follow the instructions bellow before sharing projects.

- Create one folder for each sample.
- Your sample project should be created in VS Code as a workspace.

### Readme at the workspace root

You must include a readme.md file at your workspace root folder - at the same level you include the workspace file. This document should include:

- A description of the project and each workflow.
- Required connections
- Deployment instructions

### Logic Apps Project

The Logic Apps Project should be called LogicApps. The project folder should include the following files:

- **cloud.settings.json** - create a file called cloud.setting.json with the keys that are required by customers to recreate the local.settings.json
- **readme.md** - include a readme.md file with instructions to recreate local.settings.json and recover keys and URLs required.

### Deployment Scripts

If you are providing deployment scripts to Azure Portal or to regenerate Azure connectors, add a Deployment folder to the workspace and provide the scripts under this folder.
