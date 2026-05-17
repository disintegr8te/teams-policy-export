# Example Output Structure

When you run `Export-TeamsPolicies.ps1`, it creates a timestamped output directory with the following structure:

```
Teams-Policy-Export-YYYYMMDD-HHmmss/
├── raw-json/
│   ├── CsTeamsCallingPolicy.json
│   ├── CsTeamsMessagingPolicy.json
│   ├── CsTeamsMeetingPolicy.json
│   └── ... (one JSON file per policy type)
├── flat-csv/
│   ├── CsTeamsCallingPolicy.csv
│   ├── CsTeamsMessagingPolicy.csv
│   ├── CsTeamsMeetingPolicy.csv
│   └── ... (flattened CSV per policy type)
├── manifest.csv
└── TeamsPolicies.xlsx
```

## Directory Contents

- **raw-json/** -- Raw JSON exports of each Teams policy type as returned by the Microsoft Teams PowerShell module.
- **flat-csv/** -- Flattened CSV representations of each policy, suitable for diff comparisons and version control.
- **manifest.csv** -- Summary manifest listing all exported policy types, counts, and export timestamps.
- **TeamsPolicies.xlsx** -- Combined Excel workbook with formatted sheets for stakeholder review, including Microsoft recommendation columns and actionable decision columns.

## Note

This directory contains no actual data. It exists solely to document the output structure for users of this tool.
