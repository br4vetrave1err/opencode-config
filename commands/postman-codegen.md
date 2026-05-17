---
description: "Generate typed client code from Postman collections"
agent: build
---

# Postman Codegen

Generate typed client code from Postman collections.

## Workflow

1. **Select Collection**
   - List available Postman collections via MCP
   - Ask user which collection to generate from
   - Confirm target language/framework

2. **Analyze Collection**
   - Read collection structure
   - Identify endpoints, parameters, request/response schemas
   - Detect authentication patterns

3. **Detect Project Conventions**
   - Check existing code for patterns:
     - HTTP client library (fetch, axios, requests, etc.)
     - Type system (TypeScript, Python types, etc.)
     - Error handling patterns
     - Naming conventions
   - Match generated code to project style

4. **Generate Code**
   - Create typed client with:
     - Method for each endpoint
     - Request/response types
     - Error types
     - Authentication handling
   - Write to appropriate project location

5. **Verify**
   - Check generated code compiles/parses
   - Confirm it matches project conventions
   - List generated files

## Supported Languages

- TypeScript/JavaScript
- Python
- Go
- Java
- Ruby
- PHP
- cURL

## Output

- List of generated files
- Usage example
- Any warnings about unsupported features
