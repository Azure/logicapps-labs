---
sidebar_position: 2
title: Template for creating a new Lab
sidebar_label: "Template for creating a new Lab"
description: Description of your Lab
image: aka.ms/logicapps/labs/contributing/assets/acns-pets-app.png
keywords: [keywords, describing, the main topics]
authors:
 - "Carl Andrews"
 - "John Smith"
contacts:
 - "@carl2357"
 - "@john5495"
---

 **Authors:**
[Carl Andrews - Microsoft](https://www.linkedin.com), [John Smith - Contoso](https://www.linkedin.com)

## High-level architecture

![Automate RAG demo architecture](./assets/automate-rag.gif)

## Introduction

When working with RAG (Retrieval-Augmented Generation) applications, the retriever, such as Azure AI Search, plays a crucial role in obtaining the most relevant results for the language model to deliver a response to end users. It is essential to store data representations that are semantically similar to specific user searches, such as vectors, which are a key component in vector and hybrid search.

The task of parsing, chunking, vectorizing data and storing it in an index is handled by an Azure AI Search feature known as integrated vectorization. For supported data sources, this functionality also enables automated data ingestion, enrichment and processing. However, there are numerous data sources not directly integrated with AI Search but accessible through a variety of connectors available in Azure Logic Apps.

Azure Logic Apps has introduced new functionality that facilitates every step required to process documents from their connectors for unstructured data. Now data extraction, pulling files, parsing data, chunking, vectorizing and indexing your data into Azure AI Search is all streamlined into one integrated flow. Additionally, Azure Logic Apps now offers templates for high-demand connectors, with predefined indexing workflows for RAG-ready AI Search indexes, simplifying the creation of these workflows. Some of these templates include indexing pipelines for files located in SharePoint Online, Azure Files, SFTP, among others.

:::info
To learn more, you can ask your favorite AI companion these questions:
- What is RAG in AI?
- What is Azure AI Search?
- What is vectorization in the context of search?
- What is a search index?
:::

## Prerequisites


- A data source with unstructured data supported by Azure Logic Apps connectors
- Azure Logic App (Workflow Service Plan)
- Azure AI Search service
- Azure OpenAI service with a deployed text embedding model
- Azure Logic App built-in template. This is so you don’t have to create your own workflow. Note that you can create your own as well. However, this is not covered as part of this blog post.


This tutorial shows how to index files that you add after the workflow creation in an Azure Files share.



## Azure AI Search index creation

This integration at this time needs an index created in Azure AI Search with the following schema (as a minimum). Later in this article we will explain how you can update the workflow to map more fields to each document chunk accordingly.

### Azure AI Search index: Minimum schema needed for this integration

Note: The sample index definitions below include a vector field with 3072 dimensions, corresponding to the Azure OpenAI text-embedding-3-large model. If you use a different Azure OpenAI embedding model or a different dimensionality, you must adjust the index definition accordingly before index creation.

```json
{
  "name": "chunked-index",
  "fields": [
    {
      "name": "id",
      "type": "Edm.String",
      "searchable": true,
      "retrievable": true,
      "key": true
    },
    {
      "name": "documentName",
      "type": "Edm.String",
      "searchable": true,
      "retrievable": true
    },
    {
      "name": "content",
      "type": "Edm.String",
      "searchable": true,
      "retrievable": true
    },
    {
      "name": "embeddings",
      "type": "Collection(Edm.Single)",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "dimensions": 3072,
      "vectorSearchProfile": "vector-profile"
    }
  ],
  "vectorSearch": {
    "algorithms": [
      {
        "name": "vector-config",
        "kind": "hnsw",
        "hnswParameters": {
          "metric": "cosine",
          "m": 4,
          "efConstruction": 400,
          "efSearch": 500
        },
        "exhaustiveKnnParameters": null
      }
    ],
    "profiles": [
      {
        "name": "vector-profile",
        "algorithm": "vector-config"
      }
    ]
  }
}

```

### Azure AI Search index: Vectorization at query time

If you need Azure AI Search to also vectorize your data at query time, instead of performing this operation from the orchestrator end from your RAG application, you can use the following JSON definition for your index. You need to make sure to change the Azure OpenAI endpoint and change for yours. Also, create a service-managed identity for your AI Search service, and follow the instructions to assign the Cognitive Services OpenAI User role in your Azure OpenAI service.


```json

{
  "name": "chunked-index",
  "fields": [
    {
      "name": "id",
      "type": "Edm.String",
      "searchable": true,
      "retrievable": true,
      "key": true
    },
    {
      "name": "documentName",
      "type": "Edm.String",
      "searchable": true,
      "retrievable": true
    },
    {
      "name": "content",
      "type": "Edm.String",
      "searchable": true,
      "retrievable": true
    },
    {
      "name": "embeddings",
      "type": "Collection(Edm.Single)",
      "searchable": true,
      "filterable": false,
      "retrievable": true,
      "dimensions": 3072,
      "vectorSearchProfile": "vector-profile"
    }
  ],
  "vectorSearch": {
    "algorithms": [
      {
        "name": "vector-config",
        "kind": "hnsw",
        "hnswParameters": {
          "metric": "cosine",
          "m": 4,
          "efConstruction": 400,
          "efSearch": 500
        },
        "exhaustiveKnnParameters": null
      }
    ],
    "profiles": [
      {
        "name": "vector-profile",
        "algorithm": "vector-config",
        "vectorizer": "azureOpenAI-vectorizer"
      }
    ],
    "vectorizers": [
      {
        "name": "azureOpenAI-vectorizer",
        "kind": "azureOpenAI",
        "azureOpenAIParameters": {
          "resourceUri": "https://<yourAOAIendpoint>.openai.azure.com",
          "deploymentId": "text-embedding-3-large",
          "modelName": "text-embedding-3-large"
        }
      }
    ]
  }
}


```

### **Create index from JSON in Azure portal**

This is how you can create the index from the Azure portal using the JSON template above:

*   Go to your AI Search service, select **Search Management** -> **Indexes** and click on **Add index** and select **Add index (JSON**) from the dropdown menu.

![Image 4: Figure 1 - Create Azure AI Search index from JSON using Azure portal](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzkzMmk4QkY5QTQzOUEwQTZDQUUx?image-dimensions=750x750&revision=15 "Figure 1 - Create Azure AI Search index from JSON using Azure portal")

*   Delete the JSON structure that appears at the right, copy the JSON template above according to your needs and paste in the canvas at the right. Click on **Save**.

![Image 5: Figure 2 - Copy the JSON template provided in this tutorial for index creation](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzkzNGkyMkI2NDlCNkRDRjBCNjBF?image-dimensions=750x750&revision=15 "Figure 2 - Copy the JSON template provided in this tutorial for index creation")

*   The index that is created with the template is called **chunked-index** and we’ll use it as the target index in this example.

### **Using Azure Logic App workflow templates to import data from your unstructured data source**

*   Go to your Logic App resource, click on **Workflows** > **Workflows** and click on **+Add > Add from Template**

![Image 6: Figure 3 - Add workflow from Template in Azure Logic App](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzkyMmk1RDM4NTNDNjA3NDZGQzg1?image-dimensions=750x750&revision=15 "Figure 3 - Add workflow from Template in Azure Logic App")

*   Look for **azure ai search** in the search box and choose the template that aligns with your data source. Note that you should be able to use any Azure Logic App supported connector of unstructured data so you can use it to import data to AI Search with this same chunking and embedding pattern, but you will need to modify the workflow according to your needs. 
*   In this case we will choose the “**Azure Files: Ingest and index documents at a schedule using Azure OpenAI and Azure AI Search - RAG pattern”**

![Image 7: Figure 4 - Choose Azure Files RAG template](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzkzNWk4M0VBN0EyODA0OUVDMTlB?image-dimensions=750x750&revision=15 "Figure 4 - Choose Azure Files RAG template")

*     Select **Use this template**

![Image 8: Figure 5 - Review the workflow and select it](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzkzNmlBRUY0NURERDQ1MjFGOTAy?image-dimensions=750x750&revision=15 "Figure 5 - Review the workflow and select it")

*   Choose a workflow name and type it. Click on **Next**.

![Image 9: Figure 6 - Name your workflow](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzkzOWlBNUU0N0U1NjNFQUM3MDE1?image-dimensions=750x750&revision=15 "Figure 6 - Name your workflow")

*    Click on **Connect** for each connection in the template configuration and add your existing endpoints which correspond to your data source (in this case Azure Files, your Azure AI Search service and your AOAI service)

![Image 10: Figure 7 - Configure connector connections](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzk0MGk3ODU2Qzk4QkE1NzQ0OUQ3?image-dimensions=750x750&revision=15 "Figure 7 - Configure connector connections")

Examples of how each connection configuration looks like are here. Make sure that you have a minimum role of **Contributor** access over the resources to establish the connections.

_For Azure Files connection_: Your Azure Storage account URI is under your Azure Storage account **Settings > Endpoints > File Service** and the domain is _.file.core.windows.net._ You can find the connection string under the Storage Account **Security + Network > Keys > Connection String.**

Copy the URI and add to the **Storage Account URI** configuration and the connection string in their respective fields.

![Image 11: Figure 8 - Azure Files connection configuration](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzkyNmlCQUZGMjkxRDJFMDY4RDM5?image-dimensions=750x750&revision=15 "Figure 8 - Azure Files connection configuration")

_For Azure AI Search connection_: The Azure AI Search endpoint URL is under your AI Search service **Overview > Essentials > URL** and the domain is _.search.windows.net._

In case your setup is with admin key, you’ll find it under AI Search service **Settings >  Keys > Primary Admin Key.**

![Image 12: Figure 9 - AI Search connection](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzkyN2lCOEQxNkQ2NTVGMzkxNEQw?image-dimensions=750x750&revision=15 "Figure 9 - AI Search connection")

_For Azure OpenAI connection_: The Azure OpenAI endpoint URL is under your Azure OpenAI service **Resource Management** > **Keys and Endpoint** > **Endpoint** and the suffix  domain is _.openai.azure.com._ For key setup copy Key1 and copy in the Authentication Key configuration.

![Image 13: Figure 10 - Azure OpenAI connection](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzkyOGk1NjQ5MDlGQjMzRTY4NDE0?image-dimensions=750x750&revision=15 "Figure 10 - Azure OpenAI connection")

*   After configuring all services connections, click **Next**.

![Image 14: Figure 11 - Connections configuration complete](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzkyOWk0NEIxODgxMDYzOEJBQkVG?image-dimensions=750x750&revision=15 "Figure 11 - Connections configuration complete")

Fill out the following indexing configuration details. It assumes that:

*   You already created the index with one of the templates above. 
*   You have an Azure OpenAI embedding model called “text-embeddings-3-large”in your AOAI deployed instance.

### **Indexing Workflow configuration details:**

*   AISearch index name: This is the name of the index that we’ve created as part of this tutorial. 
*   OpenAI text embedding deployment identifier = text-embedding-3-large. This is the name of the Azure OpenAI embedding model deployment: This is the embedding model deployment name (not the model name – in this case is the same though).

![Image 15: Figure 12 - Azure OpenAI embedding model name](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzk0MWk0MDYwQzIyN0JBQzAwOTdG?image-dimensions=750x750&revision=15 "Figure 12 - Azure OpenAI embedding model name")

*      Azure Files storage Folder Name: This is the name of your Azure Files file share, where your files are located.

![Image 16: Figure 13 - Azure Files share name](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzk0M2lBQTZCM0I1MzBFMjJDRTc1?image-dimensions=750x750&revision=15 "Figure 13 - Azure Files share name")

*   Click **Next** and then **Create**.

![Image 17: Figure 14 - Review workflow details and create](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzk0NGlEMTlBMjFDQkNCREZFMjND?image-dimensions=750x750&revision=15 "Figure 14 - Review workflow details and create")

*   Click on **Go to My Workflow** and wait until the initial run is completed. This is scheduled to be triggered to check for any new files added to your Azure Files share. After you add new files to your configured file share, you must see them reflected in your AI Search index.
*   Right after you have initial vectorized data in your index, you can use the index in this tutorial to chat with your data from your preferred RAG orchestrator such as [Azure AI Studio](https://learn.microsoft.com/azure/ai-studio/what-is-ai-studio).
*   To use your Azure AI Search index in [Azure AI Studio](https://ai.azure.com/) go to **Project Playground > Chat > Add your data > Add a new data source** and [follow the instructions](https://learn.microsoft.com/azure/ai-studio/how-to/index-add) to set up your index. 

:::note
>If you created an index with the minimal JSON configuration in this tutorial, you must follow the instructions in the Azure AI Studio documentation here as is. However, if you used the option of adding an index vectorizer, you must remove the vector option from the AI Studio configuration since the index will contact your embedding model directly.
::: 

![Image 18: Figure 15 - Azure AI Studio Chat Playground ](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00MjY2MDgzLTYyNzk2OWkwMDc3RTI1RUJGNzlGNDRE?image-dimensions=750x750&revision=15 "Figure 15 - Azure AI Studio Chat Playground Add your data")

## Additional considerations 

For optimal AI search relevance, consider using a hybrid approach that combines vector and keyword search along with a semantic ranker. This method is generally more effective for many use cases. For more information, please visit: [Azure AI Search Outperforming Vector Search with Hybrid](https://techcommunity.microsoft.com/t5/ai-azure-ai-services-blog/azure-ai-search-outperforming-vector-search-with-hybrid/ba-p/3929167#:~:text=In%20this%20blog%20post,%20we%20share%20the%20results%20of%20experiments).  This case focuses specifically on fixed-chunking and text-only scenarios.



:::tip[Congratulations!]

Congratulations on finshing this Lab on automating RAG indexing with Azure Logic Apps and AI Search! Here are the main conclusions from this Lab:

- Integration of Azure Logic Apps and AI Search: Azure Logic Apps facilitates every step required to process documents from various connectors for unstructured data, streamlining the process of data extraction, parsing, chunking, vectorizing, and indexing into Azure AI Search.

- Automated Data Ingestion and Processing: Azure Logic Apps enables automated data ingestion, enrichment, and processing for supported data sources, making it easier to manage and index unstructured data.

- Predefined Templates for High-Demand Connectors: Azure Logic Apps offers templates for high-demand connectors with predefined indexing workflows for RAG-ready AI Search indexes, simplifying the creation of these workflows.

- Creating and Configuring Azure AI Search Indexes: This Lab provides detailed instructions on creating and configuring Azure AI Search indexes, including the necessary schema and vectorization at query time.

**Well done on exploring these advanced features and capabilities! This knowledge will undoubtedly enhance your ability to manage and index unstructured data effectively. Keep up the great work!**

:::

---