---
title: API Member Payload
created: 2026-07-08
source: [[01_Inbox/OneNote Import/Drew @ Work]]
tags:
  - resource/api
  - area/development
---

# API Member Payload

## Source Context

- Original OneNote date: Friday, February 13, 2026, 2:21 PM.
- Source URL: `https://localhost:7179/swagger/index.html`.
- Paycor review URL was present in source import; not needed for API payload work.

## Response Shape

```json
{
  "result": {
    "min": null,
    "empNum": "001EU",
    "erpCustomerId": "001EU",
    "customerCategory": "Retired",
    "isActive": "True",
    "customerName": "Customer, Sample A",
    "customerContactName": "Sample Customer A",
    "address1": "123 Example Street",
    "address2": "",
    "address3": "",
    "city": "Brooklyn",
    "state": "NY",
    "zip": "11236",
    "country": "United States",
    "phone1": "5550000000",
    "phone2": "0000000000",
    "phone3": "",
    "firstName": "Sample",
    "lastName": "Customer",
    "shipToName": "Customer, Sample A",
    "email1": "customer@example.com",
    "email2": null,
    "email3": null,
    "customFields": {},
    "erpSystemId": "Microsoft Dynamics GP 2018 (PEFMBP)",
    "controlId": "001EU"
  }
}
```

## Request Shape

```json
{
  "empNum": "21K3Y",
  "erpCustomerId": "21K3Y",
  "customerCategory": "Retired",
  "isActive": "True",
  "customerName": "Customer, Sample B",
  "address1": "456 Example Avenue",
  "firstName": "Sample",
  "lastName": "Customer",
  "shipToName": "Customer, Sample B",
  "email1": "sample@example.com",
  "customFields": {
    "COMMENT1": "TEST",
    "COMMENT2": "TEST"
  }
}
```

## Partial Update Shape

```json
{
  "result": {
    "empNum": "003BI",
    "erpCustomerId": "003BI",
    "customerCategory": "Retired",
    "isActive": "True",
    "email1": "changed@example.com"
  }
}
```

## Field Notes

- `empNum` and `erpCustomerId` can match.
- `customFields` may be empty or contain comment fields.
- API examples in this note are sanitized; use live Swagger/dev data for exact values.
