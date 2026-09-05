# AI Product Data Processing Pipeline - n8n

## Overview

Automated product data processing and AI enrichment pipeline built in n8n.  
The workflow receives an XLSX product catalog through a Discord-based upload flow, validates and transforms the source data, processes products in controlled batches, generates structured product descriptions with Google Gemini, and exports the enriched dataset as a new XLSX file.

This repository contains a sanitized portfolio version of a workflow originally developed in a professional environment.

---

## Workflow Overview

![AI Product Data Processing Pipeline](https://raw.githubusercontent.com/MarcinDevAcc/Data-Projects/main/N8N/AI%20Product%20Data%20Processing%20Pipeline/assets/workflow_overview.png)

### Processing Flow

```text
Discord File Upload
        |
        v
File Download & Validation
        |
        v
Spreadsheet Extraction
        |
        v
Product Data Cleaning & Transformation
        |
        v
Required Field Validation
        |
        v
Batch Processing
        |
        v
AI Prompt Generation
        |
        v
Gemini AI Enrichment
        |
        v
Structured Output Validation
        |
        v
AI Response Parsing
        |
        v
Final XLSX Export
```

---

## Key Features

### File Ingestion & Validation
- **Webhook-based input** for receiving product file references from a Discord integration
- **HTTP file download** directly from the received file URL
- **MIME type validation** before spreadsheet processing
- **Explicit error handling** for unsupported file types using Stop And Error

### Product Data Cleaning & Transformation
- Standardizes raw spreadsheet columns into a consistent internal schema
- Renames irregular source fields such as `pcs/box`, `kg/pall`, and `size"cm"`
- Converts EUR product prices to PLN using a predefined exchange rate
- Preserves only selected product attributes required by downstream processing
- Filters out records missing required values:
  - EAN
  - PDF
  - Product image

### Batch Processing
- Products are processed in batches of **10 items**
- Batch-based execution limits the number of records processed by the AI stage at one time
- A rate-limit delay is applied between batch iterations

### AI Product Enrichment
- Generates two customer-facing fields for every valid product:
  - `opis_krotki` - structured short product specification
  - `opis_dlugi` - extended HTML product description
- Uses **Google Gemini 2.5 Pro** as the primary language model
- Uses **Google Gemini 2.5 Flash** as a fallback model
- Includes retry logic for failed AI executions
- Prompt rules restrict the model to the supplied product data and prohibit unsupported assumptions

### Structured Output Validation
- AI output is restricted to a predefined JSON schema
- Only the following generated fields are accepted:

```json
{
  "opis_krotki": "string",
  "opis_dlugi": "string"
}
```

- Required properties are enforced
- Additional output properties are rejected
- Source product attributes are not regenerated or overwritten by the AI model

### AI Response Processing
- Parses structured AI responses
- Removes technical workflow fields such as the temporary prompt and raw AI output
- Merges generated descriptions back into the corresponding source product record
- Preserves original product data as the source of truth
- Uses empty description values if a response cannot be parsed successfully

### Final Dataset Export
- Combines original transformed product data with AI-generated descriptions
- Exports the completed dataset to:

```text
enriched_product_catalog.xlsx
```

---

## Technical Implementation

### Workflow Architecture

The workflow is divided into six logical stages:

1. **File Ingestion & Validation**
   - Discord File Webhook
   - Download Uploaded File
   - Validate File Type
   - Extract Spreadsheet Data
   - Stop Processing - Invalid File

2. **Product Data Cleaning & Transformation**
   - Clean & Transform Product Data
   - Filter Valid Products

3. **Batch Processing**
   - Process Product Batches

4. **AI Product Enrichment**
   - Build AI Prompt
   - Generate Product Descriptions
   - Gemini 2.5 Pro - Primary Model
   - Gemini 2.5 Flash - Fallback Model
   - Enforce Output Schema

5. **AI Response Processing**
   - Parse AI Response
   - Rate Limit Delay

6. **Final Dataset Export**
   - Export Final XLSX

### Data Transformation

A JavaScript Code node is used to normalize product data before AI processing.

Example source-to-output field mapping:

| Source Field | Normalized Field |
| --- | --- |
| `description mktg` | `description_mktg` |
| `collection mktg` | `collection_mktg` |
| `thickness "mm"` | `thickness_mm` |
| `pcs/box` | `pcs_box` |
| `mq/box` | `mq_box` |
| `kg/pall` | `kg_pall` |
| `box/pall` | `box_pall` |
| `size"cm"` | `size_cm` |
| `price` | `price_PLN` |

### Reliability & Error Handling
- File type validation before spreadsheet extraction
- Processing stops explicitly for unsupported input files
- Required product fields are validated before AI processing
- AI execution includes retry handling
- Secondary Gemini model configured as fallback
- Structured output schema limits unexpected AI responses
- AI-generated values cannot overwrite original product attributes
- Batch processing and delay logic reduce request pressure on the AI service

---

## Business Value

The original workflow was created to reduce manual work associated with preparing product information for e-commerce use.

### Results
- **2,800+ product descriptions** generated through the automated workflow
- **75% reduction in manual processing time**
- Standardized output structure across processed product records
- Reduced repetitive manual product-description preparation
- Combined data transformation and AI enrichment into one repeatable workflow

### Practical Applications
- Product catalog enrichment
- E-commerce content preparation
- Supplier spreadsheet normalization
- Structured AI content generation
- Repetitive data-processing automation
- Product data quality validation

---

## Tools & Technologies

### Automation
- n8n
- Webhooks
- HTTP Request
- Batch processing
- Workflow error handling

### Data Processing
- JavaScript
- JSON
- XLSX
- Structured field mapping
- Data validation and transformation

### AI Integration
- Google Gemini 2.5 Pro
- Google Gemini 2.5 Flash
- Structured Output Parser
- JSON Schema
- Prompt engineering
- Fallback model configuration

---

## Confidentiality

This repository contains a sanitized portfolio version of a workflow originally developed in a professional environment.

The following elements have been removed or replaced:
- Company-specific data
- Production product files
- Credentials and API keys
- n8n instance metadata
- Production webhook identifiers
- Internal workflow identifiers
- Company-specific file names and references

The repository is intended to demonstrate the workflow architecture, automation logic, data transformation approach, AI integration, validation, and error handling.

It is not provided as a production-ready deployment and does not include the confidential source files or credentials required to execute the original implementation.

---

## Files Structure

```
AI Product Data Processing Pipeline/
│
├── README.md
│
├── assets/
│   └── workflow_overview.png
│
└── workflow/
    └── AI Product Data Processing Pipeline - Portfolio Demo.json
```

- `README.md` - project documentation
- `AI Product Data Processing Pipeline - Portfolio Demo.json` - sanitized n8n workflow export
- `workflow_overview.png` - full workflow architecture screenshot

---

## Notes

The public workflow intentionally excludes production datasets and credentials.  
The original implementation can be discussed in more detail during a private technical walkthrough where confidentiality requirements allow.
